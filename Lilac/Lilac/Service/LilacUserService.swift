//
//  LilacUserService.swift
//  Lilac
//
//  Created by Roen White on 1/15/24.
//

import Foundation
import RxSwift

final class LilacUserService {
    
    deinit {
        print("deinit LilacUserService")
    }
    
    private lazy var lilacAPIUserManager = LilacAPIManager<LilacAPI.User>()
    
    func kakaoLogin(for accessToken: String) -> Single<Result<Responder.SignInWithVendor, Error>> {
        return lilacAPIUserManager.request(.signIn(vendor: .kakao(accessToken: accessToken)), responder: Responder.SignInWithVendor.self)
    }
    
    func emailLogin(email: String, password: String) -> Single<Result<Responder.SignIn, Error>> {
        return lilacAPIUserManager.request(.signIn(vendor: .email(email: email, password: password)), responder: Responder.SignIn.self)
    }
    
    func checkEmailDuplicated(email: String) -> Single<Result<Void, Error>> {
        return lilacAPIUserManager.request(.validateEmail(email: email))
    }
    
    func signUp(for newUser: Requester.NewUser) -> Single<Result<Responder.SignUp, Error>> {
        return lilacAPIUserManager.request(.signUp(userInfo: newUser), responder: Responder.SignUp.self)
    }
}
