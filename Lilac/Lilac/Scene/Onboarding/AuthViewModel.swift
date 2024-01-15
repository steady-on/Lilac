//
//  AuthViewModel.swift
//  Lilac
//
//  Created by Roen White on 1/14/24.
//

import UIKit
import RxSwift
import RxCocoa

final class AuthViewModel {
    
    deinit {
        print("deinit AuthViewModel")
    }
    
    var disposeBag = DisposeBag()
    
    private lazy var kakaoLoginService = KakaoLoginService()
    private lazy var lilacUserService = LilacUserService()
    
    private func kakaoLogin() -> Observable<Result<Responder.SignInWithVendor, Error>> {
        return kakaoLoginService.kakaoLogin()
            .flatMap { [weak self] accessToken in
                self!.lilacUserService.kakaoLogin(for: accessToken)
            }
    }
}

extension AuthViewModel: ViewModel {
    struct Input {
        let kakaoLoginButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let isLoggedIn: PublishRelay<Void>
        let isShowingToastMessage: PublishRelay<String>
    }
    
    func transform(input: Input) -> Output {
        let isLoggedIn = PublishRelay<Void>()
        let isShowingToastMessage = PublishRelay<String>()
        
        input.kakaoLoginButtonTap
            .flatMap { [weak self] _ in self!.kakaoLogin() }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let profile):
                    owner.saveUserInfo(profile: profile)
                    isLoggedIn.accept(())
                case .failure(let error):
                    isShowingToastMessage.accept(String(describing: error))
                }
            } onError: { _, error in
                isShowingToastMessage.accept(String(describing: error))
            }
            .disposed(by: disposeBag)
            
        return Output(
            isLoggedIn: isLoggedIn,
            isShowingToastMessage: isShowingToastMessage
        )
    }
}

extension AuthViewModel {
    private func saveUserInfo(profile: Responder.SignInWithVendor) {
        @UserDefault(key: .email, defaultValue: profile.email) var email
        @UserDefault(key: .nickname, defaultValue: profile.nickname) var nickname
        @UserDefault(key: .accessToken, defaultValue: profile.token.accessToken) var accessToken
        @UserDefault(key: .refreshToken, defaultValue: profile.token.refreshToken) var refreshToken
    }
}
