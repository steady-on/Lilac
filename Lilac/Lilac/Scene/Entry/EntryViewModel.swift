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
    @UserDefault(key: .lastVisitedWorkspaceId, defaultValue: Optional<Int>(nil)) private var lastVisitedWorkspaceId
    
    private lazy var lilacAuthService = LilacAuthService.shared
    private lazy var lilacUserService = LilacUserService()
    private lazy var lilacWorkspaceService = LilacWorkspaceService()
    
    var disposeBag = DisposeBag()
}

extension EntryViewModel: ViewModel {
    struct Input {}
    
    struct Output {
        let goToOnboarding: BehaviorRelay<Bool>
        let goToHome: PublishRelay<Void>
    }
    
    func transform(input: Input) -> Output {
        let goToOnboarding = BehaviorRelay(value: true)
        let goToHome = PublishRelay<Void>()
        
        let isTokenRefresh = PublishRelay<Void>()
        let isLoadedProfile = PublishRelay<Void>()
        let isLoadedWorkspaces = PublishRelay<Void>()
        
        guard isFirst == false else {
            refreshToken = nil
            accessToken = nil
            isFirst = false
            
            return Output(
                goToOnboarding: goToOnboarding,
                goToHome: goToHome
            )
        }
        
        guard refreshToken != nil else {
            return Output(
                goToOnboarding: goToOnboarding,
                goToHome: goToHome
            )
        }
        
        goToOnboarding.accept(false)
        
        let tokenRefreshResponse = lilacAuthService.refreshAccessToken()
        
        tokenRefreshResponse
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let newToken):
                    owner.accessToken = newToken.accessToken
                    isTokenRefresh.accept(())
                case .failure(let error):
                    if case LilacAPIError.validToken = error {
                        isTokenRefresh.accept(())
                    } else {
                        goToOnboarding.accept(true)
                    }
                }
            } onFailure: { owner, error in
                goToOnboarding.accept(true)
            }
            .disposed(by: disposeBag)
        
        // User의 프로필 정보를 받아옴
        isTokenRefresh
            .flatMap { [unowned self] _ in
                lilacUserService.loadMyProfile()
            }
            .subscribe { result in
                switch result {
                case .success(let myProfile):
                    User.shared.update(for: myProfile)
                    isLoadedProfile.accept(())
                case .failure(_):
                    goToOnboarding.accept(true)
                }
            } onError: { _ in
                goToOnboarding.accept(true)
            }
            .disposed(by: disposeBag)
        
        // User가 속한 workspace 정보를 받아옴
        isLoadedProfile
            .flatMap { [unowned self] _ in
                lilacWorkspaceService.loadAll()
            }
            .subscribe { result in
                switch result {
                case .success(let workspaces):
                    User.shared.fetch(for: workspaces)
                    isLoadedWorkspaces.accept(())
                case .failure(_):
                    goToOnboarding.accept(true)
                }
            } onError: { _ in
                goToOnboarding.accept(true)
            }
            .disposed(by: disposeBag)
        
        isLoadedWorkspaces
            .filter { [unowned self] _ in
                guard let lastVisitedWorkspaceId else {
                    goToHome.accept(())
                    return false
                }
                
                return true
            }
            .flatMap { [unowned self] _ in
                lilacWorkspaceService.loadSpecified(id: lastVisitedWorkspaceId!)
            }
            .subscribe { result in
                switch result {
                case .success(let workspace):
                    User.shared.updateWorkspaceDetail(for: workspace)
                    goToHome.accept(())
                case .failure(let error):
                    goToOnboarding.accept(true)
                }
            } onError: { _ in
                goToOnboarding.accept(true)
            }
            .disposed(by: disposeBag)
        
        return Output(
            goToOnboarding: goToOnboarding,
            goToHome: goToHome
        )
    }
}
