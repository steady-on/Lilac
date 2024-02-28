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

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configureHiararchy() {
        view.backgroundColor = .Background.secondary
        
        let components = [chattingTextField]
        components.forEach { component in
            view.addSubview(component)
        }
    }
    
    override func setConstraints() {
        chattingTextField.snp.makeConstraints { make in
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

extension ChannelViewController {
    @objc private func channelSettingButtonTapped() {
        print(#function)
    }
}
