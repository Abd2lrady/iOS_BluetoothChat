//
//  BLEPeripheralManager.swift
//  tryBluetooth
//
//  Created by TWIAbdulrady
//

import Foundation
import CoreBluetooth

class BLEPeripheralManager: NSObject {
// MARK: - Properties
    var peripheral: CBPeripheral?
    var central: CBCentral?

// MARK: - callbacks
    
// MARK: - Operations
    
}

extension BLEPeripheralManager: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
         
    }
    
}
