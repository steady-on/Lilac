//
//  WelcomeViewController.swift
//  Lilac
//
//  Created by Roen White on 2/16/24.
//

import UIKit

final class WelcomeViewController: BaseViewController {
    
    deinit {
        print("deinit WelcomeViewController")
    }
    
    @UserDefault(key: .nickname, defaultValue: "") var nickname
    
    private let titleLabel: BasicLabel = {
        let label = BasicLabel(style: .title1)
        label.text = "출시 준비 완료"
        label.textAlignment = .center
        return label
    }()
    
    private let messageLabel: BasicLabel = {
        let label = BasicLabel(style: .body)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let launchingImageView: UIImageView = {
        let imageView = UIImageView(image: .launching)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let createWorkSpaceButton = FilledColorButton(title: "워크스페이스 생성")
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func configureHiararchy() {
        super.configureHiararchy()
        
        messageLabel.text = "\(nickname)님의 조직을 위해 새로운 라일락 워크스페이스를 시작할 준비가 완료되었어요!"
        
        let components = [titleLabel, messageLabel, launchingImageView, createWorkSpaceButton]
        components.forEach { component in
            view.addSubview(component)
        }
    }
    
    override func setConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(35)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(24)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(24)
        }
        
        launchingImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(12)
        }
        
        createWorkSpaceButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
        }
    }
    
    override func configureNavigationBar() {
        title = "시작하기"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .Icon.close, style: .plain, target: self, action: #selector(closeButtonTapped))
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        let barAppearance = UINavigationBarAppearance()
        barAppearance.backgroundColor = .Background.secondary
        navigationItem.scrollEdgeAppearance = barAppearance
    }
}

extension WelcomeViewController {
    @objc private func closeButtonTapped() {
        print("Tap Close")
    }
}

