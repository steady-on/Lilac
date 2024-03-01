//
//  UserService.swift
//  Lilac
//
//  Created by Roen White on 2/26/24.
//

import Foundation
import RxSwift

protocol UserService: AnyObject {
    /// 회원가입
    func signUp(for newUser: Requester.NewUser) -> Single<Result<Responder.User.ProfileWithToken, Error>>
    
    /// 이메일 중복 확인
    func checkEmailDuplicated(email: String) -> Single<Result<Void, Error>>
    
    /// 이메일 로그인
    func emailLogin(email: String, password: String) -> Single<Result<Responder.User.SimpleProfileWithToken, Error>>
    
    /// 카카오 로그인
    func kakaoLogin(for accessToken: String) -> Single<Result<Responder.User.ProfileWithToken, Error>>
    
    /// 애플 로그인
//    func appleLogin
    
    /// 로그아웃
    func signOut() -> Single<Result<Void, Error>>
    
    /// FCM deviceToken 저장
    func saveDeviceToken() -> Single<Result<Void, Error>>
    
    /// 내 프로필 정보 조회
    func loadMyProfile() -> Single<Result<Responder.User.MyProfile, Error>>
    
    /// 내 프로필 정보 수정(이미지 제외)
    func updateProfileInfo(nickname: String?, phone: String?) -> Single<Result<Responder.User.MyProfile, Error>>
    
    /// 내 프로필 이미지 수정
//    func updateProfileImage
    
    /// 다른 유저 프로필 조회
    func loadOtherUserProfile(id: Int) -> Single<Result<Responder.User.UserProfile, Error>>
}
