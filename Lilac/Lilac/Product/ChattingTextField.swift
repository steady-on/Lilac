//
//  ChattingTextField.swift
//  Lilac
//
//  Created by Roen White on 2/28/24.
//

import UIKit
import RxSwift

final class ChattingTextField: UITextField {
    
    init() {
        super.init(frame: .zero)
        
        configureTextField()
    }
    
    let plusButton: UIButton = {
        let button = UIButton()
        button.setImage(.Icon.plus, for: .normal)
        return button
    }()
    
    let sendButton: UIButton = {
        let button = UIButton()
        button.setImage(.Icon.send, for: .disabled)
        button.setImage(.Icon.sendActive, for: .normal)
        return button
    }()
    
    private let disposeBag = DisposeBag()
    
    private let textInsets = UIEdgeInsets(top: 10, left: 42, bottom: 10, right: 44)
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var padding = super.leftViewRect(forBounds: bounds)
        padding.origin.x = 12
        return padding
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var padding = super.rightViewRect(forBounds: bounds)
        padding.origin.x -= 12
        return padding
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }
    
    private func configureTextField() {
        delegate = self
        backgroundColor = .Background.primary
        layer.cornerRadius = 8
        
        font = .brandedFont(.body)
        textColor = .Text.primary
        
        let attributedPlaceholderString = NSAttributedString(string: "메세지를 입력하세요", attributes: [
            NSAttributedString.Key.foregroundColor : UIColor.Text.secondary
        ])
        attributedPlaceholder = attributedPlaceholderString
        
        clearButtonMode = .never
        
        leftView = plusButton
        leftViewMode = .always
        
        rightView = sendButton
        rightViewMode = .always
        
        rx.text.orEmpty
            .map { $0.isEmpty == false }
            .bind(to: sendButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }

    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ChattingTextField: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text else { return }
        let newText = text.trimmingCharacters(in: .whitespaces)
        self.text = newText
        
        if newText.isEmpty {
            sendButton.setImage(.Icon.send, for: .normal)
        }
    }
}
