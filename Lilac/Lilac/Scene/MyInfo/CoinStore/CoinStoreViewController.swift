//
//  CoinStoreViewController.swift
//  Lilac
//
//  Created by Roen White on 3/1/24.
//

import UIKit
import RxSwift
import RxCocoa

final class CoinStoreViewController: BaseViewController {
    
    private let viewModel: CoinStoreViewModel
    
    init(viewModel: CoinStoreViewModel) {
        self.viewModel = viewModel
        
        super.init()
    }
    
    private let shopTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.backgroundColor = .Background.primary
        tableView.separatorStyle = .none
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    private var dataSource: UITableViewDiffableDataSource<Section, Item>! = nil

    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configureHiararchy() {
        super.configureHiararchy()
        
        configureDataSource()
        
        view.addSubview(shopTableView)
    }

    override func setConstraints() {
        shopTableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func configureNavigationBar() {
        navigationItem.title = "코인샵"
        
        let barAppearance = UINavigationBarAppearance()
        barAppearance.backgroundColor = .Background.secondary
        navigationItem.scrollEdgeAppearance = barAppearance
    }
    
    override func bind() {
        let input = CoinStoreViewModel.Input()
        
        let output = viewModel.transform(input: input)
        
        output.itemList
            .subscribe(with: self) { owner, itemData in
                owner.configureSnapshot(myCoin: User.shared.myCoin, itemList: itemData)
            }
            .disposed(by: disposeBag)
    }
}

extension CoinStoreViewController {
    private enum Section: CaseIterable {
        case myCoin
        case itemList
    }
    
    private struct Item: Hashable {
        let text: String
        let secondaryText: String
        let section: Section
        
        init(text: String, secondaryText: String, section: Section) {
            self.text = text
            self.secondaryText = secondaryText
            self.section = section
        }
        
        init(myCoin: Int) {
            self.init(text: "현재 보유한 코인 \(myCoin)개", secondaryText: "코인이란?", section: .myCoin)
        }
        
        init(from item: Responder.Store.Item) {
            self.init(text: item.item, secondaryText: item.amount, section: .itemList)
        }
    }
}

extension CoinStoreViewController {
    private func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, Item>(tableView: shopTableView) { tableView, indexPath, item in
            let cell = UITableViewCell()
            
            var content = cell.defaultContentConfiguration()
            
            switch item.section {
            case .myCoin:
                let text = NSMutableAttributedString(
                    string: "🌱 " + item.text,
                    attributes: [
                        .font : UIFont.brandedFont(.bodyBold),
                        .foregroundColor : UIColor.accent
                    ]
                )
                
                text.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: 11))
                
                content.attributedText = text
                
                content.secondaryText = item.secondaryText
                content.secondaryTextProperties.font = .brandedFont(.body)
                content.secondaryTextProperties.color = .Text.secondary
                
            case .itemList:
                content.text = "🌱 " + item.text
                content.textProperties.font = .brandedFont(.bodyBold)
                content.textProperties.color = .Text.primary
            }
            
            cell.contentConfiguration = content
            
            if case Section.itemList = item.section {
                let accessoryButton = FilledColorButton(title: item.secondaryText)
                cell.accessoryView = accessoryButton
            }
            
            return cell
        }
    }
    
    private func configureSnapshot(myCoin: Int, itemList: [Responder.Store.Item]) {
        let myCoinItem = Item(myCoin: myCoin)
        
        let items = itemList.map { Item(from: $0) }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems([myCoinItem], toSection: .myCoin)
        snapshot.appendItems(items, toSection: .itemList)
    }
}
