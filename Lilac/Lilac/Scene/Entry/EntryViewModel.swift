//
//  EntryViewModel.swift
//  Lilac
//
//  Created by Roen White on 1/25/24.
//

import Foundation
import RxSwift
import RxCocoa

final class EntryViewModel {
    
    deinit {
        print("deinit EntryViewModel")
    }
    
    @KeychainStorage(itemType: .refreshToken) private var refreshToken
    @KeychainStorage(itemType: .accessToken) private var accessToken
    
    @UserDefault(key: .isFirst, defaultValue: true) private var isFirst
    
    private lazy var lilacAuthService = LilacAuthService.shared
    private lazy var lilacUserService = LilacUserService()
    private lazy var lilacWorkSpaceService = LilacWorkSpaceService()
    
    var disposeBag = DisposeBag()
}

extension EntryViewModel: ViewModel {
    struct Input {}
    
    struct Output {
        let goToOnboardingView: PublishRelay<Bool>
    }
    
    func transform(input: Input) -> Output {
        let goToOnboardingView = PublishRelay<Bool>()
        let isTokenRefresh = PublishRelay<Void>()
        
        let isLoadedProfile = PublishRelay<Void>()
        
        guard isFirst == false else {
            refreshToken = nil
            accessToken = nil
            isFirst = false
            goToOnboardingView.accept(true)
            return Output(goToOnboardingView: goToOnboardingView)
        }
        
        guard refreshToken != nil else {
            return Output(goToOnboardingView: goToOnboardingView)
        }
        
        let tokenRefreshResponse = lilacAuthService.refreshAccessToken()
        
        tokenRefreshResponse
            .subscribe(with: self) { owner, result in
                print("토큰 새로 받아옴")
                switch result {
                case .success(let newToken):
                    owner.accessToken = newToken.accessToken
                    isTokenRefresh.accept(())
                case .failure(let error):
                    if case LilacAPIError.validToken = error {
                        isTokenRefresh.accept(())
                    } else {
                        goToOnboardingView.accept(true)
                    }
                }
            } onFailure: { owner, error in
                goToOnboardingView.accept(true)
            }
            .disposed(by: disposeBag)
        
        isTokenRefresh
            .flatMap { [unowned self] _ in
                lilacUserService.loadMyProfile()
            }
            .subscribe { result in
                switch result {
                case .success(let myProfile):
                    print("프로필 가져왔당")
                    User.shared.update(for: myProfile)
                    isLoadedProfile.accept(())
                case .failure(_):
                    goToOnboardingView.accept(true)
                }
            } onError: { _ in
                goToOnboardingView.accept(true)
            }
            .disposed(by: disposeBag)
        
        isLoadedProfile
            .flatMap { [unowned self] _ in
                return lilacWorkSpaceService.loadAll()
            }
            .subscribe { result in
                switch result {
                case .success(let workspaces):
                    User.shared.fetch(for: workspaces)
                    goToOnboardingView.accept(false)
                case .failure(_):
                    goToOnboardingView.accept(true)
                }
            } onError: { _ in
                goToOnboardingView.accept(true)
            }
            .disposed(by: disposeBag)
        
        return Output(goToOnboardingView: goToOnboardingView)
    }
}
