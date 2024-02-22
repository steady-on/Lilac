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
    private lazy var lilacWorkspaceService = LilacWorkspaceService()
    
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
        let goToHome: PublishRelay<Void>
        let isShowingToastMessage: PublishRelay<String>
    }
    
    func transform(input: Input) -> Output {
        let goToHome = PublishRelay<Void>()
        let isShowingToastMessage = PublishRelay<String>()
        
        let isLoadedProfile = PublishRelay<Void>()
        
        input.kakaoLoginButtonTap
            .flatMap { [weak self] _ in self!.kakaoLogin() }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let profile):
                    guard owner.saveToken(token: profile.token) else {
                        isShowingToastMessage.accept("에러가 발생했어요. 잠시 후 다시 시도해주세요.")
                        return
                    }
                    
                    User.shared.update(for: profile)
                    isLoadedProfile.accept(())
                case .failure(_):
                    isShowingToastMessage.accept("에러가 발생했어요. 잠시 후 다시 시도해주세요.")
                }
            } onError: { _, _ in
                isShowingToastMessage.accept("에러가 발생했어요. 잠시 후 다시 시도해주세요.")
            }
            .disposed(by: disposeBag)
        
        isLoadedProfile
            .flatMap { [unowned self] _ in
                return lilacWorkspaceService.loadAll()
            }
            .subscribe { result in
                switch result {
                case .success(let workspaces):
                    User.shared.fetch(for: workspaces)
                    goToHome.accept(())
                case .failure(_):
                    isShowingToastMessage.accept("에러가 발생했어요. 잠시 후 다시 시도해주세요.")
                }
            } onError: { _ in
                isShowingToastMessage.accept("에러가 발생했어요. 잠시 후 다시 시도해주세요.")
            }
            .disposed(by: disposeBag)
            
        return Output(
            goToHome: goToHome,
            isShowingToastMessage: isShowingToastMessage
        )
    }
}

extension AuthViewModel {
    private func saveToken(token: Responder.User.Token) -> Bool {
        @KeychainStorage(itemType: .accessToken) var accessToken
        @KeychainStorage(itemType: .refreshToken) var refreshToken
        
        accessToken = token.accessToken
        refreshToken = token.refreshToken
        
        guard accessToken != nil, refreshToken != nil else {
            return false
        }
        
        return true
    }
}
