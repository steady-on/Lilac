//
//  LoginViewController.swift
//  Lilac
//
//  Created by Roen White on 1/15/24.
//

import UIKit

final class LoginViewController: BaseViewController {
    
    deinit {
        print("deinit LoginViewController")
    }
    
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
    
    private let loginButton: FilledColorButton = {
        let button = FilledColorButton(title: "로그인")
        button.isEnabled = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configureHiararchy() {
        super.configureHiararchy()
        
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
}
