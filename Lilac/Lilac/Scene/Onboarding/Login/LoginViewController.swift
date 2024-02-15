//
//  LoginViewController.swift
//  Lilac
//
//  Created by Roen White on 1/15/24.
//

import UIKit
import RxSwift
import RxCocoa

final class LoginViewController: BaseViewController {
    
    private let viewModel: LoginViewModel
    
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        
        super.init()
    }
    
    deinit {
        print("deinit LoginViewController")
    }
    
    private let disposeBag = DisposeBag()
    
    private let emailTextField: LabeledTextField = {
        let textField = LabeledTextField(title: "이메일")
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.placeholder = "이메일을 입력하세요"
        return textField
    }()
    
    private let passwordTextField: LabeledTextField = {
        let textField = LabeledTextField(title: "비밀번호")
        textField.isSecureTextEntry = true
        textField.placeholder = "비밀번호를 입력하세요"
        return textField
    }()
    
    private let loginButton = FilledColorButton(title: "로그인")
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configureHiararchy() {
        super.configureHiararchy()
        
        modalPresentationStyle = .formSheet
        sheetPresentationController?.prefersGrabberVisible = true
        
        let components = [emailTextField, passwordTextField, loginButton]
        components.forEach { component in
            view.addSubview(component)
        }
    }
    
    override func setConstraints() {
        emailTextField.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(24)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(24)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(24)
        }
        
        loginButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-24)
        }
    }
    
    override func bind() {
        let input = LoginViewModel.Input(
            emailInputValue: emailTextField.rx.text.orEmpty,
            passwordInputValue: passwordTextField.rx.text.orEmpty,
            loginButtonTappedEvent: loginButton.rx.tap
        )
        
        let output = viewModel.transform(input: input)
        
        output.goToHome
            .bind(with: self) { owner, _ in
                owner.moveToHome()
            }
            .disposed(by: disposeBag)
        
        output.buttonEnabled
            .bind(to: loginButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.emailValidation
            .bind(to: emailTextField.rx.isValid)
            .disposed(by: disposeBag)
        
        output.passwordValidation
            .bind(to: passwordTextField.rx.isValid)
            .disposed(by: disposeBag)
        
        output.showToastAlert
            .subscribe(with: self) { owner, message in
                owner.showToast(.init(message: message, style: .caution), target: owner, bottomInset: -84)
            }
            .disposed(by: disposeBag)
    }
    
    override func configureNavigationBar() {
        title = "이메일 로그인"
        
        let closeButton = UIBarButtonItem(image: .Icon.close, style: .plain, target: self, action: #selector(closeButtonTapped))
        closeButton.tintColor = .black
        navigationItem.leftBarButtonItem = closeButton
        
        let barAppearance = UINavigationBarAppearance()
        barAppearance.backgroundColor = .Background.secondary
        navigationItem.scrollEdgeAppearance = barAppearance
    }
}

extension LoginViewController {
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    private func moveToHome() {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let sceneDelegate = windowScene?.delegate as? SceneDelegate
        // TODO: 추후 Home Default 화면으로 이동
        let navigationController = UINavigationController(rootViewController: ViewController())
        sceneDelegate?.window?.rootViewController = navigationController
        sceneDelegate?.window?.makeKeyAndVisible()
    }
}
