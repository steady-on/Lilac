//
//  SignUpViewModel.swift
//  Lilac
//
//  Created by Roen White on 1/17/24.
//

import Foundation
import RxSwift
import RxCocoa

final class SignUpViewModel {
    
    typealias Toast = (message: String, style: ToastMessage.Style)
    
    deinit {
        print("deinit SignUpViewModel")
    }
    
    var disposeBag = DisposeBag()
    
    private var finalCheckedEmail = ""
    
    private lazy var lilacUserService = LilacUserService()
}

extension SignUpViewModel: ViewModel {
    struct Input {
        let emailInputValue: ControlProperty<String>
        let nicknameInputValue: ControlProperty<String>
        let phoneNumberInputValue: ControlProperty<String>
        let passwordInputValue: ControlProperty<String>
        let passwordCheckInputValue: ControlProperty<String>
        let checkDuplicationButtonTap: ControlEvent<Void>
        let signUpButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let showToastMessage: PublishRelay<Toast>
        let checkDuplicationButtonEnabled: Observable<Bool>
        let signUpButtonEnabled: Observable<Bool>
        let emailValidation: Observable<Bool>
    }
    
    func transform(input: Input) -> Output {
        // 토스트 알림을 방출할 스트림
        let showToastMessage = PublishRelay<Toast>()
        
        // 중복확인 버튼 활성화
        let checkDuplicationButtonEnabled = input.emailInputValue
            .map { inputValue in inputValue.isEmpty == false }
        
        // 회원가입 버튼 활성화
        let signUpButtonEnabled = PublishRelay.combineLatest(input.emailInputValue, input.nicknameInputValue, input.passwordInputValue, input.passwordCheckInputValue)
            .map { email, nickname, password, passwordCheck in
                email.isEmpty == false && nickname.isEmpty == false
                && password.isEmpty == false && passwordCheck.isEmpty == false
            }
        
        let emailValidation = input.checkDuplicationButtonTap
            .withLatestFrom(input.emailInputValue) { _, inputValue in inputValue }
            .map { emailInput in emailInput.isValidEmail }
        
        // 이메일 형식이 올바르지 않을 때 토스트 메세지
        emailValidation
            .filter { bool in bool == false }
            .bind { _ in
                showToastMessage.accept(("이메일 형식이 올바르지 않습니다.", .caution))
            }
            .disposed(by: disposeBag)
        
        // 직전에 요청한 이메일과 같은 값일 때 직전 결과로 토스트 메세지
        emailValidation
            .filter { bool in bool }
            .withLatestFrom(input.emailInputValue) { _, inputValue in inputValue }
            .distinctUntilChanged { $0 != $1 }
            .withLatestFrom(showToastMessage)
            .bind(to: showToastMessage)
            .disposed(by: disposeBag)
        
        // 직전 결과와 다를 때 서버로 중복확인 요청
        emailValidation
            .filter { bool in bool }
            .withLatestFrom(input.emailInputValue) { _, inputValue in inputValue }
            .distinctUntilChanged()
            .debounce(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .flatMap { [unowned self] inputValue in
                return self.lilacUserService.checkEmailDuplicated(email: inputValue)
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(_):
                    showToastMessage.accept(("사용 가능한 이메일입니다.", .success))
                case .failure(_):
                    showToastMessage.accept(("이미 존재하는 계정입니다.", .caution))
                }
            } onError: { _, _ in
                showToastMessage.accept(("에러가 발생했어요. 잠시 후 다시 시도해주세요.", .caution))
            }
            .disposed(by: disposeBag)

        
        return Output(
            showToastMessage: showToastMessage,
            checkDuplicationButtonEnabled: checkDuplicationButtonEnabled,
            signUpButtonEnabled: signUpButtonEnabled,
            emailValidation: emailValidation
        )
    }
}
