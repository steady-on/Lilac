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
    
    var wrappedValue: String? {
        get {
            guard let value = try? KeychainManager.shared.search(itemType) else {
                return nil
            }
            return value
        }
        set {
            guard let newValue else { return }
            try? KeychainManager.shared.save(.init(type: itemType, value: newValue))
        }
    }
}
