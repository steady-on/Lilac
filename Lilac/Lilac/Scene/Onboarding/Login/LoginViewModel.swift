//
//  LoginViewModel.swift
//  Lilac
//
//  Created by Roen White on 1/16/24.
//

import Foundation
import RxSwift
import RxCocoa

final class LoginViewModel {
    deinit {
        print("deinit LoginViewModel")
    }
    
    var disposeBag = DisposeBag()
    
    private lazy var lilacUserService = LilacUserService()
    private lazy var lilacWorkspaceService = LilacWorkspaceService()
}

extension LoginViewModel: ViewModel {
    struct Input {
        let emailInputValue: ControlProperty<String>
        let passwordInputValue: ControlProperty<String>
        let loginButtonTappedEvent: ControlEvent<Void>
    }
    
    struct Output {
        let goToHome: PublishRelay<Void>
        let buttonEnabled: Observable<Bool>
        let emailValidation: PublishRelay<Bool>
        let passwordValidation: PublishRelay<Bool>
        let showToastAlert: PublishRelay<String>
    }
    
    func transform(input: Input) -> Output {
        let goToHome = PublishRelay<Void>()
        let emailValidation = PublishRelay<Bool>()
        let passwordValidation = PublishRelay<Bool>()
        let showToastMessage = PublishRelay<String>()
        
        let isLoggedIn = PublishRelay<Void>()
        let isLoadedProfile = PublishRelay<Void>()
        
        let inputValues = PublishRelay.combineLatest(input.emailInputValue, input.passwordInputValue)
        
        let buttonEnabled = inputValues
            .map { emailValue, passwordValue in
                emailValue.isEmpty == false && passwordValue.isEmpty == false
            }
        
        let validations = input.loginButtonTappedEvent
            .withLatestFrom(inputValues) { _, values in
                return values
            }
            .map { emailInput, passwordInput in
                let emailValidation = emailInput.isValidEmail
                let passwordValidation = passwordInput.isValidPassword
                return (emailValidation, passwordValidation)
            }
        
        validations
            .bind { isValidEmail, isValidPassword in
                emailValidation.accept(isValidEmail)
                passwordValidation.accept(isValidPassword)
                
                guard isValidEmail else {
                    showToastMessage.accept("이메일 형식이 올바르지 않습니다.")
                    return
                }

                guard isValidPassword else {
                    showToastMessage.accept("비밀번호는 최소 8자 이상, 하나 이상의 대소문자/숫자/특수 문자를 설정해주세요.")
                    return
                }
            }
            .disposed(by: disposeBag)
        
        validations
            .filter { isValidEmail, isValidPassword in isValidEmail && isValidPassword }
            .withLatestFrom(inputValues) { _, values in values }
            .debounce(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .flatMap { [unowned self] email, password in
                lilacUserService.emailLogin(email: email, password: password)
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let signIn):
                    guard owner.saveToken(signIn) else {
                        showToastMessage.accept("에러가 발생했어요. 잠시 후 다시 시도해주세요.")
                        return
                    }
                    
                    isLoggedIn.accept(())
                case .failure(_):
                    showToastMessage.accept("이메일 또는 비밀번호가 올바르지 않습니다.")
                }
            } onError: { _, _  in
                showToastMessage.accept("에러가 발생했어요. 잠시 후 다시 시도해주세요.")
            }
            .disposed(by: disposeBag)
        
        isLoggedIn
            .flatMap { [unowned self] _ in
                lilacUserService.loadMyProfile()
            }
            .subscribe { result in
                switch result {
                case .success(let myProfile):
                    User.shared.update(for: myProfile)
                    isLoadedProfile.accept(())
                case .failure(_):
                    showToastMessage.accept("에러가 발생했어요. 잠시 후 다시 시도해주세요.")
                }
            } onError: { _ in
                showToastMessage.accept("에러가 발생했어요. 잠시 후 다시 시도해주세요.")
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
                    showToastMessage.accept("에러가 발생했어요. 잠시 후 다시 시도해주세요.")
                }
            } onError: { _ in
                showToastMessage.accept("에러가 발생했어요. 잠시 후 다시 시도해주세요.")
            }
            .disposed(by: disposeBag)
        
        return Output(
            goToHome: goToHome,
            buttonEnabled: buttonEnabled,
            emailValidation: emailValidation,
            passwordValidation: passwordValidation,
            showToastAlert: showToastMessage
        )
    }
}

extension LoginViewModel {
    private func saveToken(_ profile: Responder.User.SimpleProfileWithToken) -> Bool {
        @KeychainStorage(itemType: .accessToken) var accessToken
        @KeychainStorage(itemType: .refreshToken) var refreshToken
        
        accessToken = profile.accessToken
        refreshToken = profile.refreshToken
        
        guard accessToken != nil, refreshToken != nil else {
            return false
        }
        
        return true
    }
}
