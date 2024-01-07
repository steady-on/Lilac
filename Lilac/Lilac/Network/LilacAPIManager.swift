//
//  LilacAPIManager.swift
//  Lilac
//
//  Created by Roen White on 1/7/24.
//

import Foundation
import RxSwift
import Moya

struct LilacAPIManager<T: TargetType> {
    
    private let provider = MoyaProvider<T>()
    
}

extension LilacAPIManager {
    private func parseErrorData(_ data: Data) -> Error {
        let decoder = JSONDecoder()
        
        guard let decodedData = try? decoder.decode(Responder.Error.self, from: data),
              let lilacError = LilacAPIError(rawValue: decodedData.errorCode) else {
            return NetworkingError.jsonParsingError
        }
        
        return lilacError
    }
}
