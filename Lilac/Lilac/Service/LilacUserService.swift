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
    
    private let lilacAPIUserRepository = LilacRepository<LilacAPI.User>()
    
    @KeychainStorage(itemType: .refreshToken) var refreshToken
    @KeychainStorage(itemType: .accessToken) var accessToken
    
    func signUp(for newUser: Requester.NewUser) -> Single<Result<Responder.User.ProfileWithToken, Error>> {
        return lilacAPIUserRepository.request(.signUp(userInfo: newUser), responder: Responder.User.ProfileWithToken.self)
    }
    
    func checkEmailDuplicated(email: String) -> Single<Result<Void, Error>> {
        return lilacAPIUserRepository.request(.validateEmail(email: email))
    }
    
    func kakaoLogin(for accessToken: String) -> Single<Result<Responder.User.ProfileWithToken, Error>> {
        return lilacAPIUserRepository.request(.signIn(vendor: .kakao(accessToken: accessToken)), responder: Responder.User.ProfileWithToken.self)
    }
    
    func emailLogin(email: String, password: String) -> Single<Result<Responder.User.SimpleProfileWithToken, Error>> {
        return lilacAPIUserRepository.request(.signIn(vendor: .email(email: email, password: password)), responder: Responder.User.SimpleProfileWithToken.self)
    }
    
    func signOut() -> Single<Result<Void, Error>> {
        refreshToken = nil
        accessToken = nil
        return lilacAPIUserRepository.request(.signOut)
    }
}
