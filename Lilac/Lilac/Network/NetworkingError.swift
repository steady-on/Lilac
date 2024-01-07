//
//  NetworkingError.swift
//  Lilac
//
//  Created by Roen White on 1/7/24.
//

import Foundation

enum NetworkingError: Error {
    case jsonParsingError
    case unknown
}

extension NetworkingError: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .jsonParsingError:
            return "서버 응답값 변환에 실패했습니다."
        case .unknown:
            return "알 수 없는 에러"
        }
    }
}
