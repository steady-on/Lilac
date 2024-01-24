//
//  KeychainStorage.swift
//  Lilac
//
//  Created by Roen White on 1/24/24.
//

import Foundation

@propertyWrapper
struct KeychainStorage {
    private let itemType: ItemType
    
    init(itemType: ItemType) {
        self.itemType = itemType
    }
    
    private let keychainManager = KeychainManager.shared
    
    var wrappedValue: String? {
        get {
            guard let value = try? keychainManager.search(itemType) else {
                return nil
            }
            return value
        }
        set {
            guard let newValue else {
                try? keychainManager.delete(itemType)
                return
            }
            try? keychainManager.save(.init(type: itemType, value: newValue))
        }
    }
}
