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
    
    private func kakaoLogin() -> Observable<Result<Responder.User.ProfileWithToken, Error>> {
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
                    guard owner.saveUserInfo(profile: profile) else {
                        isShowingToastMessage.accept("에러가 발생했어요. 잠시 후 다시 시도해주세요.")
                        return
                    }
                    
                    isLoggedIn.accept(())
                case .failure(_):
                    isShowingToastMessage.accept("에러가 발생했어요. 잠시 후 다시 시도해주세요.")
                }
            } onError: { _, _ in
                isShowingToastMessage.accept("에러가 발생했어요. 잠시 후 다시 시도해주세요.")
            }
            .disposed(by: disposeBag)
            
        return Output(
            isLoggedIn: isLoggedIn,
            isShowingToastMessage: isShowingToastMessage
        )
    }
}

extension AuthViewModel {
    private func saveUserInfo(profile: Responder.User.ProfileWithToken) -> Bool {
        @UserDefault(key: .email, defaultValue: profile.email) var email
        @UserDefault(key: .nickname, defaultValue: profile.nickname) var nickname
        
        do {
            try KeychainManager.shared.save(.init(type: .accessToken, value: profile.token.accessToken))
            try KeychainManager.shared.save(.init(type: .refreshToken, value: profile.token.refreshToken))
            return true
        } catch {
            return false
        }
    }
}
