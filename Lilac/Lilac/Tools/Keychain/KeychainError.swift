//
//  KeychainError.swift
//  Lilac
//
//  Created by Roen White on 1/8/24.
//

import Foundation

enum KeychainError: Error {
    case failToAddItemError(itemType: String)
    case noItem(itemType: String)
    case failToSearchItemError(itemType: String)
    case unexpectedItemData(status: OSStatus)
    case unhandledError(status: OSStatus)
    case failToEncodingData
}
