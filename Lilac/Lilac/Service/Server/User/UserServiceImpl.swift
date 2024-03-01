//
//  UserServiceImpl.swift
//  Lilac
//
//  Created by Roen White on 1/15/24.
//

import Foundation
import RxSwift

final class UserServiceImpl: UserService {
    
    deinit {
        print("deinit UserService")
    }
    
    private let repository = LilacRepository<LilacAPI.User>()
    
    @KeychainStorage(itemType: .refreshToken) var refreshToken
    @KeychainStorage(itemType: .accessToken) var accessToken
    @UserDefault(key: .deviceToken, defaultValue: "") var deviceToken
    
    func signUp(for newUser: Requester.NewUser) -> Single<Result<Responder.User.ProfileWithToken, Error>> {
        return repository.request(.signUp(userInfo: newUser, deviceToken: deviceToken), responder: Responder.User.ProfileWithToken.self)
    }
    
    func checkEmailDuplicated(email: String) -> Single<Result<Void, Error>> {
        return repository.request(.validateEmail(email: email))
    }
    
    func emailLogin(email: String, password: String) -> Single<Result<Responder.User.SimpleProfileWithToken, Error>> {
        return repository.request(.signIn(vendor: .email(email: email, password: password), deviceToken: deviceToken), responder: Responder.User.SimpleProfileWithToken.self)
    }
    
    func kakaoLogin(for accessToken: String) -> Single<Result<Responder.User.ProfileWithToken, Error>> {
        return repository.request(.signIn(vendor: .kakao(accessToken: accessToken), deviceToken: deviceToken), responder: Responder.User.ProfileWithToken.self)
    }
    
    func signOut() -> Single<Result<Void, Error>> {
        refreshToken = nil
        accessToken = nil
        return repository.request(.signOut)
    }
    
    func saveDeviceToken() -> Single<Result<Void, Error>> {
        return repository.request(.saveDeviceToken(deviceToken: deviceToken))
    }
    
    func loadMyProfile() -> Single<Result<Responder.User.MyProfile, Error>> {
        return repository.request(.myProfile(type: .load), responder: Responder.User.MyProfile.self)
    }
    
    func updateProfileInfo(nickname: String?, phone: String?) -> Single<Result<Responder.User.MyProfile, Error>> {
        return repository.request(.myProfile(type: .updateInfo(nickname: nickname, phone: phone)), responder: Responder.User.MyProfile.self)
    }
    
    func loadOtherUserProfile(id: Int) -> Single<Result<Responder.User.UserProfile, Error>> {
        return repository.request(.otherUserProfile(id: id), responder: Responder.User.UserProfile.self)
    }
}
