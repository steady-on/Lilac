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
    
    func refreshAccessToken() -> Single<Result<Responder.Auth.TokenRefresh, Error>> {
        return LilacRepository<LilacAPI.Auth>().request(.refresh, responder: Responder.Auth.TokenRefresh.self)
    }
}
