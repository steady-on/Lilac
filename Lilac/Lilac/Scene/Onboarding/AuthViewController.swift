//
//  AuthViewController.swift
//  Lilac
//
//  Created by Roen White on 1/13/24.
//

import UIKit

final class AuthViewController: BaseViewController {
    
    private let buttonStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        return stack
    }()
    
    private let appleLoginButton: UIButton = {
        let button = UIButton()
        button.setImage(.LoginButton.appleLogin, for: .normal)
        return button
    }()
    
    private let kakaoLoginButton: UIButton = {
        let button = UIButton()
        button.setImage(.LoginButton.kakaoLogin, for: .normal)
        return button
    }()
    
    private let emailLoginButton: UIButton = {
        let button = UIButton()
        button.setImage(.LoginButton.emailLogin, for: .normal)
        return button
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton()
        
        let text = "또는 새롭게 회원가입 하기"
        let font = UIFont.brandedFont(.title2)
        let color = UIColor.accent
        let attributes: [NSAttributedString.Key : Any] = [
            .font : font,
            .foregroundColor : color
        ]
        
        let title = NSMutableAttributedString(string: text, attributes: attributes)
        title.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: 2))
        
        button.setAttributedTitle(title, for: .normal)
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configureHiararchy() {
        super.configureHiararchy()
        
        modalPresentationStyle = .pageSheet
        sheetPresentationController?.detents = [.custom(resolver: { _ in 290 })]
        sheetPresentationController?.prefersGrabberVisible = true
        
        view.directionalLayoutMargins = .init(top: 35, leading: 35, bottom: 35, trailing: 35)
        
        view.addSubview(buttonStackView)
        
        let components = [appleLoginButton, kakaoLoginButton, emailLoginButton, signUpButton]
        components.forEach { component in
            buttonStackView.addArrangedSubview(component)
        }
    }
    
    override func setConstraints() {
        buttonStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.layoutMarginsGuide)
            make.top.equalTo(view.safeAreaLayoutGuide).inset(42)
        }
        
        appleLoginButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        
        kakaoLoginButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        
        emailLoginButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
    }
}
