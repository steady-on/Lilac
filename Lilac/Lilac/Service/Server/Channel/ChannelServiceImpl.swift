//
//  ChannelServiceImpl.swift
//  Lilac
//
//  Created by Roen White on 2/27/24.
//

import Foundation
import RxSwift

final class ChannelServiceImpl: ChannelService {
    
    private let repository = LilacRepository<LilacAPI.Channel>()
    
    func create(workspaceId: Int, name: String, description: String) -> Single<Result<Responder.Channel.Channel, Error>> {
        return repository.request(.create(workspaceId: workspaceId, name: name, description: description), responder: Responder.Channel.Channel.self)
    }
    
    func loadAll(workspaceId: Int) -> Single<Result<[Responder.Channel.Channel], Error>> {
        return repository.request(.loadAll(workspaceId: workspaceId), responder: [Responder.Channel.Channel].self)
    }
    
    func loadBelongTo(workspaceId: Int) -> Single<Result<[Responder.Channel.Channel], Error>> {
        return repository.request(.loadBelongTo(workspaceId: workspaceId), responder: [Responder.Channel.Channel].self)
    }
    
    func load(workspaceId: Int, channelName: String) -> Single<Result<Responder.Channel.Channel, Error>> {
        return repository.request(.load(workspaceId: workspaceId, channelName: channelName), responder: Responder.Channel.Channel.self)
    }
    
    func update(workspaceId: Int, channelName: String, name: String?, description: String?) -> Single<Result<Responder.Channel.Channel, Error>> {
        return repository.request(.update(workspaceId: workspaceId, channelName: channelName, name: name, description: description), responder: Responder.Channel.Channel.self)
    }
    
    func delete(workspaceId: Int, channelName: String) -> Single<Result<Void, Error>> {
        return repository.request(.delete(workspaceId: workspaceId, channelName: channelName))
    }
    
    func sendChatting(workspaceId: Int, channelName: String, content: Data?, files: [Data]?) -> Single<Result<Responder.Channel.Chatting, Error>> {
        return repository.request(.sendChatting(workspaceId: workspaceId, channelName: channelName, content: content, files: files), responder: Responder.Channel.Chatting.self)
    }
    
    func loadChatting(workspaceId: Int, channelName: String, cursorDate: String?) -> Single<Result<[Responder.Channel.Chatting], Error>> {
        return repository.request(.loadChatting(workspaceId: workspaceId, channelName: channelName, cursorDate: cursorDate), responder: [Responder.Channel.Chatting].self)
    }
    
    func countUnreads(workspaceId: Int, channelName: String, after: String?) -> Single<Result<Responder.Channel.CountOfUnread, Error>> {
        return repository.request(.countUnreads(workspaceId: workspaceId, channelName: channelName, after: after), responder: Responder.Channel.CountOfUnread.self)
    }
    
    func loadAllMembers(workspaceId: Int, channelName: String) -> Single<Result<[Responder.Channel.Member], Error>> {
        return repository.request(.member(workspaceId: workspaceId, channelName: channelName), responder: [Responder.Channel.Member].self)
    }
    
    func leave(workspaceId: Int, channelName: String) -> Single<Result<[Responder.Channel.Channel], Error>> {
        return repository.request(.leave(workspaceId: workspaceId, channelName: channelName), responder: [Responder.Channel.Channel].self)
    }
    
    func changeAdmin(workspaceId: Int, channelName: String, userId: Int) -> Single<Result<Responder.Channel.Channel, Error>> {
        return repository.request(.changeAdmin(workspaceId: workspaceId, channelName: channelName, userId: userId), responder: Responder.Channel.Channel.self)
    }
}
