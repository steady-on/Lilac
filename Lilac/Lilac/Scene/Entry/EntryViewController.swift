//
//  EntryViewController.swift
//  Lilac
//
//  Created by Roen White on 1/25/24.
//

import UIKit

final class EntryViewController: BaseViewController {
    
    deinit {
        print("deinit EntryViewController")
    }
    
    private let viewModel: EntryViewModel
    
    init(viewModel: EntryViewModel) {
        self.viewModel = viewModel
        
        super.init()
    }
    
    private let disposeBag = DisposeBag()
    
    private let appIconImageView = UIImageView(image: .splash)
    private let appNameLabel = BasicLabel(style: .title1)

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func configureHiararchy() {
        super.configureHiararchy()
        
        let components = [appIconImageView, appNameLabel]
        components.forEach { component in
            view.addSubview(component)
        }
        
        appIconImageView.contentMode = .scaleAspectFit
        appNameLabel.text = "Lilac"
    }
    
    override func setConstraints() {
        appIconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.6)
            make.height.equalTo(appIconImageView.snp.width)
        }
        
        appNameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(50)
        }
    }
    
    }
}

}
