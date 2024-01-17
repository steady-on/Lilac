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
        let showToastMessage: PublishRelay<String>
        let buttonEnabled: Observable<Bool>
    }
    
    func transform(input: Input) -> Output {
        let isLoggedIn = PublishRelay<Void>()
        let showToastMessage = PublishRelay<String>()
        
        let inputValues = Observable.combineLatest(input.emailInputValue, input.passwordInputValue)
        
        let buttonEnabled = inputValues.map { emailValue, passwordValue in
                emailValue.isEmpty == false && passwordValue.isEmpty == false
            }
        
        let emailValidation = input.loginButtonTappedEvent
            .withLatestFrom(input.emailInputValue) { _, inputValue in
                return inputValue
            }
            .map { inputValue in
                return inputValue.isValidEmail
            }.share()
        
        emailValidation
            .filter { bool in bool == false }
            .subscribe { _ in
                showToastMessage.accept("이메일 형식이 올바르지 않습니다.")
            }
            .disposed(by: disposeBag)
        
        let passwordValidation = emailValidation
            .filter { bool in bool }
            .withLatestFrom(input.passwordInputValue) { bool, inputValue in
                return inputValue
            }
            .map { inputValue in
                return inputValue.isValidPassword
            }.share()
        
        passwordValidation
            .filter { bool in bool == false }
            .subscribe { _ in
                showToastMessage.accept("비밀번호는 최소 8자 이상, 하나 이상의 대소문자/숫자/특수 문자를 설정해주세요.")
            }
            .disposed(by: disposeBag)
        
        passwordValidation
            .filter { bool in bool }
            .withLatestFrom(inputValues)
            .flatMap { [weak self] email, password in
                self!.lilacUserService.emailLogin(email: email, password: password)
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
            showToastMessage: showToastMessage,
            buttonEnabled: buttonEnabled
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
