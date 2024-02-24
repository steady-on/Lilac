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
    
    private var collectionView: UICollectionView! = nil
    private var dataSource: UICollectionViewDiffableDataSource<Header, Item>! = nil
    
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
        
        configureCollectionView()
        configureDataSource()
        configureInitialSnapshot()
        // TODO: DM 기능 개발 시 적절한 타이밍에 호출하도록 함
        configureDMSnapshot()
        
        view.addSubview(collectionView)
    }
    
    override func setConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
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

// MARK: Related CollectionView
extension HomeViewController {
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
    }
    
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { _, layoutEnvironment in
            var configuration = UICollectionLayoutListConfiguration(appearance: .sidebar)
            configuration.headerMode = .firstItemInSection
            configuration.backgroundColor = .Background.secondary
            configuration.itemSeparatorHandler = { indexPath, listSeparatorConfiguration in
                var configuration = listSeparatorConfiguration
                
                if indexPath.row == indexPath.startIndex {
                    configuration.topSeparatorVisibility = .visible
                    configuration.bottomSeparatorVisibility = .hidden
                    configuration.topSeparatorInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
                }
                
                return configuration
            }
            
            let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
            section.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
            
            return section
        }
    }
}

// MARK: Relataed DataSource
extension HomeViewController {
    private func createHeaderRegistration() ->  UICollectionView.CellRegistration<UICollectionViewListCell, String> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, String> { cell, indexPath, item in
            var content = cell.defaultContentConfiguration()
            content.text = item
            content.textProperties.font = .brandedFont(.title2)
            
            cell.contentConfiguration = content
            cell.accessories = [.outlineDisclosure(options: .init(style: .header, tintColor: .black))]
            cell.directionalLayoutMargins = .init(top: 12, leading: 16, bottom: 12, trailing: 16)
        }
    }
    
    private func createFooterRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, String> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, String> { cell, indexPath, item in
            var content = cell.defaultContentConfiguration()
            content.text = item
            content.textProperties.font = .brandedFont(.body)
            content.textProperties.color = .Text.secondary
            
            content.image = .Icon.plus
            content.imageToTextPadding = 8
            content.imageProperties.maximumSize = .init(width: 18, height: 18)
            
            cell.contentConfiguration = content
            cell.directionalLayoutMargins = .init(top: 8, leading: 20, bottom: 8, trailing: 20)
        }
    }
    
    private func createCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Item> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, Item> { cell, indexPath, item in
            var content = cell.defaultContentConfiguration()
            content.text = item.text
            content.textProperties.font = .brandedFont(.body)
            content.textProperties.color = .Text.secondary
            
            content.image = .Hashtag.thin
            content.imageToTextPadding = 8
            content.imageProperties.maximumSize = .init(width: 18, height: 18)

            cell.contentConfiguration = content
            cell.directionalLayoutMargins = .init(top: 8, leading: 20, bottom: 8, trailing: 20)
        }
    }
    
    private func configureDataSource() {
        let headerRegistration = createHeaderRegistration()
        let footerRegistration = createFooterRegistration()
        let cellRegistration = createCellRegistration()
        
        dataSource = UICollectionViewDiffableDataSource<Header, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            switch item.type {
            case .header:
                return collectionView.dequeueConfiguredReusableCell(using: headerRegistration, for: indexPath, item: item.text)
            case .footer:
                return collectionView.dequeueConfiguredReusableCell(using: footerRegistration, for: indexPath, item: item.text)
            case .item:
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
            }
        }
    }
}

// MARK: Related Snapshot
extension HomeViewController {
    private func configureInitialSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Header, Item>()
        snapshot.appendSections(Header.allCases)
        dataSource.apply(snapshot)
        
        var sectionMemberSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        let memberFooterItem = Item(from: .inviteMember)
        sectionMemberSnapshot.append([memberFooterItem])
        dataSource.apply(sectionMemberSnapshot, to: .member)
    }
    
    private func configureChannelSnapshot(for channels: [Channel]) {
        var sectionChannelSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        let channelHeaderItem = Item(from: .channel)
        let channelFooterItem = Item(from: .addChannel)
        sectionChannelSnapshot.append([channelHeaderItem])
        
        sectionChannelSnapshot.append(channels.map { Item(from: $0) } + [channelFooterItem], to: channelHeaderItem)
        sectionChannelSnapshot.expand([channelHeaderItem])
        dataSource.apply(sectionChannelSnapshot, to: .channel)
    }
    
    // TODO: DM 기능 개발 시 매개변수로 DM 배열을 넘기도록 함
    private func configureDMSnapshot() {
        var sectionDMSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        let dmHeaderItem = Item(from: .directMessage)
        let dmFooterItem = Item(from: .newMessage)
        sectionDMSnapshot.append([dmHeaderItem])
        
        sectionDMSnapshot.append([dmFooterItem], to: dmHeaderItem)
        sectionDMSnapshot.expand([dmHeaderItem])
        dataSource.apply(sectionDMSnapshot, to: .directMessage)
    }
}

extension HomeViewController {
    private func coverToEmptyWorkspace() {
        let workspaceEmptyView = HomeEmptyViewController()
        let wrappedNavigationController = UINavigationController(rootViewController: workspaceEmptyView)
        wrappedNavigationController.modalPresentationStyle = .overFullScreen
        present(wrappedNavigationController, animated: false)
    }
}

// MARK: Related Setting Image
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

// MARK: Related KingFisher
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
