//
//  LilacUserService.swift
//  Lilac
//
//  Created by Roen White on 1/15/24.
//

import Foundation
import RxSwift

final class LilacUserService {
    
    func kakaoLogin(for accessToken: String) -> Single<Result<Responder.SignInWithVendor, Error>> {
        return LilacAPIManager<LilacAPI.User>().request(.signIn(vendor: .kakao(accessToken: accessToken)), responder: Responder.SignInWithVendor.self)
    }
    
}
