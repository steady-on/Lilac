//
//  HomeViewController.swift
//  Lilac
//
//  Created by Roen White on 2/19/24.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class HomeViewController: BaseViewController {
    
    private let disposeBag = DisposeBag()
    
    private let workspaceTitleButton = WorkspaceTitleButton()
    private let profileButton = ProfileButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureKingFisherDefaultOptions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        User.shared.workspaces
            .asDriver()
            .drive(with: self) { owner, workspaces in
                guard workspaces.isEmpty == false else {
                    owner.coverToEmptyWorkspace()
                    return
                }
            }
            .disposed(by: disposeBag)
    }
    
    override func configureHiararchy() {
        view.backgroundColor = .Background.secondary
        definesPresentationContext = true
        
    }
    
    override func configureNavigationBar() {
        let titleView = UIView()
        titleView.addSubview(workspaceTitleButton)
        workspaceTitleButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileButton)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleView)
        
        let barAppearance = UINavigationBarAppearance()
        barAppearance.backgroundColor = .Background.secondary
        navigationItem.scrollEdgeAppearance = barAppearance
        
        setWorkspaceTitleButton()
    }
    
    override func bind() {
        User.shared.profile
            .asDriver()
            .drive(with: self) { owner, profile in
                owner.setProfileImage(for: profile.profileImage)
            }
            .disposed(by: disposeBag)
    }
}

extension HomeViewController {
    private func configureKingFisherDefaultOptions() {
        @KeychainStorage(itemType: .accessToken) var accessToken
        
        guard let accessToken else { return }
        
        let modifier = AnyModifier { request in
            var request = request
            request.setValue(accessToken, forHTTPHeaderField: "Authorization")
            request.setValue(APIKey.secretKey, forHTTPHeaderField: "SesacKey")
            return request
        }
        
        KingfisherManager.shared.defaultOptions += [.requestModifier(modifier)]
    }
    
    private func coverToEmptyWorkspace() {
        let workspaceEmptyView = HomeEmptyViewController()
        let wrappedNavigationController = UINavigationController(rootViewController: workspaceEmptyView)
        wrappedNavigationController.modalPresentationStyle = .overFullScreen
        present(wrappedNavigationController, animated: false)
    }
}

extension HomeViewController {
    private func setProfileImage(for endPoint: String?) {
        let defaultImages: [UIImage] = [.Profile.noPhotoA, .Profile.noPhotoB, .Profile.noPhotoC]
        
        loadServerImage(to: endPoint) { [unowned self] image in
            guard let image else {
                profileButton.setProfile(for: defaultImages.randomElement()!)
                return
            }
            
            profileButton.setProfile(for: image)
        }
    }
    
    private func setWorkspaceTitleButton() {
        guard let workspace = User.shared.selectedWorkspace else { return }
        
        loadServerImage(to: workspace.thumbnail) { [unowned self] image in
            workspaceTitleButton.setWorkspace(for: workspace.name, thumbnail: image)
        }
    }
}

extension HomeViewController {
    private func loadServerImage(to endPoint: String?, completion: @escaping (UIImage?) -> Void) {
        guard let endPoint, let imageURL = URL(string: BaseURL.v1.server + endPoint) else {
            completion(nil)
            return
        }
        
        KingfisherManager.shared.retrieveImage(with: imageURL) { result in
            switch result {
            case .success(let imageData):
                completion(imageData.image)
            case .failure(_):
                completion(nil)
            }
        }
    }
}
