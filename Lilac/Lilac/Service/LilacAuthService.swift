//
//  LilacAuthService.swift
//  Lilac
//
//  Created by Roen White on 1/24/24.
//

import Foundation
import RxSwift

final class LilacAuthService {
    static let shared = LilacAuthService()
    
    private init() {}
    
    @KeychainStorage(itemType: .accessToken) private var accessToken
    @KeychainStorage(itemType: .refreshToken) private var refreshToken
    
    func refreshAccessToken() -> Single<Result<Responder.Auth.TokenRefresh, Error>> {
        return LilacAPIManager<LilacAPI.Auth>().request(.refresh, responder: Responder.Auth.TokenRefresh.self)
    }
}
