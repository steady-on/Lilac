//
//  Label.swift
//  Lilac
//
//  Created by Roen White on 1/5/24.
//

import UIKit

class Label: UILabel {
    var fontStyle: UIFont.Style {
        didSet {
            font = .brandedFont(fontStyle)
        }
    }
    
    override var text: String? {
        didSet { setLineHeight() }
    }
    
    init(style: UIFont.Style) {
        fontStyle = style
        
        super.init(frame: .zero)
        font = .brandedFont(fontStyle)
    }
    
    private func setLineHeight() {
        guard let text else { return }
        let lineHeight = fontStyle.lineHeight
        
        let style = NSMutableParagraphStyle()
        style.maximumLineHeight = lineHeight
        style.minimumLineHeight = lineHeight
        
        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: style,
            .baselineOffset: (lineHeight - font.lineHeight) / 2
        ]
        
        let attrString = NSAttributedString(string: text, attributes: attributes)
        self.attributedText = attrString
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
