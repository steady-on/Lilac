//
//  KakaoLoginService.swift
//  Lilac
//
//  Created by Roen White on 1/15/24.
//

import Foundation
import RxSwift
import KakaoSDKAuth
import KakaoSDKUser
import RxKakaoSDKUser

final class KakaoLoginService {
    deinit {
        print("deinit KakaoLoginService")
    }
    
    private let userApi = UserApi.shared
    
    func kakaoLogin() -> Observable<OAuthToken> {
        // 카카오톡 설치 확인
        guard UserApi.isKakaoTalkLoginAvailable() else {
            // 브라우저를 통해 로그인
            return userApi.rx.loginWithKakaoAccount()
        }
        
        return userApi.rx.loginWithKakaoTalk()
    }
}
