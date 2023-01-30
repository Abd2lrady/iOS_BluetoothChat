//
//  CentralManager.swift
//  tryBluetooth
//
//  Created by TWIAbdulrady .
//

import CoreBluetooth
import Foundation

class BLECentralManager: NSObject {
    
    static let shared: BLECentralManager = {
        let instance = BLECentralManager()
        instance.centralManager = CBCentralManager(delegate: instance, queue: nil)
        return instance
        }()
    
// MARK: - Properties
    private var centralManager: CBCentralManager?
    var peripherals: [CBPeripheral]?
    
    private override init() {    }

// MARK: - callbacks
    private var checkPowerStatusCompletion: ((CBManagerState) -> Void)?
    private var discoverCompletion: ((CBPeripheral) -> Void)?
    private var connectCompletion: ((Result<CBPeripheral, Error>) -> Void)?
    
// MARK: - Central Operations
    
    func checkPowerStatus(checkPowerStatusCompletion: @escaping ((CBManagerState) -> Void)) {
        self.checkPowerStatusCompletion = checkPowerStatusCompletion
    }
    
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
    
    func stopScan() {
        centralManager?.stopScan()
    }
}

// MARK: - Central Delegate
extension BLECentralManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        checkPowerStatusCompletion?(central.state)
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any],
                        rssi RSSI: NSNumber) {
        discoverCompletion?(peripheral)
        peripherals?.append(peripheral)
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
