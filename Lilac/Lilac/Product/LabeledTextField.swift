//
//  LabeledTextField.swift
//  Lilac
//
//  Created by Roen White on 1/16/24.
//

import UIKit

final class LabeledTextField: UITextField {

    private let titleLabel: BasicLabel = {
        let label = BasicLabel(style: .title2)
        return label
    }()
    
    init(title: String) {
        titleLabel.text = title
        
        super.init(frame: .zero)
        configureTextField()
    }
    
    var isValid: Bool = true {
        didSet { reflectValidState() }
    }
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .Background.secondary
        view.layer.cornerRadius = 8
        return view
    }()
    
    private var labelHeight: CGFloat { titleLabel.fontStyle.lineHeight }
    private let spacing: CGFloat = 8
    private var textInsets: UIEdgeInsets {
        UIEdgeInsets(top: labelHeight + spacing + 14, left: 12, bottom: 14, right: 12)
    }
    private let textFieldHeight: CGFloat = 18
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: bounds.width, height: textInsets.top + textFieldHeight + textInsets.bottom)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.frame = CGRect(x: 0, y: 0, width: bounds.width, height: labelHeight)
        backgroundView.frame = CGRect(x: 0, y: labelHeight + spacing, width: bounds.width, height: 44)
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
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LabeledTextField {
    private func configureTextField() {
        font = .brandedFont(.body)
        
        let components = [backgroundView, titleLabel]
        components.forEach { component in
            component.isUserInteractionEnabled = false
            addSubview(component)
        }
    }
}

extension LabeledTextField {
    private func reflectValidState() {
        titleLabel.textColor = isValid ? .black : .Brand.error
    }
    
    
}
