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

    private let createWorkSpaceButton = FilledColorButton(title: "워크스페이스 생성")
    
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
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: closeButton)
        
        let barAppearance = UINavigationBarAppearance()
        barAppearance.backgroundColor = .Background.secondary
        navigationItem.scrollEdgeAppearance = barAppearance
    }
    
    override func bind() {
        createWorkSpaceButton.rx.tap
            .asDriver()
            .drive(with: self) { owner, _ in
                let addWorkSpaceView = AddWorkSpaceViewController(viewModel: AddWorkSpaceViewModel())
                let wrappedNavigationContoller = UINavigationController(rootViewController: addWorkSpaceView)
                owner.present(wrappedNavigationContoller, animated: true)
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
        // TODO: 추후 Home Default 화면으로 이동
        let navigationController = UINavigationController(rootViewController: ViewController())
        sceneDelegate?.window?.rootViewController = navigationController
        sceneDelegate?.window?.makeKeyAndVisible()
    }
}
