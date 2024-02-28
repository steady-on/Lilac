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
    private let channelId = PublishRelay<Int>()
    private let workspaceId: Int
    private let channelName: String
    
    init(channelId: Int, workspaceId: Int, channelName: String) {
        self.channelId.accept(channelId)
        self.workspaceId = workspaceId
        self.channelName = channelName
    }
    
    var disposeBag = DisposeBag()
    
    private let channelChattingService = ChannelChattingService()
}

extension ChannelViewModel: ViewModel {
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    func transform(input: Input) -> Output {
        return Output()
    }
}
