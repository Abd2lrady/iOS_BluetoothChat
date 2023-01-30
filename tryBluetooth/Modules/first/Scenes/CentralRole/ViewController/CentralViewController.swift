//
//  CentralViewController.swift
//  tryBluetooth
//
//  Created by TWIAbdulrady
//

import UIKit

class CentralViewController: UIViewController {

    @IBOutlet weak var connectionStatusLabel: UILabel!
    @IBOutlet weak var chatTextField: UITextField!
    
    var bleCentralManager: BLECentralManager?
    var chatPeripheral: BLEPeripheral?

    override func viewDidLoad() {
        super.viewDidLoad()
        configCentralManager()
    }

    func configCentralManager() {
        
        bleCentralManager = BLECentralManager.shared

        bleCentralManager?.checkPowerStatus { status in
            if status == .poweredOn {
                print("powerOn from view controller")
                self.bleCentralManager?
                    .scan(for: Constants.BluetoothUUID.chatServiceUUID) { [weak self] peripheral in
                    self?.chatPeripheral = BLEPeripheral(peripheral: peripheral)
                        self?.bleCentralManager?.connect(to: peripheral, connectCompletion: { result in
                            switch result {
                            case .success:
                                self?.connectionStatusLabel.text = "Good"
                                self?.discoverChatService(uuid: Constants.BluetoothUUID.chatServiceUUID)
                            case .failure:
                                self?.connectionStatusLabel.text = "Bad"
                            }
                        })
                    }
            }
        }
    }
    
    func discoverChatService(uuid: String) {
        chatPeripheral?.discoverServices(with: [uuid],
                                         serviceDiscoveredCompletion: { _ in
            self.chatPeripheral?.discoverCharacteristics(withUUIDs: [Constants.BluetoothUUID.chatCharactristicsUUID],
                                                         forUUID: Constants.BluetoothUUID.chatServiceUUID,
                                                         characteristicsDiscoveredCompletion: { _ in
                let msg = "Hello Central"
                guard let data = msg.data(using: .utf8) else { return }
                self.chatPeripheral?.writeValue(data: data,
                                                for: Constants.BluetoothUUID.chatCharactristicsUUID,
                                                withResponse: false)
            })
             
        })
        
    }
    
    func discoverChatCharactristics(uuid: String, service: String) {
        
    }
    
    @IBAction func dicoverCharacteristics(_ sender: Any) {
        discoverChatService(uuid: Constants.BluetoothUUID.chatServiceUUID)

//        discoverChatCharactristics(uuid: Constants.BluetoothUUID.chatCharactristicsUUID,
//                                   service: Constants.BluetoothUUID.chatServiceUUID)
    }
    @IBAction func sendButtonAction(_ sender: Any) {
                
        let msg = chatTextField.text ?? ""
        guard let data = msg.data(using: .utf8) else { return }
        chatPeripheral?.writeValue(data: data,
                                   for: Constants.BluetoothUUID.chatCharactristicsUUID,
                                   withResponse: false)
    }
    
    @IBAction func getLastMsgButtonAction(_ sender: Any) {
        
    }
    
}
