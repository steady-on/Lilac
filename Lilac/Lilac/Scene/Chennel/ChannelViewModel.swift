//
//  ChannelViewModel.swift
//  Lilac
//
//  Created by Roen White on 2/28/24.
//

import Foundation
import RxSwift
import RxCocoa
import RxRealm
import RealmSwift

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
        let chattingRecords: Observable<[ChannelChatting]>
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
        
        let chattingRecords = channelId
            .flatMap { [unowned self] id in
                let allChattingRecords = channelChattingService.loadChattingHistory(for: id)
                return Observable.array(from: allChattingRecords)
            }
            .debug()
            
        chattingRecords
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
        
        chattingRecords
            .filter { $0.isEmpty == false }
            .map { $0.last!.createdAt.convertFormmtedString }
            .flatMap { [unowned self] cursorDate in
                channelService.loadChatting(workspaceId: workspaceId, channelName: channelName, cursorDate: cursorDate)
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
            channel: channel,
            chattingRecords: chattingRecords
        )
    }
}
