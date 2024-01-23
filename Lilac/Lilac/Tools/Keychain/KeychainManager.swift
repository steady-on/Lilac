//
//  KeychainManager.swift
//  Lilac
//
//  Created by Roen White on 1/8/24.
//

import Foundation
import Security

final class KeychainManager {
    static let shared = KeychainManager()
    private init() {}
    
    private let server = BaseURL.server
    
    func save(_ item: SecItem) throws {
        guard let data = item.value.data(using: String.Encoding.utf8) else {
            throw KeychainError.failToEncodingData
        }
        
        let query: NSDictionary = [
            kSecClass : kSecClassInternetPassword,
            kSecAttrServer : server,
            kSecAttrLabel : item.type.rawValue,
            kSecValueData : data
        ]
        
        SecItemDelete(query)
        
        let status = SecItemAdd(query, nil)
        guard status == errSecSuccess else {
            throw KeychainError.failToAddItemError(itemType: item.type.rawValue)
        }
    }
    
    func search(_ itemType: ItemType) throws -> String {
        let query: NSDictionary = [
            kSecClass : kSecClassInternetPassword,
            kSecAttrServer : server,
            kSecAttrLabel : itemType.rawValue,
            kSecMatchLimit : kSecMatchLimitOne,
            kSecReturnData : true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query, &item)
        guard status != errSecItemNotFound else {
            throw KeychainError.noItem(itemType: itemType.rawValue)
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
        
        guard let valueData = item as? Data,
              let value = String(data: valueData, encoding: String.Encoding.utf8)
        else {
            throw KeychainError.unexpectedItemData(status: status)
        }
        
        return value
    }
    
    func delete(_ itemType: ItemType) throws {
        let query: NSDictionary = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: server,
            kSecAttrLabel as String: itemType.rawValue
        ]
        
        let status = SecItemDelete(query)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status: status)
        }
    }
}
