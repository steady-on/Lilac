//
//  BaseView.swift
//  Lilac
//
//  Created by Roen White on 1/7/24.
//

import UIKit

class BaseView: UIView {
    init() {
        super.init(frame: .zero)
        
        configureHiararchy()
        setConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureHiararchy() {}
    func setConstraints() {}
}
