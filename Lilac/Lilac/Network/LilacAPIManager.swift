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
    
    private let provider = MoyaProvider<T>(session: Session(interceptor: AuthInterceptor.shared))
    
    func request<U: Decodable>(_ api: T, responder: U.Type) -> Single<Result<U, Error>> {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return Single<Result<U, Error>>.create { single in
            self.provider.request(api) { result in
                switch result {
                case .success(let response):
                    guard let decodedData = try? decoder.decode(U.self, from: response.data) else {
                        single(.success(.failure(NetworkingError.jsonParsingError)))
                        return
                    }
                    
                    single(.success(.success(decodedData)))
                case .failure(let moyaError):
                    guard let data = moyaError.response?.data,
                          let lilacError = parseErrorData(data) else {
                        single(.failure(moyaError))
                        return
                    }
                    
                    single(.success(.failure(lilacError)))
                }
            }
            
            return Disposables.create()
        }
    }
    
    func request(_ api: T) -> Single<Result<Void, Error>> {
        return Single<Result<Void, Error>>.create { single in
            self.provider.request(api) { result in
                switch result {
                case .success(_):
                    single(.success(.success(())))
                case .failure(let moyaError):
                    guard let data = moyaError.response?.data,
                          let lilacError = parseErrorData(data) else {
                        single(.failure(moyaError))
                        return
                    }
                    
                    single(.success(.failure(lilacError)))
                }
            }
            
            return Disposables.create()
        }
    }
}

extension LilacAPIManager {
    private func parseErrorData(_ data: Data) -> Error? {
        let decoder = JSONDecoder()
        
        guard let decodedData = try? decoder.decode(Responder.Error.self, from: data),
              let lilacError = LilacAPIError(rawValue: decodedData.errorCode) else {
            return nil
        }
        
        return lilacError
    }
}
