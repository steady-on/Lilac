//
//  AuthService.swift
//  Lilac
//
//  Created by Roen White on 2/26/24.
//

import Foundation
import RxSwift

protocol AuthService: AnyObject {
    /// 토큰 갱신
    func refreshAccessToken() -> Single<Result<Responder.Auth.TokenRefresh, Error>>
}
