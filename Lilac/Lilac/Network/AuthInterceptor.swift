//
//  AuthInterceptor.swift
//  Lilac
//
//  Created by Roen White on 1/24/24.
//

import Foundation
import Alamofire

final class AuthInterceptor {
    static let shared = AuthInterceptor()
    
    private init() {}
    
    @KeychainStorage(itemType: .accessToken) private var accessToken
    @KeychainStorage(itemType: .refreshToken) private var refreshToken
}

extension AuthInterceptor: RequestInterceptor {
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {

        var urlRequest = urlRequest
        urlRequest.setValue(APIKey.secretKey, forHTTPHeaderField: "SesacKey")
        
        guard urlRequest.url?.lastPathComponent != LilacAPI.Auth.refresh.rawValue else {
            let urlRequestWithRefreshToken = addRefreshToken(to: urlRequest)
            completion(.success(urlRequestWithRefreshToken))
            return
        }
        
        let urlRequestWithAccessToken = addAccessToken(to: urlRequest)
        completion(.success(urlRequestWithAccessToken))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request as? DataRequest,
              let data = response.data,
              let serverError = parseErrorData(data) else {
            completion(.doNotRetryWithError(error))
            return
        }

        guard case LilacAPIError.expiredAccessToken = serverError else {
            completion(.doNotRetry)
            return
        }
        
        let refreshResponse = LilacAuthService.shared.refreshAccessToken()
        
        refreshResponse
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let newToken):
                    owner.accessToken = newToken.accessToken
                    completion(.retry)
                case .failure(_):
                    completion(.doNotRetry)
                }
            } onFailure: { owner, error in
                completion(.doNotRetry)
            }
            .dispose()
    }
}

extension AuthInterceptor {
    private func parseErrorData(_ data: Data) -> Error? {
        let decoder = JSONDecoder()
        
        guard let decodedData = try? decoder.decode(Responder.Error.self, from: data),
              let lilacError = LilacAPIError(rawValue: decodedData.errorCode) else {
            return nil
        }
        
        return lilacError
    }
    
    private func addRefreshToken(to urlRequest: URLRequest) -> URLRequest {
        guard let refreshToken else {
            return urlRequest
        }
        
        var urlRequest = urlRequest
        urlRequest.setValue(refreshToken, forHTTPHeaderField: "RefreshToken")
        
        return urlRequest
    }
    
    private func addAccessToken(to urlRequest: URLRequest) -> URLRequest {
        guard let accessToken else {
            return urlRequest
        }
        
        var urlRequest = urlRequest
        urlRequest.setValue(accessToken, forHTTPHeaderField: "Authorization")
        
        return urlRequest
    }
}
