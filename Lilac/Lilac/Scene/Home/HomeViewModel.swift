//
//  HomeViewModel.swift
//  Lilac
//
//  Created by Roen White on 2/24/24.
//

import Foundation
import RxSwift
import RxCocoa

final class HomeViewModel {
    var disposeBag = DisposeBag()
    
    private lazy var channelService = ChannelServiceImpl()
}

extension HomeViewModel: ViewModel {
    struct Input {
        let isRefresh: PublishRelay<Void>
    }
    
    struct Output {
        let selectedWorkspace: PublishRelay<Workspace>
    }
    
    func transform(input: Input) -> Output {
        let selectedWorkspace = PublishRelay<Workspace>()
        
        let selectedWorkspaceId = User.shared.selectedWorkspaceId
        
        selectedWorkspaceId
            .flatMap { [unowned self] id in
                channelService.loadBelongTo(workspaceId: id)
            }
            .subscribe { result in
                switch result {
                case .success(let channelData):
                    guard let updatedWorkspace = User.shared.fetchChannelToWorkspace(channelData) else {
                        // TODO: 토스트메세지
                        return
                    }
                    selectedWorkspace.accept(updatedWorkspace)
                case .failure(let failure):
                    print("Fail:", failure)
                }
            } onError: { error in
                print("Error!", error)
            }
            .disposed(by: disposeBag)
        
            .flatMap { [unowned self] id in
            }
            .subscribe { result in
                switch result {
                }
            } onError: { error in
                print("Error", error)
            }
            .disposed(by: disposeBag)
        
        return Output(
            selectedWorkspace: selectedWorkspace
        )
    }
}
