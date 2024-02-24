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
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureKingFisherDefaultOptions()
        
        guard let channels = User.shared.selectedWorkspace?.channels else {
            print("채널 없음")
            return
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(Section.allCases)
        dataSource.apply(snapshot)
        
        var sectionChannelSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        let channelHeaderItem = Item(from: .channel)
        let channelFooterItem = Item(from: .addChannel)
        sectionChannelSnapshot.append([channelHeaderItem])
        
        sectionChannelSnapshot.append(channels.map { Item(from: $0) } + [channelFooterItem], to: channelHeaderItem)
        sectionChannelSnapshot.expand([channelHeaderItem])
        dataSource.apply(sectionChannelSnapshot, to: .channel)
        
        var sectionDMSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        let dmHeaderItem = Item(from: .directMessage)
        let dmFooterItem = Item(from: .newMessage)
        sectionDMSnapshot.append([dmHeaderItem])
        
        sectionDMSnapshot.append([dmFooterItem], to: dmHeaderItem)
        sectionDMSnapshot.expand([dmHeaderItem])
        dataSource.apply(sectionDMSnapshot, to: .directMessage)
        
        var sectionMemberSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        let memberFooterItem = Item(from: .inviteMember)
        sectionMemberSnapshot.append([memberFooterItem])
        dataSource.apply(sectionMemberSnapshot, to: .member)
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

extension HomeViewController {
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

extension HomeViewController {
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
    }
    
    private func configureDataSource() {
        let headerRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, String> { cell, indexPath, item in
            var content = cell.defaultContentConfiguration()
            content.text = item
            content.textProperties.font = .brandedFont(.title2)
            
            cell.contentConfiguration = content
            cell.accessories = [.outlineDisclosure(options: .init(style: .header, tintColor: .black))]
            cell.directionalLayoutMargins = .init(top: 12, leading: 16, bottom: 12, trailing: 16)
        }
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { cell, indexPath, item in
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
        
        let footerRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, String> { cell, indexPath, item in
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
        
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
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

extension HomeViewController {
    enum Section: Int, CaseIterable {
        case channel
        case directMessage
        case member
        
        var title: String {
            switch self {
            case .channel: return "채널"
            case .directMessage: return "다이렉트 메시지"
            case .member: return ""
            }
        }
    }
    
    enum Footer: Int {
        case addChannel
        case newMessage
        case inviteMember
        
        var title: String {
            switch self {
            case .addChannel: return "채널 추가"
            case .newMessage: return "새 메시지 시작"
            case .inviteMember: return "팀원 추가"
            }
        }
    }
    
    struct Item: Hashable {
        let id: Int
        let text: String
        let image: String?
        let type: ItemType
//        let unreads: Int?
        
        init(id: Int, text: String, image: String?, type: ItemType) {
            self.id = id
            self.text = text
            self.image = image
//            self.unreads = unreads
            self.type = type
        }
        
        init(from section: Section) {
            self.init(id: section.rawValue, text: section.title, image: nil, type: .header)
        }
        
        init(from channel: Channel) {
            self.init(id: channel.channelId, text: channel.name, image: nil, type: .item)
        }
        
        init(from footer: Footer) {
            self.init(id: footer.rawValue, text: footer.title, image: nil, type: .footer)
        }
        
        enum ItemType {
            case header
            case footer
            case item
        }
    }
}
