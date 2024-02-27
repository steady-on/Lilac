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
    private let channelId: Int
    
    init(channelId: Int) {
        self.channelId = channelId
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
