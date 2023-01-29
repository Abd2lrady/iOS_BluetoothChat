//
//  CentralManager.swift
//  tryBluetooth
//
//  Created by TWIAbdulrady .
//

import CoreBluetooth
import CoreText

class BLECentralManager: NSObject {
    
// MARK: - Properties
    var centralManager: CBCentralManager?
    var peripherals: [CBPeripheral]?

// MARK: - callbacks
    var statusUpdated: ((CBManagerState) -> Void)?
    private var discoverCompletion: ((CBPeripheral) -> Void)?
    private var connectCompletion: ((Result<CBPeripheral, Error>) -> Void)?
    
// MARK: - Central Operations
    func scan(for uuid: String?,
              discoverCompletion: @escaping ((CBPeripheral) -> Void)) {
        
        guard centralManager?.state == .poweredOn
        else { return }
        
        self.discoverCompletion = discoverCompletion
        
        print("scan started")
        
        var cbUUID: CBUUID?
        
        if let uuid = uuid {
            cbUUID = CBUUID(string: uuid)
        }
        
        if let cbUUID = cbUUID {
            centralManager?.scanForPeripherals(withServices: [cbUUID])
        } else {
            centralManager?.scanForPeripherals(withServices: nil)
        }
    }
    
    func connect(to peripheral: CBPeripheral,
                 connectCompletion: @escaping ((Result<CBPeripheral, Error>) -> Void)) {
        centralManager?.connect(peripheral)
        self.connectCompletion = connectCompletion
    }
}

// MARK: - Central Delegate
extension BLECentralManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        statusUpdated?(central.state)
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any],
                        rssi RSSI: NSNumber) {
        peripherals?.append(peripheral)
        discoverCompletion?(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        connectCompletion?(.success(peripheral))
    }
    
    func centralManager(_ central: CBCentralManager,
                        didFailToConnect peripheral: CBPeripheral,
                        error: Error?) {
        connectCompletion?(.failure(error ?? NSError(domain: "connection failure",
                                                     code: 0)))
    }
}
