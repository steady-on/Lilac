//
//  MyInfoViewController.swift
//  Lilac
//
//  Created by Roen White on 3/1/24.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class MyInfoViewController: BaseViewController {
    
    private let viewModel: MyInfoViewModel
    
    init(viewModel: MyInfoViewModel) {
        self.viewModel = viewModel
        
        super.init()
    }
    
    private let disposeBag = DisposeBag()
    
    private let profilePhotoButton = SelectImageButton(baseImage: nil)
    
    private let infoTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.backgroundColor = .Background.primary
        tableView.separatorStyle = .none
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    private var dataSource: UITableViewDiffableDataSource<Section, Item>! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configureHiararchy() {
        super.configureHiararchy()
        
        configureDataSource()
        
        let components = [profilePhotoButton, infoTableView]
        components.forEach { component in
            view.addSubview(component)
        }
    }
    
    override func setConstraints() {
        profilePhotoButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
        }
        
        infoTableView.snp.makeConstraints { make in
            make.top.equalTo(profilePhotoButton.snp.bottom).offset(12)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func configureNavigationBar() {
        navigationItem.title = "내 정보 수정"
        navigationController?.navigationBar.tintColor = .black
        
        let barAppearance = UINavigationBarAppearance()
        barAppearance.backgroundColor = .Background.secondary
        navigationItem.scrollEdgeAppearance = barAppearance
    }
    
    override func bind() {
        let input = MyInfoViewModel.Input()
        
        let output = viewModel.transform(input: input)
        
        output.myProfile
            .subscribe(with: self) { owner, myProfile in
                owner.setProfileImage(for: myProfile.profileImage)
                owner.configureSnapshot(for: myProfile)
            }
            .disposed(by: disposeBag)
    }
}

extension MyInfoViewController {
    enum Section: CaseIterable {
        case info
        case account
    }
    
    enum ItemType {
        case coin(count: Int)
        case nickname(String)
        case contact(String)
        case email(String)
        case logout
        
        var text: String {
            switch self {
            case .coin: return "내 새싹 코인"
            case .nickname: return "닉네임"
            case .contact: return "연락처"
            case .email: return "이메일"
            case .logout: return "로그아웃"
            }
        }
        
        var secondatyText: String {
            switch self {
            case .coin: return "충전하기"
            case .nickname(let nickname): return "\(nickname)"
            case .contact(let contact): return "\(contact)"
            case .email(let email): return "\(email)"
            default: return ""
            }
        }
    }
    
    struct Item: Hashable {
        let id = UUID()
        let type: ItemType
        let section: Section
        
        func hash(into hasher: inout Hasher) {}
        
        static func == (lhs: MyInfoViewController.Item, rhs: MyInfoViewController.Item) -> Bool {
            lhs.id == rhs.id
        }
        
        init(type: ItemType, section: Section) {
            self.type = type
            self.section = section
        }
    }
}

extension MyInfoViewController {
    private func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, Item>(tableView: infoTableView) { tableView, indexPath, item in
            let cell = UITableViewCell()
            
            var content = cell.defaultContentConfiguration()
            
            switch item.type {
            case .coin(let count):
                let text = NSMutableAttributedString(
                    string: "\(item.type.text) \(count)",
                    attributes: [
                        .font : UIFont.brandedFont(.bodyBold),
                        .foregroundColor : UIColor.accent
                    ]
                )
                
                text.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: 6))
                
                content.attributedText = text
            default:
                content.text = item.type.text
                content.textProperties.font = .brandedFont(.bodyBold)
                content.textProperties.color = .Text.primary
            }
            
            content.secondaryText = item.type.secondatyText
            content.secondaryTextProperties.font = .brandedFont(.body)
            content.secondaryTextProperties.color = .Text.secondary
            
            content.prefersSideBySideTextAndSecondaryText = true
            
            cell.contentConfiguration = content
            
            if case Section.info = item.section {
                cell.accessoryType = .disclosureIndicator
            }
            
            return cell
        }
    }
    
    private func configureSnapshot(for profile: MyProfile) {
        let infoItems = [
            Item(type: .coin(count: profile.sesacCoin ?? 0), section: .info),
            Item(type: .nickname(profile.nickname), section: .info),
            Item(type: .contact(profile.phone ?? ""), section: .info)
        ]
        
        let accountItems = [
            Item(type: .email(profile.email), section: .account),
            Item(type: .logout, section: .account)
        ]
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(infoItems, toSection: .info)
        snapshot.appendItems(accountItems, toSection: .account)
        
        dataSource.apply(snapshot)
    }
}

extension MyInfoViewController {
    private func setProfileImage(for endPoint: String?) {
        let defaultImages: [UIImage] = [.Profile.noPhotoA, .Profile.noPhotoB, .Profile.noPhotoC]
        
        loadServerImage(to: endPoint) { [unowned self] image in
            guard let image else {
                profilePhotoButton.changeImage(for: defaultImages.randomElement()!)
                return
            }
            
            profilePhotoButton.changeImage(for: image)
        }
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
