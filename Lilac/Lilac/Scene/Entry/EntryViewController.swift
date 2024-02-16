//
//  EntryViewController.swift
//  Lilac
//
//  Created by Roen White on 1/25/24.
//

import UIKit
import RxSwift

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
    
    override func bind() {
        let output = viewModel.transform(input: .init())
        
        output.goToOnboarding
            .bind(with: self) { owner, goToOnboarding in
                guard goToOnboarding else { return }
                
                owner.moveToOnboardingView()
            }
            .disposed(by: disposeBag)
        
        output.goToHome
            .bind(with: self) { owner, _ in
                owner.moveToHomeView()
            }
            .disposed(by: disposeBag)
    }
}

extension EntryViewController {
    private func moveToOnboardingView() {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let sceneDelegate = windowScene?.delegate as? SceneDelegate
        let rootViewController = OnboardingViewController()
        sceneDelegate?.window?.rootViewController = rootViewController
        sceneDelegate?.window?.makeKeyAndVisible()
    }
    
    // TODO: HomeView 만들고 수정
    private func moveToHomeView() {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let sceneDelegate = windowScene?.delegate as? SceneDelegate
        let rootViewController = ViewController()
        sceneDelegate?.window?.rootViewController = rootViewController
        sceneDelegate?.window?.makeKeyAndVisible()
    }
}
