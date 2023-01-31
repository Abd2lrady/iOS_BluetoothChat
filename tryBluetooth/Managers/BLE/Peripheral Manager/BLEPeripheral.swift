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
    private var services: [CBService]?
    private var characteristics: [CBCharacteristic]?
    
    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
        super.init()
        peripheral.delegate = self
    }
    // MARK: - callbacks
    private var serviceDiscoveredCompletion: (([CBService]?) -> Void)?
    private var characteristicsDiscoveredCompletion: (([CBCharacteristic]?) -> Void)?
    private var updateValueCompletion: ((Data?) -> Void)?

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
    
    func discoverCharacteristics(withUUIDs charUuids: [String]?,
                                 forUUID serviceUuid: String,
                                 characteristicsDiscoveredCompletion: @escaping (([CBCharacteristic]?) -> Void)) {
        self.characteristicsDiscoveredCompletion = characteristicsDiscoveredCompletion
        let serviceCBUuid = CBUUID(string: serviceUuid)

        guard let services = services else {
            return
        }

        var service: CBService?
        for ser in services {
            if ser.uuid == serviceCBUuid {
                service = ser
            }
        }
        
        guard let service = service else {
            return
        }

        guard let charUuids = charUuids
        else {
            peripheral.discoverCharacteristics(nil, for: service)
            return
        }
        let cbuuids = charUuids.map { CBUUID(string: $0) }
        peripheral.discoverCharacteristics(cbuuids, for: service)
    }
    
    func readValue(for characteristicUuid: String,
                   readValueCompletion: @escaping ((Data?) -> Void)) {
        
        guard let characteristics = characteristics else { return }
        let characteristisUuid = CBUUID(string: characteristicUuid)
        var characteristic: CBCharacteristic?
        
        for char in characteristics {
            if (char.uuid == characteristisUuid && char.properties.contains(.read)) {
                characteristic = char
                break
            }
        }
        
        guard let characteristic = characteristic else { return }

        peripheral.readValue(for: characteristic)
    }
    
    func writeValue(data: Data,
                    for characteristicUuid: String,
                    withResponse: Bool) {
        
        guard let characteristics = characteristics else { return }
        let characteristisUuid = CBUUID(string: characteristicUuid)
        var characteristic: CBCharacteristic?
        
        for char in characteristics {
            if (char.uuid == characteristisUuid) {
                characteristic = char
                break
            }
        }
        
        guard let characteristic = characteristic else { return }
        
        if (withResponse) {
            peripheral.writeValue(data, for: characteristic, type: .withResponse)
        } else {
            peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
        }
    }
    
    func notifyValue(for characteristicUuid: String,
                     updateValueCompletion: @escaping ((Data?) -> Void)) {
        
        guard let characteristics = characteristics else { return }
        let characteristisUuid = CBUUID(string: characteristicUuid)
        var characteristic: CBCharacteristic?
        
        for char in characteristics {
            if (char.uuid == characteristisUuid && char.properties.contains(.notify)) {
                characteristic = char
                break
            }
        }
        
        guard let characteristic = characteristic else { return }

        self.updateValueCompletion = updateValueCompletion
        peripheral.setNotifyValue(true, for: characteristic)
    }
    
}

// MARK: - Peripheral Delegate
extension BLEPeripheral: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverServices error: Error?) {
        services = peripheral.services
        serviceDiscoveredCompletion?(peripheral.services)
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        
        if let error = error {
            print(error)
        }
        self.characteristics = service.characteristics
        characteristicsDiscoveredCompletion?(service.characteristics)
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        updateValueCompletion?(characteristic.value)
    }
}
