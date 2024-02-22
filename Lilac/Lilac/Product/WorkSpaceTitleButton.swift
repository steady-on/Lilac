//
//  WorkSpaceTitleButton.swift
//  Lilac
//
//  Created by Roen White on 2/22/24.
//

import UIKit

final class WorkSpaceTitleButton: UIButton {
    init() {
        super.init(frame: .zero)
        
        configureButton()
    }
    
    private func configureButton() {
        var config = UIButton.Configuration.plain()
        config.imagePadding = 8
        config.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        config.titleTextAttributesTransformer = .init { _ in
            return .init([
                .font : UIFont.brandedFont(.title1),
                .foregroundColor : UIColor.label
            ])
        }
        
        config.titleAlignment = .leading
        
        configuration = config
        
        imageView?.layer.cornerRadius = 8
        imageView?.backgroundColor = .accent
    }
    
    func setWorkSpace(for name: String, thumbnail: UIImage?) {
        configuration?.image = thumbnail?.resize(targetSize: .init(width: 32, height: 32))
        configuration?.attributedTitle = AttributedString(name)
    }
    
    func setEmpty() {
        configuration?.image = UIImage.WorkSpace.default.resize(targetSize: .init(width: 32, height: 32))
        configuration?.attributedTitle = AttributedString("No Workspace")
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
