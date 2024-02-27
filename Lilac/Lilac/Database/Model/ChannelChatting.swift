//
//  ChannelChatting.swift
//  Lilac
//
//  Created by Roen White on 2/27/24.
//

import Foundation
import RealmSwift

final class ChannelChatting: Object {
    @Persisted(primaryKey: true) var chatId: Int
    @Persisted(indexed: true) var channelId: Int
    @Persisted var channelName: String
    @Persisted var content: String?
    @Persisted var createdAt: Date
    @Persisted var files: List<String>
    @Persisted var sender: Sender
    
    convenience init(from chatting: Responder.Channel.Chatting) {
        self.init()
        
        self.chatId = chatting.chatId
        self.channelId = chatting.channelId
        self.channelName = chatting.channelName
        self.content = chatting.content
        self.createdAt = chatting.createdAt
        self.files.append(objectsIn: chatting.files)
        self.sender = .init(from: chatting.user)
    }
}
