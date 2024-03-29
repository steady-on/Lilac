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
    deinit {
        print("deinit SignUpViewModel")
    }
    
    var disposeBag = DisposeBag()
        
    private lazy var lilacUserService = UserServiceImpl()
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
        let showToastAlert: PublishRelay<ToastAlert.Toast>
        let checkDuplicationButtonEnabled: Observable<Bool>
        let emailValidationResult: PublishRelay<Bool>
        let signUpButtonEnabled: Observable<Bool>
        let allValuesValidationResult: PublishRelay<(isCheckedEmail: Bool, isValidNickname: Bool, isValidPhoneNumber: Bool, isValidPassword: Bool, isPasswordChecked: Bool)>
        let isCompletedSignUp: PublishRelay<Void>
    }
    
    func transform(input: Input) -> Output {
        let showToastMessage = PublishRelay<ToastAlert.Toast>() // 토스트 알림을 방출하는 스트림
        let emailValidationResult = PublishRelay<Bool>() // 이메일이 형식에 맞는지를 판단한 결과
        let allValuesValidationResult = PublishRelay<(isCheckedEmail: Bool, isValidNickname: Bool, isValidPhoneNumber: Bool, isValidPassword: Bool, isPasswordChecked: Bool)>()
        let isCompletedSignUp = PublishRelay<Void>()
        
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
                    showToastMessage.accept(.init(message: "이메일 형식이 올바르지 않습니다.", style: .caution))
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
                showToastMessage.accept(.init(message: "에러가 발생했어요. 잠시 후 다시 시도해주세요.", style: .caution))
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
                    showToastMessage.accept(.init(message: "사용 가능한 이메일입니다.", style: .success))
                case .failure(_):
                    showToastMessage.accept(.init(message: "이미 존재하는 계정입니다.", style: .caution))
                }
            } onError: { _, _ in
                showToastMessage.accept(.init(message: "에러가 발생했어요. 잠시 후 다시 시도해주세요.", style: .caution))
            }
            .disposed(by: disposeBag)
        
        // 현재 emailTextField에 입력된 값과 마지막으로 서버에 확인한 이메일의 일치여부를 확인하기 위한 스트림
        let isSameEmailValues = Observable.combineLatest(input.emailInputValue, validEmailInputValue)
            .map { present, checked in present == checked }
        
        // 회원 가입 전 확인해야할 모든 검사 모음
        let allValuesValidation = Observable.combineLatest(isSameEmailValues, nicknameValidation, phoneNumberValidation, passwordValidation, passwordCheckValidation)
        
        // 회원가입 요청에 필요한 값 모음
        let allInputValues = Observable.combineLatest(input.emailInputValue, input.nicknameInputValue, input.passwordInputValue, input.phoneNumberInputValue)
        
        // 회원가입 버튼을 탭했을 때 모든 정보가 유효한지 순차적으로 확인하는 로직
        let validInputValues = input.signUpButtonTap
            .withLatestFrom(allValuesValidation) { _, validation in validation }
            .filter { isCheckedEmail, isValidNickname, isValidPhoneNumber, isValidPassword, isPasswordChecked in
                allValuesValidationResult.accept((isCheckedEmail, isValidNickname, isValidPhoneNumber, isValidPassword, isPasswordChecked))
                
                let toast: ToastAlert.Toast? = if isCheckedEmail == false { .init(message: "이메일 중복 확인을 진행해주세요.", style: .caution)
                } else if isValidNickname == false { .init(message: "닉네임은 1글자 이상 30글자 이내로 부탁드려요.", style: .caution)
                } else if isValidPhoneNumber == false { .init(message: "잘못된 전화번호 형식입니다.", style: .caution)
                } else if isValidPassword == false { .init(message: "비밀번호는 최소 8자 이상, 하나 이상의 대소문자/숫자/특수 문자를 설정해주세요.", style: .caution)
                } else  if isPasswordChecked == false { .init(message: "작성하신 비밀번호가 일치하지 않습니다. ", style: .caution)
                } else { nil }
                
                if let toast {
                    showToastMessage.accept(toast)
                }
                
                return isCheckedEmail && isValidNickname && isValidPhoneNumber && isValidPassword && isPasswordChecked
            }
            .withLatestFrom(allInputValues) { _, allValues in allValues }
        
        // 모든 값이 유효한 경우 회원가입 요청
        validInputValues
            .debounce(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .flatMap { [unowned self] email, nickname, password, phoneNumber in
                lilacUserService.signUp(for: .init(email: email, password: password, nickname: nickname, phone: phoneNumber))
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let profile):
                    guard owner.saveToken(profile.token) else {
                        showToastMessage.accept(.init(message: "에러가 발생했어요. 잠시 후 다시 시도해주세요.", style: .caution))
                        return
                    }
                    User.shared.update(for: profile)
                    isCompletedSignUp.accept(())
                case .failure(_):
                    showToastMessage.accept(.init(message: "이미 가입된 회원입니다. 로그인을 진행해주세요.", style: .caution))
                }
            } onError: { owner, _ in
                showToastMessage.accept(.init(message: "에러가 발생했어요. 잠시 후 다시 시도해주세요.", style: .caution))
            }
            .disposed(by: disposeBag)

        return Output(
            showToastAlert: showToastMessage,
            checkDuplicationButtonEnabled: checkDuplicationButtonEnabled, 
            emailValidationResult: emailValidationResult,
            signUpButtonEnabled: signUpButtonEnabled,
            allValuesValidationResult: allValuesValidationResult,
            isCompletedSignUp: isCompletedSignUp
        )
    }
}

extension SignUpViewModel {
    private func saveToken(_ token: Responder.User.Token) -> Bool {
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
