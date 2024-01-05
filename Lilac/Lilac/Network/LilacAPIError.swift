//
//  LilacAPIError.swift
//  Lilac
//
//  Created by Roen White on 1/6/24.
//

import Foundation

enum LilacAPIError {
    enum AuthError: String, Error {
        case failToAuthorization = "E02"
        case unknownAccount = "E03"
        case validToken = "E04"
        case expiredRefreshToken = "E06"
    }
}
