//
//  BaseViewController.swift
//  Lilac
//
//  Created by Roen White on 1/7/24.
//

import UIKit

class BaseViewController: UIViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHiararchy()
        setConstraints()
        bind()
        configureNavigationBar()
    }

    func configureHiararchy() {
        view.backgroundColor = .Background.primary
    }
    
    func setConstraints() {}
    
    func bind() {}
    
    func configureNavigationBar() {}
}

