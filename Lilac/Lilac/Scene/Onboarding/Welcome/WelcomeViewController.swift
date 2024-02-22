//
//  WelcomeViewController.swift
//  Lilac
//
//  Created by Roen White on 2/16/24.
//

import UIKit
import RxSwift
import RxCocoa

final class WelcomeViewController: BaseViewController {
    
    private let viewModel: WelcomeViewModel
    
    init(viewModel: WelcomeViewModel) {
        self.viewModel = viewModel
        
        super.init()
    }
    
    deinit {
        print("deinit WelcomeViewController")
    }
    
    private let disposeBag = DisposeBag()
    
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

    private let createWorkspaceButton = FilledColorButton(title: "워크스페이스 생성")
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(.Icon.close, for: .normal)
        button.tintColor = .black
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func configureHiararchy() {
        super.configureHiararchy()
        
        messageLabel.text = "\(nickname)님의 조직을 위해 새로운 라일락 워크스페이스를 시작할 준비가 완료되었어요!"
        
        let components = [titleLabel, messageLabel, launchingImageView, createWorkspaceButton]
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
        
        createWorkspaceButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
        }
    }
    
    override func configureNavigationBar() {
        title = "시작하기"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: closeButton)
        
        let barAppearance = UINavigationBarAppearance()
        barAppearance.backgroundColor = .Background.secondary
        navigationItem.scrollEdgeAppearance = barAppearance
    }
    
    override func bind() {
        User.shared.workspaces
            .subscribe(with: self) { owner, workspaces in
                guard workspaces.isEmpty == false else { return }
                owner.moveToHome()
            }
            .disposed(by: disposeBag)
        
        closeButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.moveToHome()
            }
            .disposed(by: disposeBag)
        
        createWorkspaceButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.presentAddWorksapceView()
            }
            .disposed(by: disposeBag)
        
        let input = WelcomeViewModel.Input(closeButtonTapped: closeButton.rx.tap)
        
        let output = viewModel.transform(input: input)
        
        output.goToHome
            .subscribe(with: self) { owner, _ in
                owner.moveToHome()
            }
            .disposed(by: disposeBag)
    }
}

extension WelcomeViewController {
    private func moveToHome() {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let sceneDelegate = windowScene?.delegate as? SceneDelegate
        let rootViewController = WorkspaceTabBarController()
        sceneDelegate?.window?.rootViewController = rootViewController
        sceneDelegate?.window?.makeKeyAndVisible()
    }
    
    private func presentAddWorksapceView() {
        let addWorkspaceView = AddWorkspaceViewController(viewModel: AddWorkspaceViewModel())
        let wrappedNavigationContoller = UINavigationController(rootViewController: addWorkspaceView)
        present(wrappedNavigationContoller, animated: true)
    }
}
