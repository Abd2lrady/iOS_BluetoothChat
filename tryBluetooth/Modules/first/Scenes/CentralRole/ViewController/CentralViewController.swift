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
    @IBOutlet weak var lastMsgLabel: UILabel!
    
    var bleCentralManager: BLECentralManager?
    var chatPeripheral: BLEPeripheral?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configCentralManager()
    }
    
    func configCentralManager() {
        
        bleCentralManager = BLECentralManager.shared
        
        bleCentralManager?.checkPowerStatus { [weak self] status in
            if status == .poweredOn {
                print("powerOn from view controller")
                self?.scanPeripherals(withService: Constants.BluetoothUUID.chatServiceUUID)
            }
        }
    }
    
    func scanPeripherals(withService uuid: String?) {
        self.bleCentralManager?
            .scan(for: uuid) { [weak self] peripheral in
                self?.chatPeripheral = BLEPeripheral(peripheral: peripheral)
                self?.connect(to: self?.chatPeripheral)
            }
    }
    
    func connect(to peripheral: BLEPeripheral?) {
        
        guard let peripheral = peripheral else { return }
        
        bleCentralManager?.connect(to: peripheral.peripheral, connectCompletion: { [weak self] result in
            switch result {
            case .success:
                self?.connectionStatusLabel.text = "Good"
                self?.discoverChatService(uuid: Constants.BluetoothUUID.chatServiceUUID)
            case .failure:
                self?.connectionStatusLabel.text = "Bad"
            }
        })
    }
    
    func discoverChatService(uuid: String) {
        chatPeripheral?.discoverServices(with: [uuid],
                                         serviceDiscoveredCompletion: { [weak self] _ in
            
            self?.discoverChatCharactristics(uuid: Constants.BluetoothUUID.chatCharactristicsUUID,
                                             service: uuid)
        })
        
    }
    
    func discoverChatCharactristics(uuid: String, service: String) {
        self.chatPeripheral?.discoverCharacteristics(withUUIDs: [Constants.BluetoothUUID.chatCharactristicsUUID],
                                                     forUUID: Constants.BluetoothUUID.chatServiceUUID,
                                                     characteristicsDiscoveredCompletion: { [weak self] _ in
            let msg = "Hello Central"
            guard let data = msg.data(using: .utf8) else { return }
            self?.chatPeripheral?.writeValue(data: data,
                                             for: Constants.BluetoothUUID.chatCharactristicsUUID,
                                             withResponse: false)
        })
    }
    
    @IBAction func connectCharacteristics(_ sender: Any) {
        
        guard let peripheral = chatPeripheral?.peripheral else { return }
        
        bleCentralManager?.connect(to: peripheral, connectCompletion: { [weak self] result in
            switch result {
            case .success:
                self?.connectionStatusLabel.text = "Good"
                self?.discoverChatService(uuid: Constants.BluetoothUUID.chatServiceUUID)
            case .failure:
                self?.connectionStatusLabel.text = "Bad"
            }
        })
    }
    
    @IBAction func sendButtonAction(_ sender: Any) {
        
        guard let msg = chatTextField.text, !msg.isEmpty else { return }
        guard let data = msg.data(using: .utf8) else { return }
        
        chatPeripheral?.writeValue(data: data,
                                   for: Constants.BluetoothUUID.chatCharactristicsUUID,
                                   withResponse: false)
        chatTextField.resignFirstResponder()
    }
    
    @IBAction func getLastMsgButtonAction(_ sender: Any) {
        chatPeripheral?.readValue(for: Constants.BluetoothUUID.chatCharactristicsUUID,
                                  readValueCompletion: { [weak self] data in
            guard let data = data else { return }
            let msg = String(data: data, encoding: .utf8)
            self?.lastMsgLabel.text = msg
        })
    }
}
