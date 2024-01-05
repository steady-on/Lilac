//
//  LilacAPIError.swift
//  Lilac
//
//  Created by Roen White on 1/6/24.
//

import Foundation

enum LilacAPIError: String, Error {
    case accessDenied = "E01"
    case failToAuthorization = "E02"
    case unknownedAccount = "E03"
    case validToken = "E04"
    case expiredAccessToken = "E05"
    case expiredRefreshToken = "E06"
    case badRequest = "E11"
    case duplicatedData = "E12"
    case unknownedRoutePath = "E97"
    case overCall = "E98"
    case serverError = "E99"
}
