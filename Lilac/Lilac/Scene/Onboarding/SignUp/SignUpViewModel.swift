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
        let emailValidationResult: PublishRelay<Bool>
        let signUpButtonEnabled: Observable<Bool>
        let allValuesValidationResult: PublishRelay<(isCheckedEmail: Bool, isValidNickname: Bool, isValidPhoneNumber: Bool, isValidPassword: Bool, isPasswordChecked: Bool)>
        let isLoggedIn: PublishRelay<Void>
    }
    
    func transform(input: Input) -> Output {
        let showToastMessage = PublishRelay<Toast>() // 토스트 알림을 방출하는 스트림
        let emailValidationResult = PublishRelay<Bool>() // 이메일이 형식에 맞는지를 판단한 결과
        let allValuesValidationResult = PublishRelay<(isCheckedEmail: Bool, isValidNickname: Bool, isValidPhoneNumber: Bool, isValidPassword: Bool, isPasswordChecked: Bool)>()
        let isLoggedIn = PublishRelay<Void>()
        
        let isDuplicatedEmail = PublishRelay<Result<Void, Error>>()
        let validEmailInputValue = BehaviorRelay(value: "")
        
        // 중복확인 버튼 활성화
        let checkDuplicationButtonEnabled = input.emailInputValue
            .map { inputValue in inputValue.isEmpty == false }
        
        // 회원가입 버튼 활성화
        let signUpButtonEnabled = PublishRelay.combineLatest(input.emailInputValue, input.nicknameInputValue, input.passwordInputValue, input.passwordCheckInputValue)
            .map { email, nickname, password, passwordCheck in
                email.isEmpty == false && nickname.isEmpty == false
                && password.isEmpty == false && passwordCheck.isEmpty == false
            }
        
        // 이메일 형식 확인
        let emailValidation = input.emailInputValue
            .map { emailInput in emailInput.isValidEmail }
        
        // 닉네임 길이 확인
        let nicknameValidation = input.nicknameInputValue
            .map { inputValue in
                1...30 ~= inputValue.count
            }
        
        // 전화번호 길이 확인
        let phoneNumberValidation = input.phoneNumberInputValue
            .map { inputValue in
                guard inputValue.isEmpty == false else { return true } // 비어있으면 true
                return inputValue.starts(with: "01") && 12...13 ~= inputValue.count
            }
        
        // 비밀번호 형식 확인
        let passwordValidation = input.passwordInputValue
            .map { inputValue in
                inputValue.isValidPassword
            }
        
        // 비밀번호와 비밀번호 확인 일치
        let passwordCheckValidation = Observable.combineLatest(input.passwordInputValue, input.passwordCheckInputValue)
            .map { passwordInput, checkInput in
                passwordInput == checkInput
            }
        
        // 유효한 이메일인지에 대한 검사 결과를 view에 반영하고, 형식에 맞다면 그 이메일 주소를 저장
        input.checkDuplicationButtonTap
            .withLatestFrom(emailValidation) { _, isValidEmail in isValidEmail }
            .filter { isValidEmail in
                if isValidEmail == false {
                    showToastMessage.accept(("이메일 형식이 올바르지 않습니다.", .caution))
                }
                
                emailValidationResult.accept(isValidEmail)
                
                return isValidEmail
            }
            .withLatestFrom(input.emailInputValue) { _, inputValue in inputValue }
            .bind(to: validEmailInputValue)
            .disposed(by: disposeBag)
        
        // 직전에 중복검사 요청을 한 메일 주소가 아닌 경우: 서버로 중복 검사 요청
        validEmailInputValue
            .skip(1) // BehaviorRelay가 선언되면서 방출하는 빈 문자열 스킵
            .distinctUntilChanged()
            .debounce(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .flatMap { [unowned self] inputValue in
                self.lilacUserService.checkEmailDuplicated(email: inputValue)
            }
            .subscribe { result in
                isDuplicatedEmail.accept(result)
            } onError: { _ in
                showToastMessage.accept(("에러가 발생했어요. 잠시 후 다시 시도해주세요.", .caution))
            }
            .disposed(by: disposeBag)
            
        
        // 직전에 중복검사 요청을 한 메일 주소와 같은 경우: 마지막으로 서버에서 받은 결과를 다시 한 번 방출
        validEmailInputValue
            .skip(1) // 맨 처음에는 비교할 값이 없기 때문에 pass
            .distinctUntilChanged { $0 != $1 }
            .withLatestFrom(isDuplicatedEmail)
            .bind(to: isDuplicatedEmail)
            .disposed(by: disposeBag)
        
        // 서버에서 받은 결과를 처리하는 로직
        isDuplicatedEmail
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
        
        // 현재 emailTextField에 입력된 값과 마지막으로 서버에 확인한 이메일의 일치여부를 확인하기 위한 스트림
        let isSameEmailValues = Observable.combineLatest(input.emailInputValue, validEmailInputValue)
            .map { present, checked in present == checked }
        
        // 회원 가입 전 확인해야할 모든 검사 모음
        let allValuesValidation = Observable.combineLatest(isSameEmailValues, nicknameValidation, phoneNumberValidation, passwordValidation, passwordCheckValidation)
        
        // 회원가입 요청에 필요한 값 모음
        let allInputValues = Observable.combineLatest(input.emailInputValue, input.nicknameInputValue, input.passwordInputValue, input.phoneNumberInputValue)
        
        let validInputValues = input.signUpButtonTap
            .withLatestFrom(allValuesValidation) { _, validation in validation }
            .filter { isCheckedEmail, isValidNickname, isValidPhoneNumber, isValidPassword, isPasswordChecked in
                allValuesValidationResult.accept((isCheckedEmail, isValidNickname, isValidPhoneNumber, isValidPassword, isPasswordChecked))
                
                let toast: Toast? = if isCheckedEmail == false { ("이메일 중복 확인을 진행해주세요.", .caution)
                } else if isValidNickname == false { ("닉네임은 1글자 이상 30글자 이내로 부탁드려요.", .caution)
                } else if isValidPhoneNumber == false { ("잘못된 전화번호 형식입니다.", .caution)
                } else if isValidPassword == false { ("비밀번호는 최소 8자 이상, 하나 이상의 대소문자/숫자/특수 문자를 설정해주세요.", .caution)
                } else  if isPasswordChecked == false { ("작성하신 비밀번호가 일치하지 않습니다. ", .caution)
                } else { nil }
                
                if let toast {
                    showToastMessage.accept(toast)
                }
                
                return isCheckedEmail && isValidNickname && isValidPhoneNumber && isValidPassword && isPasswordChecked
            }
            .withLatestFrom(allInputValues) { _, allValues in allValues }
        
        validInputValues
            .debounce(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .flatMap { [unowned self] email, nickname, password, phoneNumber in
                self.lilacUserService.signUp(for: .init(email: email, password: password, nickname: nickname, phone: phoneNumber))
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let signUp):
                    owner.saveUserInfo(signUp)
                    isLoggedIn.accept(())
                case .failure(_):
                    showToastMessage.accept(("이미 가입된 회원입니다. 로그인을 진행해주세요.", .caution))
                }
            } onError: { owner, _ in
                showToastMessage.accept(("에러가 발생했어요. 잠시 후 다시 시도해주세요.", .caution))
            }
            .disposed(by: disposeBag)

        return Output(
            showToastMessage: showToastMessage,
            checkDuplicationButtonEnabled: checkDuplicationButtonEnabled, 
            emailValidationResult: emailValidationResult,
            signUpButtonEnabled: signUpButtonEnabled,
            allValuesValidationResult: allValuesValidationResult,
            isLoggedIn: isLoggedIn
        )
    }
}

extension SignUpViewModel {
    private func saveUserInfo(_ signUp: Responder.SignUp) {
        @UserDefault(key: .accessToken, defaultValue: signUp.token.accessToken) var accessToken
        @UserDefault(key: .refreshToken, defaultValue: signUp.token.refreshToken) var refreshToken
    }
}
