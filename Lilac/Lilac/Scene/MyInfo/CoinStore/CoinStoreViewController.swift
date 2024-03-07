//
//  CoinStoreViewController.swift
//  Lilac
//
//  Created by Roen White on 3/1/24.
//

import UIKit
import RxSwift
import RxCocoa
import iamport_ios
import WebKit

final class CoinStoreViewController: BaseViewController {
    
    private let viewModel: CoinStoreViewModel
    
    init(viewModel: CoinStoreViewModel) {
        self.viewModel = viewModel
        
        super.init()
    }
    
    private let disposeBag = DisposeBag()
    
    private let paySuccess = PublishRelay<(imp_uid: String, merchant_uid: String)>()
    
    private var shopCollectionView: UICollectionView! = nil
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>! = nil
    
    private lazy var wkWebView: WKWebView = {
        var view = WKWebView()
        view.backgroundColor = .clear
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Iamport.shared.close()
    }
    
    override func configureHiararchy() {
        super.configureHiararchy()
        
        configureCollectionView()
        configureDataSource()
        
        view.addSubview(shopCollectionView)
    }
    
    override func setConstraints() {
        shopCollectionView.snp.makeConstraints { make in
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
        let input = CoinStoreViewModel.Input(
            paySuccess: paySuccess
        )
        
        let output = viewModel.transform(input: input)
        
        output.coinAndItemList
            .subscribe(with: self) { owner, itemData in
                owner.configureSnapshot(myCoin: itemData.0, itemList: itemData.1)
            }
            .disposed(by: disposeBag)
        
        output.showToast
            .subscribe(with: self) { owner, toast in
                owner.showToast(toast, target: self, position: .low)
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
    private func configureCollectionView() {
        shopCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        shopCollectionView.showsVerticalScrollIndicator = false
        shopCollectionView.showsHorizontalScrollIndicator = false
        shopCollectionView.delegate = self
    }
    
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { _, layoutEnvironment in
            var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            configuration.backgroundColor = .Background.primary
            configuration.showsSeparators = false
            
            return NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
        }
    }
}

extension CoinStoreViewController {
    private func configureDataSource() {
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { cell, indexPath, item in
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
                
                text.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: 12))
                
                content.attributedText = text
                
                content.secondaryText = item.secondaryText
                content.secondaryTextProperties.font = .brandedFont(.body)
                content.secondaryTextProperties.color = .Text.secondary
                
            case .itemList:
                content.text = "🌱 " + item.text
                content.textProperties.font = .brandedFont(.bodyBold)
                content.textProperties.color = .Text.primary
            }
            
            content.prefersSideBySideTextAndSecondaryText = true
            
            cell.contentConfiguration = content
            
            if case Section.itemList = item.section {
                let secondaryButton = FilledColorButton(title: "₩\(item.secondaryText)")
                secondaryButton.isUserInteractionEnabled = false
                cell.accessories = [.customView(configuration: UICellAccessory.CustomViewConfiguration(customView: secondaryButton, placement: .trailing(displayed: .always, at: UICellAccessory.Placement.position(after: .detail()))))]
            }
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: shopCollectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
    }
}

extension CoinStoreViewController {
    private func configureSnapshot(myCoin: Int, itemList: [Responder.Store.Item]) {
        let myCoinItem = Item(myCoin: myCoin)
        
        let items = itemList.map { Item(from: $0) }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems([myCoinItem], toSection: .myCoin)
        snapshot.appendItems(items, toSection: .itemList)
        
        dataSource.apply(snapshot)
    }
}

extension CoinStoreViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let item = dataSource.itemIdentifier(for: indexPath),
              item.section == .itemList else { return }
        
        let convertedItem = Responder.Store.Item(item: item.text, amount: item.secondaryText)
        buyItem(convertedItem)
    }
}

extension CoinStoreViewController {
    private func buyItem(_ item: Responder.Store.Item) {
        let payment = IamportPayment(
            pg: PG.html5_inicis.makePgRawName(pgId: "INIpayTest"),
            merchant_uid: "ios_\(APIKey.secretKey)_\(Int(Date().timeIntervalSince1970))",
            amount: item.amount
        ).then {
            $0.pay_method = PayMethod.card.rawValue
            $0.name = item.item
            $0.buyer_name = "백수민"
            $0.app_scheme = "iamport"
        }
        
        guard let navigationController else { return }
        Iamport.shared.payment(navController: navigationController, userCode: APIKey.portOneUserCode, payment: payment) { [unowned self] response in
            guard let response, let success = response.success, success else {
                print("결제 실패!")
                return
            }
            
            guard let imp_uid = response.imp_uid, let merchant_uid = response.merchant_uid else {
                print("결제 정보를 알 수 없음")
                return
            }
            
            paySuccess.accept((imp_uid, merchant_uid))
        }
    }
}
