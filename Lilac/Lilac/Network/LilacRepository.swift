//
//  LilacAPIManager.swift
//  Lilac
//
//  Created by Roen White on 1/7/24.
//

import Foundation
import RxSwift
import Moya

struct LilacRepository<T: TargetType> {
    
    private let provider = MoyaProvider<T>(session: Session(interceptor: AuthInterceptor.shared))
    
    func request<U: Decodable>(_ api: T, responder: U.Type) -> Single<Result<U, Error>> {
        
        let decoder = setJSONDecoder()
        
        return Single<Result<U, Error>>.create { single in
            self.provider.request(api) { result in
                switch result {
                case .success(let response): 
                // TargetType에서 validationType을 successCode로 설정했기 때문에 statusCode 200인 경우만 success로 들어옴
                    do {
                        let decodedData = try response.map(U.self, using: decoder)
                        single(.success(.success(decodedData)))
                    } catch { // 디코딩 실패의 경우 catch로 넘어옴
                        print("Decoding Failure: ", error)
                        single(.failure(NetworkingError.jsonParsingError))
                    }

                case .failure(let failure):
                    let moyaError = failure as MoyaError
                    guard case .underlying = moyaError, let response = failure.response else {
                        print("Failure: ", failure.errorDescription ?? "")
                        single(.failure(NetworkingError.unknown))
                        return
                    }

                    do { // 서버에서 에러를 보냈을 때만
                        let errorResponse = try response.map(Responder.Error.self)
                        let lilacError = LilacAPIError(for: errorResponse.errorCode)
                        single(.success(.failure(lilacError)))
                    } catch { // 디코딩 실패의 경우
                        print("Decoding Failure: ", error)
                        single(.failure(NetworkingError.jsonParsingError))
                    }
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
                    
                case .failure(let failure):
                    let moyaError = failure as MoyaError
                    guard case .underlying = moyaError, let response = failure.response else {
                        print("Failure: ", failure.errorDescription ?? "")
                        single(.failure(NetworkingError.unknown))
                        return
                    }

                    do { // 서버에서 에러를 보냈을 때만
                        let errorResponse = try response.map(Responder.Error.self)
                        let lilacError = LilacAPIError(for: errorResponse.errorCode)
                        single(.success(.failure(lilacError)))
                    } catch { // 디코딩 실패의 경우
                        print("Decoding Failure: ", error)
                        single(.failure(NetworkingError.jsonParsingError))
                    }
                }
            }
            
            return Disposables.create()
        }
    }
}

extension LilacRepository {
    private func setDateFormat() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        return dateFormatter
    }
    
    private func setJSONDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .formatted(setDateFormat())
        return decoder
    }
}
