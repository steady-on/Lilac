//
//  FilledColorButton.swift
//  Lilac
//
//  Created by Roen White on 1/12/24.
//

import UIKit

final class FilledColorButton: UIButton {
    init(title: String, action: UIAction, color: UIColor = .accent) {
        super.init(frame: .zero)
        
        setTitle(title, for: .normal)
        addAction(action, for: .touchUpInside)
        configureButton(color: color)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureButton(color: UIColor) {
        var config = UIButton.Configuration.filled()
        config.background.cornerRadius = 8
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
        
        setTitleColor(.white, for: .normal)
        setTitleColor(.white, for: .disabled)
        
        titleLabel?.font = .brandedFont(.title2)
    }
}
