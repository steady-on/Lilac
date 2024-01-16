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
    var disposeBag = DisposeBag()
}

extension LoginViewModel: ViewModel {
    struct Input {
        let emailInputValue: ControlProperty<String>
        let passwordInputValue: ControlProperty<String>
        let loginButtonTappedEvent: ControlEvent<Void>
    }
    
    struct Output {
        let buttonEnabled: Observable<Bool>
    }
    
    func transform(input: Input) -> Output {
        let buttonEnabled =  Observable.combineLatest(input.emailInputValue, input.passwordInputValue)
            .map { emailValue, passwordValue in
                emailValue.isEmpty == false && passwordValue.isEmpty == false
            }
        
        
        
        return Output(
            buttonEnabled: buttonEnabled
        )
    }
}
