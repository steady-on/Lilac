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
}

extension LoginViewModel: ViewModel {
    struct Input {
        let emailInputValue: ControlProperty<String>
        let passwordInputValue: ControlProperty<String>
        let loginButtonTappedEvent: ControlEvent<Void>
    }
    
    struct Output {
        let isLoggedIn: PublishRelay<Void>
        let buttonEnabled: Observable<Bool>
        let emailValidation: PublishRelay<Bool>
        let passwordValidation: PublishRelay<Bool>
        let showToastMessage: PublishRelay<String>
    }
    
    func transform(input: Input) -> Output {
        let isLoggedIn = PublishRelay<Void>()
        let emailValidation = PublishRelay<Bool>()
        let passwordValidation = PublishRelay<Bool>()
        let showToastMessage = PublishRelay<String>()
        
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
                    owner.saveUserInfo(signIn)
                    isLoggedIn.accept(())
                case .failure(_):
                    showToastMessage.accept("이메일 또는 비밀번호가 올바르지 않습니다.")
                }
            } onError: { _, _  in
                showToastMessage.accept("에러가 발생했어요. 잠시 후 다시 시도해주세요.")
            }
            .disposed(by: disposeBag)
        
        return Output(
            isLoggedIn: isLoggedIn,
            buttonEnabled: buttonEnabled,
            emailValidation: emailValidation,
            passwordValidation: passwordValidation,
            showToastMessage: showToastMessage
        )
    }
}

extension LoginViewModel {
    private func saveUserInfo(_ signIn: Responder.SignIn) {
        @UserDefault(key: .nickname, defaultValue: signIn.nickname) var nickname
        @UserDefault(key: .accessToken, defaultValue: signIn.accessToken) var accessToken
        @UserDefault(key: .refreshToken, defaultValue: signIn.refreshToken) var refreshToken
    }
}
