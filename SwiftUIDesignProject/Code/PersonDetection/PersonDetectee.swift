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
    var myID: String = ""
    @Published var connectedPeriperhals = [CBPeripheral]()
    private var activeParticipants = [PersonModel]()
    private var savedParticipants = [PersonModel]()
    
    // Bluetooth
    var centralManager: CBCentralManager!
    var internalPeripheral:  CBPeripheral!
    let internalServiceCBUUID = CBUUID(string: "0xFD6F")
    var txCharacteristic: CBCharacteristic!
    var peripheralManager: CBPeripheralManager!
    
    // Combine
    var connectedSubscriber: AnyCancellable?
    var rssiTimer: AnyCancellable?
    var foundSubscriber: AnyCancellable?
    var detectingCancellable: AnyCancellable?
    var idCancellable: AnyCancellable?
    
    // Helpers
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    let defaults = UserDefaults.standard
    var idHelper = IdentificationHelper()
    
    #if !os(watchOS)
    var keyValStore = NSUbiquitousKeyValueStore()
    private var haptics = Haptics()
    #endif
    
    override init() {
        
        super.init()
        self.myID = idHelper.myID
        
        idCancellable = idHelper.$myID
            .receive(on: RunLoop.main)
            .assign(to: \.myID, on: self)
        
        connectedSubscriber = $connectedPeriperhals
            .receive(on: RunLoop.main)
            .sink(receiveValue: { connectors in
                connectors.count > 0 ? self.startTimer() : self.stopTimer()

            })
        
        #if !os(watchOS)
        if let savedData = keyValStore.object(forKey: "interactions") as? Data {
            if let loadedData = try? decoder.decode([PersonModel].self, from: savedData) {
                self.savedParticipants = loadedData
            }
        }
        #endif
        
        if savedParticipants.isEmpty {
            if let savedData = defaults.object(forKey: "interactions") as? Data {
                if let loadedData = try? decoder.decode([PersonModel].self, from: savedData) {
                    self.savedParticipants = loadedData
                }
            }
        }
        
        self.isDetecting = true
        
        detectingCancellable = $isDetecting
        .receive(on: RunLoop.main)
        .sink(receiveValue: { detecting in
            detecting ? self.start() : self.stop()
        })
        
        foundSubscriber = $personFound
            .receive(on: RunLoop.main)
            .sink(receiveValue: { found in
                #if !os(watchOS)
                if found {
                    self.haptics.intenseDetection()
                } else {
                    self.haptics.cancelHaptics()
                }
                #endif
            })
    }
    
    // MARK: Parent BLE Functions
    private func start() {
        #if !os(watchOS)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        #endif
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    private func stop() {
        _ = self.connectedPeriperhals.compactMap{ self.centralManager.cancelPeripheralConnection($0) }
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
            self.save(participant: newParticipant)
        }
    }
    
    func peerDisconnected(peerID: String, bleID: String) {
        guard self.activeParticipants.contains(where: { $0.personUUID == peerID }) else { return }
        if let participant = self.activeParticipants.first(where: { $0.personUUID == peerID }) {
            self.update(participant: participant)
            DispatchQueue.main.async {
                self.connectedPeriperhals.removeAll(where: { $0.identifier.uuidString == bleID })
                self.activeParticipants.removeAll(where: { $0.personUUID == peerID })
            }
            print("Disconnected from", peerID)
        }
    }
    
    func save(participant: PersonModel) {
        self.savedParticipants.append(participant)
        self.saveToDisk()
    }
    
    func update(participant: PersonModel) {
        if let personIndex = self.savedParticipants.firstIndex(where: { $0.personUUID == participant.personUUID }) {
            self.savedParticipants[personIndex].disconnectTime = Date().timeIntervalSince1970
            self.saveToDisk()
        }
    }
    
    func saveToDisk() {
        if let encoded = try? encoder.encode(self.savedParticipants) {
            defaults.set(encoded, forKey: "interactions")
            #if !os(watchOS)
            keyValStore.set(encoded, forKey: "interactions")
            keyValStore.synchronize()
            #endif
        }
    }
}

extension PersonDetectee: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        #if !os(watchOS)
        
        // Start advertising
        var advertiseData = [String: Any]()
        advertiseData["kCBAdvDataTimestamp"] = Date().timeIntervalSinceReferenceDate
        advertiseData["kCBAdvDataLocalName"] = "further_app"
        //advertiseData["kCBAdvDataIsConnectable"] = 1
        advertiseData["kCBAdvDataServiceUUIDs"] = [CBUUID(string: "0xFD6F"), CBUUID(string: self.myID)]
        peripheralManager.startAdvertising(advertiseData)
        
        #endif
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
        guard localName.contains("further_app") else { return }
        guard !connectedPeriperhals.contains(where: { $0.identifier == peripheral.identifier }) else { return }
        
        if let serviceUUID = advertisementData["kCBAdvDataServiceUUIDs"] as? [CBUUID] {
            guard serviceUUID.contains(where: { $0.uuidString == "FD6F" }) else {
                print("Could not find proper service")
                return
            }
            if let userID = serviceUUID.first(where: { $0 != CBUUID(string: "0xFD6F" )}) {
                let foundUUID = userID.uuidString
                print("FOUND UUID:", foundUUID)
//                guard foundUUID != myID else {
//                    print("The found ID matches your ID.  No need to continue.")
//                    return
//                }
                let foundPerson = peripheral
                foundPerson.delegate = self
                foundPerson.discoverServices([])
                centralManager.registerForConnectionEvents(options: [.peripheralUUIDs: [peripheral.identifier]])
                connectedPeriperhals.append(peripheral)
                self.peerConnected(peerID: foundUUID, bleID: peripheral.identifier.uuidString)
                centralManager.connect(foundPerson)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        //
    }
    
    func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral) {
        //
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
        //
    }
    
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        //
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        //
    }
    
    private func characteristicText(characteristic: CBCharacteristic) -> String? {
        guard let data = characteristic.value else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        guard peripheral.state == .connected else { return }
        print("RSSI:", RSSI, "ID:", peripheral.identifier, peripheral.state.rawValue)
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
