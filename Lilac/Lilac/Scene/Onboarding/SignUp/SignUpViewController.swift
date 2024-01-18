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
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.placeholder = "이메일을 입력하세요"
        textField.returnKeyType = .next
        return textField
    }()

    private let checkDuplicationButton: FilledColorButton = FilledColorButton(title: "중복 확인")

    private let nicknameTextField: LabeledTextField = {
        let textField = LabeledTextField(title: "닉네임")
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.placeholder = "닉네임을 입력하세요"
        textField.returnKeyType = .next
        return textField
    }()
    
    private let phoneNumberTextField: LabeledTextField = {
        let textField = LabeledTextField(title: "연락처")
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
    
    private let signUpButton = FilledColorButton(title: "가입하기")
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configureHiararchy() {
        super.configureHiararchy()
        
        modalPresentationStyle = .formSheet
        sheetPresentationController?.prefersGrabberVisible = true
        
        view.addSubview(scrollView)
        view.addSubview(signUpButton)
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
        
        signUpButton.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.bottom).offset(12)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top).inset(-12)
        }
    }
    
    override func bind() {
        let input = SignUpViewModel.Input(
            emailInputValue: emailTextField.rx.text.orEmpty,
            checkDuplicationButtonTap: checkDuplicationButton.rx.tap
        )
        
        let output = viewModel.transform(input: input)
        
        output.showToastMessage
            .bind(with: self) { owner, toast in
                owner.showToast(message: toast.message, style: toast.style, bottomInset: 105)
            }
            .disposed(by: disposeBag)
        
        output.checkDuplicationButtonEnabled
            .bind(to: checkDuplicationButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.emailValidation
            .bind(to: emailTextField.rx.isValid)
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
}
