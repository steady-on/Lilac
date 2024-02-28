//
//  ChannelViewModel.swift
//  Lilac
//
//  Created by Roen White on 2/28/24.
//

import Foundation
import RxSwift
import RxCocoa

final class ChannelViewModel {
    private let channelId = BehaviorRelay(value: -1)
    private let workspaceId: Int
    private let channelName: String
    
    init(channelId: Int, workspaceId: Int, channelName: String) {
        self.channelId.accept(channelId)
        self.workspaceId = workspaceId
        self.channelName = channelName
    }
    
    var disposeBag = DisposeBag()
    
    private let channelService = ChannelServiceImpl()
    private let channelChattingService = ChannelChattingService()
}

extension ChannelViewModel: ViewModel {
    struct Input {
        
    }
    
    struct Output {
        let channel: PublishRelay<Channel>
    }
    
    func transform(input: Input) -> Output {
        let channel = PublishRelay<Channel>()
        
        channelId
            .flatMap { [unowned self] id in
                channelService.load(workspaceId: workspaceId, channelName: channelName)
            }
            .subscribe { result in
                switch result {
                case .success(let channelData):
                    let fetchedChannel = Channel(from: channelData)
                    channel.accept(fetchedChannel)
                case .failure(let failure):
                    print("failure: ", failure)
                }
            } onError: { error in
                print("Error: ", error)
            }
            .disposed(by: disposeBag)
        
        let chattingHistory = channelId
            .map { [unowned self] id in
                let channelChattingResults = channelChattingService.loadChattingHistory(for: id)
                return Array(channelChattingResults)
            }
            .debug()
        
        chattingHistory
            .filter { $0.isEmpty }
            .flatMap { [unowned self] _ in
                channelService.loadChatting(workspaceId: workspaceId, channelName: channelName, cursorDate: nil)
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let allChattingData):
                    owner.channelChattingService.saveChattings(allChattingData)
                case .failure(let failure):
                    print("failure: ", failure)
                }
            } onError: { _, error in
                print("Error: ", error)
            }
            .disposed(by: disposeBag)

        
        return Output(
            channel: channel
        )
    }
}
