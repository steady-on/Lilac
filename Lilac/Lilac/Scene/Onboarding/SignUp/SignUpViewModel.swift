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
    
    private var duplicatedEmail = [String]()
    private var finalCheckedEmail = ""
    
    private lazy var lilacUserService = LilacUserService()
}

extension SignUpViewModel: ViewModel {
    struct Input {
        let emailInputValue: ControlProperty<String>
        let checkDuplicationButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let showToastMessage: PublishRelay<Toast>
        let checkDuplicationButtonEnabled: Observable<Bool>
        let emailValidateion: Observable<Bool>
    }
    
    func transform(input: Input) -> Output {
        let showToastMessage = PublishRelay<Toast>()
        
        let checkDuplicationButtonEnabled = input.emailInputValue
            .map { inputValue in inputValue.isEmpty == false }
        
        let emailValidation = input.checkDuplicationButtonTap
            .withLatestFrom(input.emailInputValue) { _, inputValue in inputValue }
            .map { emailInput in emailInput.isValidEmail }
        
        emailValidation
            .filter { bool in bool == false }
            .bind { _ in
                showToastMessage.accept(("이메일 형식이 올바르지 않습니다.", .caution))
            }
            .disposed(by: disposeBag)
        
        return Output(
            showToastMessage: showToastMessage,
            checkDuplicationButtonEnabled: checkDuplicationButtonEnabled, 
            emailValidateion: emailValidation
        )
    }
}
