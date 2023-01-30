//
//  BLEPeripheral.swift
//  tryBluetooth
//
//  Created by TWIAbdulrady
//

import Foundation
import CoreBluetooth

class BLEPeripheral: NSObject {
    // MARK: - Properties
    let peripheral: CBPeripheral
    
    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
        super.init()
        peripheral.delegate = self
    }
    // MARK: - callbacks
    var serviceDiscoveredCompletion: (([CBService]?) -> Void)?
    var characteristicsDiscoveredCompletion: (([CBCharacteristic]?) -> Void)?
    var readValueCompletion: ((Data?) -> Void)?

    // MARK: - Operations
    func discoverServices(with uuids: [String]?,
                          serviceDiscoveredCompletion: (([CBService]?) -> Void)?) {
        self.serviceDiscoveredCompletion = serviceDiscoveredCompletion
        guard let uuids = uuids
        else {
            peripheral.discoverServices(nil)
            return
        }
        let cbuuids = uuids.map { CBUUID(string: $0) }
        peripheral.discoverServices(cbuuids)
    }
    
    func discoverCharacteristics(with uuids: [String]?,
                                 for service: CBService,
                                 characteristicsDiscoveredCompletion: @escaping (([CBCharacteristic]?) -> Void)) {
        self.characteristicsDiscoveredCompletion = characteristicsDiscoveredCompletion
        guard let uuids = uuids
        else {
            peripheral.discoverCharacteristics(nil, for: service)
            return
        }
        
        let cbuuids = uuids.map { CBUUID(string: $0) }
        peripheral.discoverCharacteristics(cbuuids, for: service)
    }
    
    func readValue(for characteristics: CBCharacteristic,
                   readValueCompletion: @escaping ((Data?) -> Void)) {
        self.readValueCompletion = readValueCompletion
        peripheral.readValue(for: characteristics)
    }
    
//    func writeValue(for characteristics: CBCharacteristic,
//                    writeValueCompletion: @escaping ((Data?) -> Void)) {
//    }
    
}

// MARK: - Peripheral Delegate
extension BLEPeripheral: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverServices error: Error?) {
        serviceDiscoveredCompletion?(peripheral.services)
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        characteristicsDiscoveredCompletion?(service.characteristics)
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        readValueCompletion?(characteristic.value)
    }
}
