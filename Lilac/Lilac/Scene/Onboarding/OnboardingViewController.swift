//
//  OnboardingViewController.swift
//  Lilac
//
//  Created by Roen White on 1/12/24.
//

import UIKit

final class OnboardingViewController: BaseViewController {
    
    private let messageLabel: BasicLabel = {
        let label = BasicLabel(style: .title1)
        label.text = "새싹톡을 사용하면 어디서나\n팀을 모을 수 있습니다"
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let onboardingImageView = UIImageView(image: .onboarding)
    
    private let startButton = FilledColorButton(title: "시작하기", action: UIAction { _ in  })

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func configureHiararchy() {
        super.configureHiararchy()
        
        let components = [messageLabel, onboardingImageView, startButton]
        components.forEach { component in
            view.addSubview(component)
        }
    }
    
    override func setConstraints() {
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(24)
        }
        
        onboardingImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(12)
            make.height.equalTo(onboardingImageView.snp.width).multipliedBy(1)
        }
        
        startButton.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide).inset(24)
        }
    }
}
