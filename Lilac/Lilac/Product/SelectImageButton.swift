//
//  SelectImageButton.swift
//  Lilac
//
//  Created by Roen White on 2/19/24.
//

import UIKit

final class SelectImageButton: UIButton {
    private let baseImage: UIImage?
    private var firstLayout = true
    
    init(baseImage: UIImage?) {
        self.baseImage = baseImage
        
        super.init(frame: .init(x: 0, y: 0, width: 70, height: 70))
        
        configureButton()
    }
    
    private let badgeImage = UIImageView(image: .Button.camera)
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: bounds.width, height: bounds.height)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        overlayBadge()
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let newArea = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: badgeImage.frame.maxX, height: badgeImage.frame.maxY)
        
        return newArea.contains(point)
    }
    
    private func configureButton() {
        addSubview(badgeImage)
        badgeImage.isUserInteractionEnabled = false
        
        let image = baseImage ?? .WorkSpace.default
        
        var config = UIButton.Configuration.filled()
        config.background.cornerRadius = 8
        configuration = config
        
        setImage(image, for: .normal)
    }
    
    private func overlayBadge() {
        badgeImage.frame = CGRect(x: bounds.width * 0.8, y: bounds.height * 0.8, width: bounds.width * 0.35, height: bounds.height * 0.35)
        bringSubviewToFront(badgeImage)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SelectImageButton {
    func changeImage(for image: UIImage?) {
        let imageSize = CGSize(width: bounds.width, height: bounds.height)
        let resizedImage = image?.resize(targetSize: imageSize)

        imageView?.contentMode = .scaleToFill
        imageView?.clipsToBounds = true
        imageView?.layer.cornerRadius = 8
        
        setImage(resizedImage, for: .normal)
    }
}
