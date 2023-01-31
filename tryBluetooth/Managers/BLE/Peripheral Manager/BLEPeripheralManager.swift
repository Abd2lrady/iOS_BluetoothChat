//
//  BLEPeripheralManager.swift
//  tryBluetooth
//
//  Created by TWIAbdulrady
//

import Foundation
import CoreBluetooth

class BLEPeripheralManager: NSObject {
    
    static let shared: BLEPeripheralManager = {
        let instance = BLEPeripheralManager()
        instance.peripheralManager = CBPeripheralManager(delegate: instance, queue: nil)
        return instance
        }()
    
// MARK: - Properties
    private var peripheralManager: CBPeripheralManager?
    private var localName: String?
    
    private override init() {    }

// MARK: - callbacks
    private var checkPowerStatusCompletion: ((CBManagerState) -> Void)?
    private var discoverCompletion: ((CBPeripheral) -> Void)?
    private var connectCompletion: ((Result<CBPeripheral, Error>) -> Void)?
    var didReceiveWriteRequests: (([CBATTRequest]?) -> Void)?
    var didReceiveReadRequest: ((CBATTRequest) -> Void)?

// MARK: - Peripheral Operations
    func setLocalName(name: String) {
        localName = name
    }
    
    func addService(service: Service) {
        let cbuuid = CBUUID(string: service.uuid)
        let characteristics: [CBMutableCharacteristic] = service.characteristics.map {
            CBMutableCharacteristic(type: CBUUID(string: $0.uuid),
                                    properties: $0.properties,
                                    value: $0.value,
                                    permissions: $0.permissions)
        }
        
        let service = CBMutableService(type: cbuuid, primary: service.primary)
        service.characteristics = characteristics
        peripheralManager?.add(service)
    }
        
    func checkPowerStatus(checkPowerStatusCompletion: @escaping ((CBManagerState) -> Void)) {
        self.checkPowerStatusCompletion = checkPowerStatusCompletion
    }
    
    func startAdvertising(uuid: String, localName: String) {
        let cbuuid = CBUUID(string: uuid)
        let advertisingData: [String: Any] = [CBAdvertisementDataServiceUUIDsKey: [cbuuid],
                                                 CBAdvertisementDataLocalNameKey: localName]
        peripheralManager?.startAdvertising(advertisingData)
    }
    
    func stopAdvertisment() {
        peripheralManager?.stopAdvertising()
    }
    
    func removeService(uuid: String, pirmary: Bool) {
        let cbuuid = CBUUID(string: uuid)
        let service = CBMutableService(type: cbuuid, primary: pirmary)
        peripheralManager?.remove(service)
    }
}

// MARK: - Peripheral Delegate
extension BLEPeripheralManager: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        checkPowerStatusCompletion?(peripheral.state)
    }
        
    func peripheralManager(_ peripheral: CBPeripheralManager,
                           didReceiveRead request: CBATTRequest) {
        didReceiveReadRequest?(request)
        peripheral.respond(to: request, withResult: .success)
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager,
                           didReceiveWrite requests: [CBATTRequest]) {
        didReceiveWriteRequests?(requests)
    }
}

struct Service {
    let uuid: String
    let primary: Bool
    let characteristics: [Characteristic]
}

struct Characteristic {
    let uuid: String
    let value: Data?
    let permissions: CBAttributePermissions
    let properties: CBCharacteristicProperties
}
