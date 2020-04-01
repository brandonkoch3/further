//
//  PersonDetectee.swift
//  SwiftUIDesignProject
//
//  Created by Brandon on 4/1/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import Foundation
import CoreBluetooth
import Combine

class PersonDetecee: NSObject, ObservableObject {
    
    // Updateable config
    @Published var personFound = false
    @Published var isDetecting = false
    
    let testUUID = UUID().uuidString
    
    @Published var connectedPeriperhals = [CBPeripheral]()
    
    // Bluetooth
    var centralManager: CBCentralManager!
    var internalPeripheral:  CBPeripheral!
    let internalServiceCBUUID = CBUUID(string: "0xFFE0")
    var txCharacteristic: CBCharacteristic!
    var peripheralManager: CBPeripheralManager!
    
    // Combine
    var connectedSubscriber: AnyCancellable?
    var rssiTimer: AnyCancellable?
    var foundSubscriber: AnyCancellable?
    
    override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        connectedSubscriber = $connectedPeriperhals
            .receive(on: RunLoop.main)
            .sink(receiveValue: { connectors in
                connectors.count > 0 ? self.startTimer() : self.stopTimer()
            })
        
    }
    
    private func startTimer() {
        rssiTimer = Timer.publish(every: 1.0, tolerance: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { _ in self.checkRSSI() }
    }
    
    private func stopTimer() {
        rssiTimer?.cancel()
    }
    
    private func checkRSSI() {
        _ = connectedPeriperhals.compactMap { acc in
            acc.readRSSI()
        }
    }
    
}

extension PersonDetecee: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        // Start advertising
        var advertiseData = [String: Any]()
        advertiseData["kCBAdvDataTimestamp"] = Date().timeIntervalSinceReferenceDate
        advertiseData["kCBAdvDataLocalName"] = "further_\(testUUID)"
        advertiseData["kCBAdvDataIsConnectable"] = 1
        advertiseData["kCBAdvDataServiceUUIDs"] = [CBUUID(string: "FFE0")]
        peripheralManager.startAdvertising(advertiseData)
        
        // Configure services
        let serviceUUID = CBUUID(string: "FFE0")
        let service = CBMutableService(type: serviceUUID, primary: true)
        
        // Configure characteristics
        let characteristicUUID = CBUUID(string: "FFE1")
        let properties = CBCharacteristicProperties([.notify, .write])
        let permissions: CBAttributePermissions = [.writeable]
        let characteristic = CBMutableCharacteristic(
            type: characteristicUUID,
            properties: properties,
            value: nil,
            permissions: permissions)
        
        // Add characteristics
        service.characteristics = [characteristic]
        
        // Add service
        peripheralManager.add(service)
    }
    
    // MARK: Advertising Delegates
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager,
                                              error: Error?) {
        print("We're advertising peripheral:", peripheral)
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        print("Service added!", service)
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager,
                           didReceiveRead request: CBATTRequest) {
        
        peripheralManager.respond(to: request, withResult: .success)
        
        print("Got read request!", request)
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        
        for request in requests {
            peripheral.updateValue(request.value!, for: request.characteristic as! CBMutableCharacteristic, onSubscribedCentrals: [request.central])
        }
        peripheralManager.respond(to: requests[0], withResult: .success)
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        let test: [UInt8] = [0xd7, 0x4f, 0x88, 0x01]
        let data = Data(test)
        peripheralManager.updateValue(data, for: characteristic as! CBMutableCharacteristic, onSubscribedCentrals: [central])
        print("Someone subscribed!", characteristic)
        
    }
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        print("Someone unsubscribed!", characteristic)
    }
    
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        print("Ready to update subscribers!")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didOpen channel: CBL2CAPChannel?, error: Error?) {
        print("OPENED CHANNEL!")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didUnpublishL2CAPChannel PSM: CBL2CAPPSM, error: Error?) {
        print("DID UNPUBLISH CHANNEL")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didPublishL2CAPChannel PSM: CBL2CAPPSM, error: Error?) {
        print("DID PUBLISH CHANNEL")
    }
}

// MARK: Bluetooth Delegates
extension PersonDetecee: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
            centralManager.scanForPeripherals(withServices: [internalServiceCBUUID], options: ["CBCentralManagerScanOptionAllowDuplicatesKey": 1])
            //centralManager.scanForPeripherals(withServices: [internalServiceCBUUID])
        @unknown default:
            print("central.state cannot be understood.")
        }
    }
    
    // MARK: Device Discovery
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard !advertisementData.isEmpty else { return }
        guard let localName = advertisementData["kCBAdvDataLocalName"] as? String else { return }
        guard localName.contains("further_") else { return }
        guard !connectedPeriperhals.contains(where: { $0.identifier == peripheral.identifier }) else { return }
        let foundUUID = localName.replacingOccurrences(of: "further_", with: "")
        guard foundUUID != testUUID else { return }
        
        
        print("DISCOVERED AN ACCESSORY WITH IDENTIFIER", peripheral.identifier, "with further ID:", foundUUID, "with RSSI:", RSSI)

        let foundPerson = peripheral
        foundPerson.delegate = self
        connectedPeriperhals.append(peripheral)
        centralManager.connect(foundPerson)
        //peripheral.delegate = self
        //centralManager.connect(peripheral)
        //internalPeripheral = peripheral
//        sp107ePeripheral = peripheral
//        sp107ePeripheral.delegate = self
//        centralManager.stopScan()
        //centralManager.connect(internalPeripheral)

    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        let now = Date().timeIntervalSince1970
        print("Connected to Salsa at", now, "peripheral:", peripheral)
        
        
        //internalPeripheral.discoverServices([internalServiceCBUUID])
    }
    
    internal func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        let now = Date().timeIntervalSince1970
        print("Disconnect from Salsa at", now, "peripheral:", peripheral)
        connectedPeriperhals.removeAll(where: { $0.identifier == peripheral.identifier})
    }
}

// MARK: Service/Characteristic Discovery Delegates
extension PersonDetecee: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {return}
        
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {return}
        
        for characteristic in characteristics {

            print("Characteristic:", characteristic)
            peripheral.discoverDescriptors(for: characteristic)
            
            if characteristic.properties.contains(.authenticatedSignedWrites) {
                print("Allows signed writes.")
            }
            if characteristic.properties.contains(.broadcast) {
                print("Allows broadcast.")
            }
            if characteristic.properties.contains(.extendedProperties) {
                print("Has extended properties.")
            }
            if characteristic.properties.contains(.indicate) {
                print("Allows indicate.")
            }
            if characteristic.properties.contains(.indicateEncryptionRequired) {
                print("Indicate encryption required.")
            }
            if characteristic.properties.contains(.notify) {
                print("Allows notify.")
            }
            if characteristic.properties.contains(.notifyEncryptionRequired) {
                print("Notify encryption required.")
            }
            if characteristic.properties.contains(.read) {
                print("Allows read.")
            }
            if characteristic.properties.contains(.write) {
                print("Allows write.")
            }
            if characteristic.properties.contains(.writeWithoutResponse) {
                print("Allows write without response.")
            }
            
            if characteristic.uuid == CBUUID(string: "FFE1") {
                peripheral.setNotifyValue(true, for: characteristic)
                txCharacteristic = characteristic
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let ASCIIstring = NSString(data: characteristic.value!, encoding: String.Encoding.utf8.rawValue) {
            let characteristicASCIIValue = ASCIIstring
            print("Value Recieved: \((characteristicASCIIValue as String))")
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        guard error == nil else {
            print("Error writing value:", error?.localizedDescription ?? "Unknown descriptor error.")
            return
        }
        print("Succeeded in writing value!")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print("\(error.debugDescription)")
            return
        }
        if ((characteristic.descriptors) != nil) {
            for x in characteristic.descriptors!{
                let descript = x as CBDescriptor?
                _ = descript
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if (error != nil) {
            print("Error changing notification state:\(String(describing: error?.localizedDescription))")
        } else {
            print("Characteristic's value subscribed")
        }
        if (characteristic.isNotifying) {
            print ("Subscribed. Notification has begun for: \(characteristic.uuid)")
            
            // Send initial values
            let new1: [UInt8] = [0, 113, 213, 9]
            let new2: [UInt8] = [127, 59, 64, 11]
            let new3: [UInt8] = [255, 255, 255, 12]
            let new4: [UInt8] = [127, 201, 238, 10]
            let dataToWrite = [new1, new2, new3, new4]
            if characteristic.uuid == CBUUID(string: "FFE1") {
                for item in dataToWrite {
                    let data = Data(item)
                    peripheral.writeValue(data, for: characteristic, type: .withResponse)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("Wrote characteristic to", characteristic.uuid)
        if let myError = error {
            print("Received error:", myError)
        }
    }
    
    private func characteristicText(characteristic: CBCharacteristic) -> String? {
        guard let data = characteristic.value else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        print("RSSI:", RSSI)
        self.personFound = (Double(truncating: RSSI) >= -40.0)
    }
}

enum CharacteristicPermissions {
    case read, write, notify
}

/**
This extension makes checking a characteristic's permissions cleaner and easier to read. It abstracts away the CBCharacterisProperties class and the raw value bitwise operator logic.
*/
extension CBCharacteristic {

    /// Returns a Set of permissions for the characteristic
    var permissions: Set<CharacteristicPermissions> {
        var permissionsSet = Set<CharacteristicPermissions>()

        if self.properties.rawValue & CBCharacteristicProperties.read.rawValue != 0 {
            permissionsSet.insert(CharacteristicPermissions.read)
        }

        if self.properties.rawValue & CBCharacteristicProperties.write.rawValue != 0 {
            permissionsSet.insert(CharacteristicPermissions.write)
        }

        if self.properties.rawValue & CBCharacteristicProperties.notify.rawValue != 0 {
            permissionsSet.insert(CharacteristicPermissions.notify)
        }

        return permissionsSet
    }
}
