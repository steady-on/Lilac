//
//  ChannelChattingService.swift
//  Lilac
//
//  Created by Roen White on 2/27/24.
//

import Foundation
import RealmSwift

final class ChannelChattingService {
    private let repository = RealmRepository<ChannelChatting>()
    
    /// 채팅 1개 저장
    func saveChatting(_ chatting: Responder.Channel.Chatting) {
        let channelChatting = ChannelChatting(from: chatting)
        
        repository.create(channelChatting)
    }
    
    /// 다수의 채팅 저장
    func saveChattings(_ chattings: [Responder.Channel.Chatting]) {
        let channelChattings = chattings.map { ChannelChatting(from: $0) }
        
        for chatting in channelChattings {
            repository.create(chatting)
        }
    }
    
    /// 채널에 해당하는 채팅 불러오기
    func loadChattingHistory(for channelId: Int) -> Results<ChannelChatting> {
        let allChattings = repository.read()
        let channelChattings = allChattings.where { $0.channelId == channelId }
        return channelChattings.sorted(by: \.createdAt)
    }
    
    /// 채팅 내역 삭제
    func deleteAll(_ chattings: Results<ChannelChatting>) {
        repository.delete(chattings)
    }
}
