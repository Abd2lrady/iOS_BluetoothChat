//
//  Configuration.swift
//  tryBluetooth
//
//  Created by TWIAbdulrady
//

import Foundation

enum Configuration: String {
    
    case debug
    case release
    
    private enum PlistKeys {
        static let environment = "Environment"
    }
    
    private static let infoDict: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist not found")
        }
        return dict
    }()
    
    static let current: Configuration = {
        guard let rawValue = infoDict[PlistKeys.environment] as? String else {
            fatalError("environment not found")
        }
        guard let configuration = Configuration(rawValue: rawValue) else {
            fatalError("not valid configuration")
        }
        return configuration
    }()
}
