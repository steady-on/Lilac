//
//  HomeEmptyViewController.swift
//  Lilac
//
//  Created by Roen White on 2/22/24.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class HomeEmptyViewController: BaseViewController {
    
    private let disposeBag = DisposeBag()
        
    private let workspaceTitleButton = WorkspaceTitleButton()
    private let profileButton = ProfileButton()
    
    private let titleLabel: BasicLabel = {
        let label = BasicLabel(style: .title1)
        label.text = "워크스페이스를 찾을 수 없어요."
        label.textAlignment = .center
        return label
    }()
    
    private let directionLabel: BasicLabel = {
        let label = BasicLabel(style: .body)
        label.text = "관리자에게 초대를 요청하거나 다른 이메일로 시도하거나\n새로운 워크스페이스를 생성해주세요."
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView(image: .workspaceEmpty)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let createWorkspaceButton = FilledColorButton(title: "워크스페이스 생성")
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configureHiararchy() {
        view.backgroundColor = .Background.secondary
        
        let components = [titleLabel, directionLabel, imageView, createWorkspaceButton]
        components.forEach { component in
            view.addSubview(component)
        }
    }
    
    override func setConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(35)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(24)
        }
        
        directionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(24)
        }
        
        imageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(12)
            make.height.equalTo(imageView.snp.width)
        }
        
        createWorkspaceButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(24)
        }
    }
    
    override func configureNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: workspaceTitleButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileButton)
        
        let barAppearance = UINavigationBarAppearance()
        barAppearance.backgroundColor = .Background.secondary
        navigationItem.scrollEdgeAppearance = barAppearance
    }
    
    override func bind() {
        User.shared.profile
            .asDriver()
            .drive(with: self) { owner, profile in
                owner.setProfileImage(for: profile.profileImage)
            }
            .disposed(by: disposeBag)
        
        User.shared.workspaces
            .subscribe(with: self) { owner, workspaces in
                guard workspaces.isEmpty == false else { return }
                owner.dismiss(animated: false)
            }
            .disposed(by: disposeBag)
        
        createWorkspaceButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.presentAddWorksapceView()
            }
            .disposed(by: disposeBag)
    }
}

extension HomeEmptyViewController {
    private func setProfileImage(for endPoint: String?) {
        let defaultImages: [UIImage] = [.Profile.noPhotoA, .Profile.noPhotoB, .Profile.noPhotoC]
        
        guard let endPoint, let imageURL = URL(string: BaseURL.v1.server + endPoint) else {
            profileButton.setProfile(for: defaultImages.randomElement()!)
            return
        }
        
        KingfisherManager.shared.retrieveImage(with: imageURL) { [unowned self] result in
            switch result {
            case .success(let imageData):
                profileButton.setProfile(for: imageData.image)
            case .failure(_):
                profileButton.setProfile(for: defaultImages.randomElement()!)
            }
        }
    }
    
    private func presentAddWorksapceView() {
        let addWorkspaceView = AddWorkspaceViewController(viewModel: AddWorkspaceViewModel())
        let wrappedNavigationContoller = UINavigationController(rootViewController: addWorkspaceView)
        present(wrappedNavigationContoller, animated: true)
    }
}
