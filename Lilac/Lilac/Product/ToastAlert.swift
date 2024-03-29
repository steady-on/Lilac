//
//  ToastAlert.swift
//  Lilac
//
//  Created by Roen White on 1/8/24.
//

import UIKit
import SnapKit

final class ToastAlert: BasicLabel {
    
    private let style: Style
    
    private init(message: String, style: Style) {
        self.style = style
        super.init(style: .body)
        configureLabel(message)
    }
    
    convenience init(toast: Toast) {
        self.init(message: toast.message, style: toast.style)
    }
    
    private let textInsets = UIEdgeInsets(top: 9, left: 16, bottom: 9, right: 16)
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetRect = bounds.inset(by: textInsets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textInsets.top, left: -textInsets.left, bottom: -textInsets.bottom, right: -textInsets.right)
        
        return textRect.inset(by: invertedInsets)
    }
    
    private func configureLabel(_ message: String) {
        self.text = message
        self.textColor = .white
        self.backgroundColor = style.backgroundColor
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
        self.numberOfLines = 0
    }
}

extension ToastAlert {
    enum Style {
        case success
        case caution
        
        var backgroundColor: UIColor {
            switch self {
            case .success: return .accent
            case .caution: return .Brand.error
            }
        }
    }
    
    struct Toast {
        let message: String
        let style: Style
    }
    
    enum Position {
        case high
        case low
    }
}
