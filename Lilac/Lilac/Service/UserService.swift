//
//  UserService.swift
//  Lilac
//
//  Created by Roen White on 2/26/24.
//

import Foundation
import RxSwift

protocol UserService: AnyObject {
    func signUp(for newUser: Requester.NewUser) -> Single<Result<Responder.User.ProfileWithToken, Error>>
    func checkEmailDuplicated(email: String) -> Single<Result<Void, Error>>
    func kakaoLogin(for accessToken: String) -> Single<Result<Responder.User.ProfileWithToken, Error>>
    func emailLogin(email: String, password: String) -> Single<Result<Responder.User.SimpleProfileWithToken, Error>>
    func signOut() -> Single<Result<Void, Error>>
    func loadMyProfile() -> Single<Result<Responder.User.MyProfile, Error>>
    func updateProfileInfo(nickname: String?, phone: String?) -> Single<Result<Responder.User.MyProfile, Error>>
    func loadOtherUserProfile(id: Int) -> Single<Result<Responder.User.UserProfile, Error>>
}
