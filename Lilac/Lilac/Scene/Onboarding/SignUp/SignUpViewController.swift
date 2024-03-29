//
//  SignUpViewController.swift
//  Lilac
//
//  Created by Roen White on 1/17/24.
//

import UIKit
import RxSwift
import RxCocoa

final class SignUpViewController: BaseViewController {
    
    private let viewModel: SignUpViewModel
    
    init(viewModel: SignUpViewModel) {
        self.viewModel = viewModel
        
        super.init()
    }
    
    deinit {
        print("deinit SignUpViewController")
    }
    
    private let disposeBag = DisposeBag()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.keyboardDismissMode = .onDrag
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.directionalLayoutMargins = .init(top: 24, leading: 24, bottom: 24, trailing: 24)
        return view
    }()
    
    private let formStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .fill
        return stackView
    }()
    
    private let emailFieldStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .firstBaseline
        return stackView
    }()
    
    private let emailTextField: LabeledTextField = {
        let textField = LabeledTextField(title: "이메일")
        textField.textContentType = .emailAddress
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.placeholder = "이메일을 입력하세요"
        textField.returnKeyType = .next
        return textField
    }()

    private let checkDuplicationButton: FilledColorButton = FilledColorButton(title: "중복 확인")

    private let nicknameTextField: LabeledTextField = {
        let textField = LabeledTextField(title: "닉네임")
        textField.textContentType = .nickname
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.placeholder = "닉네임을 입력하세요"
        textField.returnKeyType = .next
        return textField
    }()
    
    private let phoneNumberTextField: LabeledTextField = {
        let textField = LabeledTextField(title: "연락처")
        textField.textContentType = .telephoneNumber
        textField.keyboardType = .numberPad
        textField.placeholder = "전화번호를 입력하세요"
        textField.returnKeyType = .next
        return textField
    }()
    
    private let passwordTextField: LabeledTextField = {
        let textField = LabeledTextField(title: "비밀번호")
        textField.textContentType = .newPassword
        textField.isSecureTextEntry = true
        textField.placeholder = "비밀번호를 입력하세요"
        textField.returnKeyType = .next
        return textField
    }()
    
    private let passwordCheckTextField: LabeledTextField = {
        let textField = LabeledTextField(title: "비밀번호 확인")
        textField.textContentType = .password
        textField.isSecureTextEntry = true
        textField.placeholder = "비밀번호를 한 번 더 입력하세요"
        textField.returnKeyType = .done
        return textField
    }()
    
    private let buttonBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .Background.primary
        view.directionalLayoutMargins = .init(top: 12, leading: 24, bottom: 12, trailing: 24)
        return view
    }()
    
    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .View.seperator
        view.isHidden = true
        return view
    }()
    
    private let signUpButton = FilledColorButton(title: "가입하기")
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configureHiararchy() {
        super.configureHiararchy()
        
        modalPresentationStyle = .formSheet
        sheetPresentationController?.prefersGrabberVisible = true
        
        let viewComponents = [scrollView, buttonBackgroundView]
        viewComponents.forEach { component in
            view.addSubview(component)
        }
        
        let buttonBackgroundViewComponents = [separator, signUpButton]
        buttonBackgroundViewComponents.forEach { component in
            buttonBackgroundView.addSubview(component)
        }
        
        scrollView.addSubview(contentView)
        contentView.addSubview(formStackView)
        
        let components = [emailFieldStack, nicknameTextField, phoneNumberTextField, passwordTextField, passwordCheckTextField]
        components.forEach { component in
            formStackView.addArrangedSubview(component)
        }
        
        let emailFieldComponents = [emailTextField, checkDuplicationButton]
        emailFieldComponents.forEach { component in
            emailFieldStack.addArrangedSubview(component)
        }
        
        let textFields = [emailTextField, nicknameTextField, phoneNumberTextField, passwordTextField, passwordCheckTextField]
        textFields.forEach { textField in
            textField.delegate = self
        }
    }
    
    override func setConstraints() {
        scrollView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(buttonBackgroundView.snp.top)
        }
        
        contentView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.edges.equalToSuperview()
        }
        
        formStackView.snp.makeConstraints { make in
            make.edges.equalTo(contentView.layoutMarginsGuide)
        }
        
        checkDuplicationButton.snp.makeConstraints { make in
            make.width.equalTo(100)
        }
        
        buttonBackgroundView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
        }
        
        separator.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(1)
            make.bottom.equalTo(buttonBackgroundView.snp.top)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.bottom.horizontalEdges.equalTo(buttonBackgroundView.layoutMarginsGuide)
            make.top.lessThanOrEqualTo(buttonBackgroundView.snp.top).offset(12)
        }
    }
    
    override func bind() {
        phoneNumberTextField.rx.text.orEmpty
            .map { input in
                input.formattedPhoneNumber()
            }
            .bind(to: phoneNumberTextField.rx.text)
            .disposed(by: disposeBag)
        
        let input = SignUpViewModel.Input(
            emailInputValue: emailTextField.rx.text.orEmpty,
            nicknameInputValue: nicknameTextField.rx.text.orEmpty,
            phoneNumberInputValue: phoneNumberTextField.rx.text.orEmpty,
            passwordInputValue: passwordTextField.rx.text.orEmpty,
            passwordCheckInputValue: passwordCheckTextField.rx.text.orEmpty,
            checkDuplicationButtonTap: checkDuplicationButton.rx.tap,
            signUpButtonTap: signUpButton.rx.tap
        )
        
        let output = viewModel.transform(input: input)
        
        output.showToastAlert
            .bind(with: self) { owner, toast in
                owner.showToast(toast, target: self, position: .high)
            }
            .disposed(by: disposeBag)
        
        output.checkDuplicationButtonEnabled
            .bind(to: checkDuplicationButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.emailValidationResult
            .bind(to: emailTextField.rx.isValid)
            .disposed(by: disposeBag)
        
        output.signUpButtonEnabled
            .bind(to: signUpButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.allValuesValidationResult
            .bind(with: self) { owner, allValidations in
                owner.emailTextField.rx.isValid.onNext(allValidations.isCheckedEmail)
                owner.nicknameTextField.rx.isValid.onNext(allValidations.isValidNickname)
                owner.phoneNumberTextField.rx.isValid.onNext(allValidations.isValidPhoneNumber)
                owner.passwordTextField.rx.isValid.onNext(allValidations.isValidPassword)
                owner.passwordCheckTextField.rx.isValid.onNext(allValidations.isPasswordChecked)
                
                if allValidations.isCheckedEmail == false {
                    owner.emailTextField.becomeFirstResponder()
                } else if allValidations.isValidNickname == false {
                    owner.nicknameTextField.becomeFirstResponder()
                } else if allValidations.isValidPhoneNumber == false {
                    owner.phoneNumberTextField.becomeFirstResponder()
                } else if allValidations.isValidPassword == false {
                    owner.passwordTextField.becomeFirstResponder()
                } else if allValidations.isPasswordChecked == false {
                    owner.passwordCheckTextField.becomeFirstResponder()
                }
            }
            .disposed(by: disposeBag)
        
        output.isCompletedSignUp
            .bind(with: self) { owner, _ in
                owner.moveToWelcomeView()
            }
            .disposed(by: disposeBag)
    }
    
    override func configureNavigationBar() {
        title = "회원가입"
        
        let closeButton = UIBarButtonItem(image: .Icon.close, style: .plain, target: self, action: #selector(closeButtonTapped))
        closeButton.tintColor = .black
        navigationItem.leftBarButtonItem = closeButton
                        
        let barAppearance = UINavigationBarAppearance()
        barAppearance.backgroundColor = .Background.secondary
        navigationItem.scrollEdgeAppearance = barAppearance
    }
}

extension SignUpViewController {
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            nicknameTextField.becomeFirstResponder()
        case nicknameTextField:
            phoneNumberTextField.becomeFirstResponder()
        case phoneNumberTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            passwordCheckTextField.becomeFirstResponder()
        default:
            view.endEditing(true)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        separator.isHidden = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        separator.isHidden = true
    }
}

extension SignUpViewController {
    private func moveToWelcomeView() {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let sceneDelegate = windowScene?.delegate as? SceneDelegate
        let navigationController = UINavigationController(rootViewController: WelcomeViewController(viewModel: WelcomeViewModel()))
        sceneDelegate?.window?.rootViewController = navigationController
        sceneDelegate?.window?.makeKeyAndVisible()
    }
}
