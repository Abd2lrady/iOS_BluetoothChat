//
//  PeripheralViewController.swift
//  tryBluetooth
//
//  Created by TWIAbdulrady
//

import UIKit

class PeripheralViewController: UIViewController {
    
    @IBOutlet weak var chatTextField: UITextField!
    @IBOutlet weak var dataLabel: UILabel!
    
    var blePeripheralManager: BLEPeripheralManager?


    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Peripheral"
        configPeripheralManager()
    }
    
    func configPeripheralManager() {
        
        blePeripheralManager = BLEPeripheralManager.shared
        
        blePeripheralManager?.checkPowerStatus(checkPowerStatusCompletion: { [weak self] state in
            
            if (state == .poweredOn) {
                print("hello peri")
                
                let service = Service(uuid: Constants.BluetoothUUID.chatServiceUUID,
                                      primary: true,
                                      characteristics: [
                                        Characteristic(uuid: Constants.BluetoothUUID.chatCharactristicsUUID,
                                                       value: nil,
                                                       permissions: [.readable, .writeable],
                                                       properties: [.read, .notify, .writeWithoutResponse])])
                                
                self?.blePeripheralManager?.addService(service: service)
                self?.blePeripheralManager?.startAdvertising(uuid: Constants.BluetoothUUID.chatServiceUUID,
                                                             localName: "hello peripheral xcode")
            }
        })
        
        blePeripheralManager?.didReceiveWriteRequests = {[weak self] requests in
            if let data = requests?.first?.value {
                self?.dataLabel.text = String(data: data, encoding: .utf8)
            }
        }
        
        blePeripheralManager?.didReceiveReadRequest = { [weak self] request in
            guard let msg = self?.dataLabel.text else { return }
            let data = msg.data(using: .utf8)
            request.value = data
        }
        
    }
    
    @IBAction func sendButtonAction(_ sender: Any) {
        chatTextField.resignFirstResponder()
        guard let msg = chatTextField.text, !msg.isEmpty else { return }
        guard let data = msg.data(using: .utf8) else { return }
        
        blePeripheralManager?.writeOn(data: data,
                                      on: Constants.BluetoothUUID.chatCharactristicsUUID,
                                      for: Constants.BluetoothUUID.chatServiceUUID)
    }
    
}
