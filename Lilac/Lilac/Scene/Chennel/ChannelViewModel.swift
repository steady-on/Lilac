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
    
    deinit {
        print("deinit ChannelViewModel")
        WebSocketManager.shared.closeWebSocket()
    }
    
    private let startLoading = BehaviorRelay(value: -1)
    private let channelId: Int
    private let workspaceId: Int
    private let channelName: String
    
    init(channelId: Int, workspaceId: Int, channelName: String) {
        self.startLoading.accept(channelId)
        self.channelId = channelId
        self.workspaceId = workspaceId
        self.channelName = channelName
    }
    
    var disposeBag = DisposeBag()
    
    private let channelService = ChannelServiceImpl()
    private let channelChattingService = ChannelChattingService()
}

extension ChannelViewModel: ViewModel {
    struct Input {
        let sendButtonTapped: ControlEvent<Void>
        let chattingInputValue: ControlProperty<String>
    }
    
    struct Output {
        let channel: PublishRelay<Channel>
        let chattingRecords: Observable<[ChannelChatting]>
        let emptyTextField: PublishRelay<Void>
    }
    
    func transform(input: Input) -> Output {
        let channel = PublishRelay<Channel>()
        let emptyTextField = PublishRelay<Void>()
        let isOpenSocket = PublishRelay<Void>()
        
        startLoading
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
        
        let records = channelChattingService.loadChattingHistory(for: channelId)
        let chattingRecords = Observable.array(from: records)
            
        chattingRecords
            .filter { $0.isEmpty }
            .flatMap { [unowned self] _ in
                channelService.loadChatting(workspaceId: workspaceId, channelName: channelName, cursorDate: nil)
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let allChattingData):
                    owner.channelChattingService.saveChattings(allChattingData)
                    isOpenSocket.accept(())
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
                    isOpenSocket.accept(())
                case .failure(let failure):
                    print("failure: ", failure)
                }
            } onError: { _, error in
                print("Error: ", error)
            }
            .disposed(by: disposeBag)
        
        isOpenSocket
            .subscribe(with: self) { owner, bool in
                WebSocketManager.shared.openWebSocket(for: owner.channelId, type: .channel)
            }
            .disposed(by: disposeBag)
        
        input.sendButtonTapped
            .withLatestFrom(input.chattingInputValue) { _, inputValue in inputValue }
            .map { $0.data(using: .utf8) }
            .flatMap { [unowned self] contentData in
                channelService.sendChatting(workspaceId: workspaceId, channelName: channelName, content: contentData, files: nil)
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let sendedChatting):
                    owner.channelChattingService.saveChatting(sendedChatting)
                    emptyTextField.accept(())
                case .failure(let failure):
                    print("failure: ", failure)
                }
            } onError: { _, error in
                print("Error: ", error)
            }
            .disposed(by: disposeBag)
                    
        return Output(
            channel: channel,
            chattingRecords: chattingRecords,
            emptyTextField: emptyTextField
        )
    }
}
