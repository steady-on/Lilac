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
    
    private lazy var lilacAuthSevice = LilacAuthService.shared
    
    var disposeBag = DisposeBag()
}

extension EntryViewModel: ViewModel {
    struct Input {}
    
    struct Output {
        let goToOnboardingView: BehaviorRelay<Bool>
    }
    
    func transform(input: Input) -> Output {
        let goToOnboardingView = BehaviorRelay<Bool>(value: true)
        
        guard isFirst == false else {
            refreshToken = nil
            accessToken = nil
            isFirst = false
            return Output(goToOnboardingView: goToOnboardingView)
        }
        
        guard refreshToken != nil else {
            return Output(goToOnboardingView: goToOnboardingView)
        }
        
        let tokenRefreshResponse = lilacAuthSevice.refreshAccessToken()
        
        tokenRefreshResponse
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let newToken):
                    owner.accessToken = newToken.accessToken
                    goToOnboardingView.accept(false)
                case .failure(let error):
                    if case LilacAPIError.validToken = error {
                        goToOnboardingView.accept(false)
                    } else {
                        goToOnboardingView.accept(true)
                    }
                }
            } onFailure: { owner, error in
                goToOnboardingView.accept(true)
            }
            .disposed(by: disposeBag)
        
        return Output(goToOnboardingView: goToOnboardingView)
    }
}
