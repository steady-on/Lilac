//
//  AuthServiceImpl.swift
//  Lilac
//
//  Created by Roen White on 1/24/24.
//

import Foundation
import RxSwift

final class AuthServiceImpl: AuthService {
    static let shared = AuthServiceImpl()
    
    private init() {}
    
    private let repository = LilacRepository<LilacAPI.Auth>()
    
    func refreshAccessToken() -> Single<Result<Responder.Auth.TokenRefresh, Error>> {
        return repository.request(.refresh, responder: Responder.Auth.TokenRefresh.self)
    }
}
