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
    
    
    func request(_ api: T) -> Completable {
        return Completable.create { completable in
            self.provider.request(api) { result in
                switch result {
                case .success(let response):
                    guard response.statusCode == 200 else {
                        let error = parseErrorData(response.data)
                        completable(.error(error))
                        return
                    }
                    
                    completable(.completed)
                case .failure(let moyaError):
                    completable(.error(moyaError))
                }
            }
            
            return Disposables.create()
        }
    }
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
