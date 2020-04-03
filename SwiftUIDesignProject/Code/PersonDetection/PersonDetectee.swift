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

class PersonDetectee: NSObject, ObservableObject {
    
    // UI-based config
    @Published var personFound = false
    @Published var isDetecting = false
    
    // Person config
    var myID = UUID().uuidString
    @Published var connectedPeriperhals = [CBPeripheral]()
    private var activeParticipants = [PersonModel]()
    private var savedParticipants = [PersonModel]()
    
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
    var detectingCancellable: AnyCancellable?
    
    // Helpers
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    let defaults = UserDefaults.standard
    
    override init() {
        super.init()
        
        if let myID = UserDefaults.standard.string(forKey: "deviceID") {
            self.myID = myID
        } else {
            let newID = UUID().uuidString
            self.myID = newID
            UserDefaults.standard.set(newID, forKey: "deviceID")
        }
        
        connectedSubscriber = $connectedPeriperhals
            .receive(on: RunLoop.main)
            .sink(receiveValue: { connectors in
                connectors.count > 0 ? self.startTimer() : self.stopTimer()
            })
        
        if let savedData = defaults.object(forKey: "interactions") as? Data {
            if let loadedData = try? decoder.decode([PersonModel].self, from: savedData) {
                self.savedParticipants = loadedData
            }
        }
        
        self.isDetecting = true
        
        detectingCancellable = $isDetecting
        .receive(on: RunLoop.main)
        .sink(receiveValue: { detecting in
            detecting ? self.start() : self.stop()
        })
    }
    
    // MARK: Parent BLE Functions
    private func start() {
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    private func stop() {
        peripheralManager.stopAdvertising()
        centralManager.stopScan()
        peripheralManager = nil
        centralManager = nil
        self.activeParticipants.removeAll()
        self.connectedPeriperhals.removeAll()
    }
        
    // MARK: RSSI Timer Check
    private func startTimer() {
        rssiTimer = Timer.publish(every: 1.0, tolerance: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { _ in self.checkRSSI() }
    }
    
    private func stopTimer() {
        rssiTimer?.cancel()
        self.personFound = false
    }
    
    private func checkRSSI() {
        _ = connectedPeriperhals.compactMap { acc in
            acc.readRSSI()
        }
    }
    
    // MARK: Internal BLE Checking
    func peerConnected(peerID: String, bleID: String) {
        guard !self.activeParticipants.contains(where: { $0.personUUID == peerID }) else { return }
        guard !self.savedParticipants.contains(where: { $0.personUUID == peerID && $0.hasReceivedNotification }) else { return }
        let newParticipant = PersonModel(personUUID: peerID, bleUUID: bleID, connectTime: Date().timeIntervalSince1970, disconnectTime: nil, hasReceivedNotification: false)
        print("Connected to", peerID)
        DispatchQueue.main.async {
            self.activeParticipants.append(newParticipant)
        }
    }
    
    func peerDisconnected(peerID: String, bleID: String) {
        guard self.activeParticipants.contains(where: { $0.personUUID == peerID }) else { return }
        if let participant = self.activeParticipants.first(where: { $0.personUUID == peerID }) {
            var myParticipant = participant
            if Date().timeIntervalSince1970 - myParticipant.connectTime >= 60 {
                myParticipant.disconnectTime = Date().timeIntervalSince1970
                print("Disconnected from", peerID, "with 60 second interval")
                self.save(participant: myParticipant)
            }
            DispatchQueue.main.async {
                self.connectedPeriperhals.removeAll(where: { $0.identifier.uuidString == bleID })
                self.activeParticipants.removeAll(where: { $0.personUUID == peerID })
            }
            print("Disconnected from", peerID)
        }
    }
    
    func save(participant: PersonModel) {
        self.savedParticipants.append(participant)
        if let encoded = try? encoder.encode(self.savedParticipants) {
            defaults.set(encoded, forKey: "interactions")
        }
    }
}

extension PersonDetectee: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        // Start advertising
        var advertiseData = [String: Any]()
        advertiseData["kCBAdvDataTimestamp"] = Date().timeIntervalSinceReferenceDate
        advertiseData["kCBAdvDataLocalName"] = "further_\(myID)"
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
        //
    }
}

// MARK: Bluetooth Delegates
extension PersonDetectee: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            break
        case .resetting:
            break
        case .unsupported:
            break
        case .unauthorized:
            break
        case .poweredOff:
            break
        case .poweredOn:
            centralManager.scanForPeripherals(withServices: [internalServiceCBUUID], options: ["CBCentralManagerScanOptionAllowDuplicatesKey": 1])
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
        guard foundUUID != myID else { return }

        let foundPerson = peripheral
        foundPerson.delegate = self
        connectedPeriperhals.append(peripheral)
        self.peerConnected(peerID: foundUUID, bleID: peripheral.identifier.uuidString)
        centralManager.connect(foundPerson)
        
        print("DISCOVERED AN ACCESSORY WITH IDENTIFIER", peripheral.identifier, "with further ID:", foundUUID, "with RSSI:", RSSI)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to Further Participant at", peripheral.identifier.uuidString)
    }
    
    internal func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let peer = self.activeParticipants.first(where: { $0.bleUUID == peripheral.identifier.uuidString }) {
            let peerID = peer.personUUID
            self.peerDisconnected(peerID: peerID, bleID: peripheral.identifier.uuidString)
        }
    }
}

// MARK: Service/Characteristic Discovery Delegates
extension PersonDetectee: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {return}
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {return}
        for characteristic in characteristics {
            if characteristic.uuid == CBUUID(string: "FFE1") {
                peripheral.setNotifyValue(true, for: characteristic)
                txCharacteristic = characteristic
            }
        }
    }
    
    private func characteristicText(characteristic: CBCharacteristic) -> String? {
        guard let data = characteristic.value else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        print("RSSI:", RSSI)
        self.personFound = (Double(truncating: RSSI) >= -60.0)
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
