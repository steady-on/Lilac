//
//  ChattingContentLabel.swift
//  Lilac
//
//  Created by Roen White on 2/29/24.
//

import UIKit

final class ChattingContentLabel: BasicLabel {
    init() {
        super.init(style: .body)
        configure()
    }
    
    private let textInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    
    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.height += textInset.top + textInset.bottom
        contentSize.width += textInset.left + textInset.right
        return contentSize
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInset))
    }
    
    private func configure() {
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.Brand.inactive.cgColor
        
        numberOfLines = 0
        lineBreakStrategy = .hangulWordPriority
        lineBreakMode = .byWordWrapping
    }
}
