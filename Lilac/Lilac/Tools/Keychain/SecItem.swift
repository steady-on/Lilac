//
//  SecItem.swift
//  Lilac
//
//  Created by Roen White on 1/8/24.
//

import Foundation

struct SecItem {
    let type: ItemType
    let value: String
}

enum ItemType: String {
    case accessToken
    case refreshToken
}
