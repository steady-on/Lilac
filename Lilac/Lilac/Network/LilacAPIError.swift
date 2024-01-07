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

extension LilacAPIError: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .accessDenied:
            return "접근 권한이 없습니다."
        case .failToAuthorization:
            return "인증에 실패했습니다."
        case .unknownedAccount:
            return "존재하지 않는 계정입니다."
        case .validToken:
            return "AccessToken이 만료되지 않았습니다."
        case .expiredAccessToken:
            return "AccessTokne이 만료되었습니다."
        case .expiredRefreshToken:
            return "RefreshToken이 만료되었습니다."
        case .badRequest:
            return "잘못된 요청입니다."
        case .duplicatedData:
            return "이미 존재하는 데이터 입니다."
        case .unknownedRoutePath:
            return "잘못된 요청경로 입니다."
        case .overCall:
            return "과호출 입니다."
        case .serverError:
            return "내부 서버에 오류가 있습니다."
        }
    }
}
