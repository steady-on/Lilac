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
        
        /// 선택한 워크스페이스에 따라 해당 워크스페이스에서 사용자가 속한 채널리스트를 업데이트
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
        
        /// collectionView를 당겨서 새로고침 시 채널리스트를 업데이트
        input.isRefresh
            .withLatestFrom(selectedWorkspaceId) { _, workspaceId in workspaceId }
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
                print("Error", error)
            }
            .disposed(by: disposeBag)
        
        return Output(
            selectedWorkspace: selectedWorkspace
        )
    }
}
