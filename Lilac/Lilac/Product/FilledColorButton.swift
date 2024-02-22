//
//  FilledColorButton.swift
//  Lilac
//
//  Created by Roen White on 1/12/24.
//

import UIKit

final class FilledColorButton: UIButton {
    init(title: String, baseColor: UIColor = .accent) {
        super.init(frame: .zero)
        
        configureButton(title: title, color: baseColor)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.height = 44
        return size
    }
    
    private func configureButton(title: String, color: UIColor) {
        var config = UIButton.Configuration.filled()
        config.background.cornerRadius = 8
        config.attributedTitle = AttributedString(title)
        
        config.titleTextAttributesTransformer = .init { _ in
            return .init([
                .font : UIFont.brandedFont(.title2),
                .foregroundColor : UIColor.white
            ])
        }
        
        configuration = config
        
        let updateHandler: UIButton.ConfigurationUpdateHandler = { button in
            switch button.state {
            case .disabled:
                button.configuration?.background.backgroundColor = .Brand.inactive
            default:
                button.configuration?.background.backgroundColor = color
            }
        }
        
        configurationUpdateHandler = updateHandler
    }
}
