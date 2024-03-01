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
    
    private let viewModel: HomeViewModel
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    private let disposeBag = DisposeBag()
    private let isRefresh = PublishRelay<Void>()
    
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
        
        isWorkspaceEmpty()
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
    }
    
    override func bind() {
        User.shared.profile
            .asDriver()
            .drive(with: self) { owner, profile in
                owner.setProfileImage(for: profile.profileImage)
            }
            .disposed(by: disposeBag)
        
        profileButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.pushMyInfoView()
            }
            .disposed(by: disposeBag)
        
        let input = HomeViewModel.Input(
            isRefresh: isRefresh
        )
        
        let output = viewModel.transform(input: input)
        
        output.selectedWorkspace
            .subscribe(with: self) { owner, workspace in
                owner.setWorkspaceTitleButton(for: workspace.name, thumbnail: workspace.thumbnail)
                owner.configureChannelSnapshot(for: workspace.channels)
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
        collectionView.delegate = self
        
        configureRefreshControl()
    }
    
    private func configureRefreshControl() {
        let refreshControl = UIRefreshControl()
        
        refreshControl.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        refreshControl.tintColor = .accent
        refreshControl.attributedTitle = NSAttributedString(
                string: "당겨서 새로고침",
                attributes: [.foregroundColor : UIColor.Text.secondary]
            )
        
        collectionView.refreshControl = refreshControl
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

// MARK: Related CollectionView RefreshContol
extension HomeViewController {
    @objc private func handleRefreshControl() {
        isRefresh.accept(())
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [unowned self] in
            collectionView.refreshControl?.endRefreshing()
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
    
    private func createChannelCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Item> {
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
    
    private func createDMCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Item> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, Item> { [unowned self] cell, indexPath, item in
            var content = cell.defaultContentConfiguration()
            content.text = item.text
            content.textProperties.font = .brandedFont(.body)
            content.textProperties.color = .Text.secondary
            
            loadServerImage(to: item.image) { image in
                content.image = image ?? .Profile.noPhotoC
            }
            
            content.imageToTextPadding = 8
            content.imageProperties.maximumSize = .init(width: 24, height: 24)

            cell.contentConfiguration = content
            cell.directionalLayoutMargins = .init(top: 8, leading: 20, bottom: 8, trailing: 20)
        }
    }
    
    private func configureDataSource() {
        let headerRegistration = createHeaderRegistration()
        let footerRegistration = createFooterRegistration()
        let channelCellRegistration = createChannelCellRegistration()
        let dmCellRegistration = createDMCellRegistration()
        
        dataSource = UICollectionViewDiffableDataSource<Header, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            switch item.type {
            case .header:
                return collectionView.dequeueConfiguredReusableCell(using: headerRegistration, for: indexPath, item: item.text)
            case .footer:
                return collectionView.dequeueConfiguredReusableCell(using: footerRegistration, for: indexPath, item: item.text)
            case .channel:
                return collectionView.dequeueConfiguredReusableCell(using: channelCellRegistration, for: indexPath, item: item)
            case .dm:
                return collectionView.dequeueConfiguredReusableCell(using: dmCellRegistration, for: indexPath, item: item)
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
    
    private func configureChannelSnapshot(for channels: [Channel]?) {
        let channels = channels?.map({ Item(from: $0) }) ?? []
        
        var sectionChannelSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        let channelHeaderItem = Item(from: .channel)
        let channelFooterItem = Item(from: .addChannel)
        sectionChannelSnapshot.append([channelHeaderItem])
        
        sectionChannelSnapshot.append(channels + [channelFooterItem], to: channelHeaderItem)
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

// MARK: Related HomeEmptyView
extension HomeViewController {
    private func isWorkspaceEmpty() {
        guard User.shared.isNotBelongToWorkspace else { return }
        coverToEmptyWorkspace()
    }
    
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
    
    private func setWorkspaceTitleButton(for name: String, thumbnail: String) {
        loadServerImage(to: thumbnail) { [unowned self] image in
            workspaceTitleButton.setWorkspace(for: name, thumbnail: image)
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

// MARK: Related Channel Selected
extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        switch item.type {
        case .footer:
            print("Footer:", item.text)
        case .channel:
            pushChannelView(for: item)
        case .dm:
            print("dm 클릭")
        default:
            break
        }
    }
    
    /// ChannelView로 이동
    private func pushChannelView(for item: Item) {
        let channelViewModel = ChannelViewModel(channelId: item.id, workspaceId: item.workspaceId, channelName: item.text)
        let channelView = ChannelViewController(viewModel: channelViewModel)
        navigationItem.backButtonDisplayMode = .minimal
        navigationController?.pushViewController(channelView, animated: true)
    }
}

extension HomeViewController {
    private func pushMyInfoView() {
        let myInfoView = MyInfoViewController(viewModel: MyInfoViewModel())
        navigationItem.backButtonDisplayMode = .minimal
        navigationController?.pushViewController(myInfoView, animated: true)
    }
}
