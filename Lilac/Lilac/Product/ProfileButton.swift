//
//  ProfileButton.swift
//  Lilac
//
//  Created by Roen White on 2/22/24.
//

import UIKit

final class ProfileButton: UIButton {
    init() {
        super.init(frame: .init(x: 0, y: 0, width: 32, height: 32))
        
        configureButton()
    }
    
    private func configureButton() {
        var config = UIButton.Configuration.plain()
        config.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        configuration = config
        
        imageView?.backgroundColor = .accent
        imageView?.contentMode = .scaleAspectFill
        
        layer.borderColor = UIColor.View.selected.cgColor
        layer.borderWidth = 2
        layer.cornerRadius = frame.width / 2
        clipsToBounds = true
    }
    
    func setProfile(for image: UIImage) {
        configuration?.image = image.resize(targetSize: .init(width: 32, height: 32))
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
