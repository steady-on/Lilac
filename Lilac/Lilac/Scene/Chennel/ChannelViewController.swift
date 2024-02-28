//
//  ChannelViewController.swift
//  Lilac
//
//  Created by Roen White on 2/28/24.
//

import UIKit
import RxSwift
import RxCocoa

final class ChannelViewController: BaseViewController {
    
    private let viewModel: ChannelViewModel
    
    init(viewModel: ChannelViewModel) {
        self.viewModel = viewModel
        
        super.init()
    }
    
    private let disposeBag = DisposeBag()
    
    private let titleView = ChannelTitleView()

    private let chattingTextField = ChattingTextField()
    
    private let chattingTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ChattingTableViewCell.self, forCellReuseIdentifier: ChattingTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.contentInset = .init(top: 16, left: 16, bottom: 16, right: 16)
        return tableView
    }()
    
    private var dataSource: UITableViewDiffableDataSource<Section, ChannelChatting>! = nil
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configureHiararchy() {
        view.backgroundColor = .Background.secondary
        
        let components = [chattingTableView, chattingTextField]
        components.forEach { component in
            view.addSubview(component)
        }
    }
    
    override func setConstraints() {
        chattingTableView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
        }
        
        chattingTextField.snp.makeConstraints { make in
            make.top.equalTo(chattingTableView.snp.bottom)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-12)
        }
    }
    
    override func configureNavigationBar() {
        navigationItem.titleView = titleView
                
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: .Workspace.list, style: .plain, target: self, action: #selector(channelSettingButtonTapped))
        navigationController?.navigationBar.tintColor = .black
        
        let barAppearance = UINavigationBarAppearance()
        barAppearance.backgroundColor = .Background.secondary
        navigationItem.scrollEdgeAppearance = barAppearance
    }
    
    override func bind() {
        let input = ChannelViewModel.Input()
        
        let output = viewModel.transform(input: input)
        
        output.channel
            .subscribe(with: self) { owner, channel in
                owner.titleView.setChannel(for: channel.name, countOfMember: channel.channelMembers?.count ?? 1)
            }
            .disposed(by: disposeBag)
    }
}

// MARK: Related DataSource & Snapshot
extension ChannelViewController {
    private enum Section {
        case main
    }
    
    private func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, ChannelChatting>(tableView: chattingTableView) { tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ChattingTableViewCell.identifier) as? ChattingTableViewCell else { return UITableViewCell() }
            cell.chatting = item
            return cell
        }
    }
    
    private func configureSnapshot(for chattings: [ChannelChatting]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ChannelChatting>()
        snapshot.appendSections([.main])
        snapshot.appendItems(chattings)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}



extension ChannelViewController {
    @objc private func channelSettingButtonTapped() {
        print(#function)
    }
}
