//
//  Workspace.swift
//  Lilac
//
//  Created by Roen White on 2/16/24.
//

import Foundation

struct Workspace {
    let workspaceId: Int
    let name: String
    let description: String?
    let thumbnail: String
    let ownerId: Int
    let createdAt: Date
    var channels: [Channel]?
    let workspaceMembers: [Member]?
    
    init(workspaceId: Int, name: String, description: String?, thumbnail: String, ownerId: Int, createdAt: Date, channels: [Channel]?, workspaceMembers: [Member]?) {
        self.workspaceId = workspaceId
        self.name = name
        self.description = description
        self.thumbnail = thumbnail
        self.ownerId = ownerId
        self.createdAt = createdAt
        self.channels = channels
        self.workspaceMembers = workspaceMembers
    }
    
    init(from workspace: Responder.Workspace.Workspace) {
        let channels = workspace.channels?.compactMap { Channel(from: $0) }
        let workspaceMembers = workspace.workspaceMembers?.compactMap { Member(from: $0) }
        
        self.init(workspaceId: workspace.workspaceId, name: workspace.name, description: workspace.description, thumbnail: workspace.thumbnail, ownerId: workspace.ownerId, createdAt: workspace.createdAt, channels: channels, workspaceMembers: workspaceMembers)
    }
}

struct Channel: Hashable {
    let workspaceId: Int
    let channelId: Int
    let name: String
    let description: String?
    let ownerId: Int
    let isPrivate: Bool
    let createdAt: Date
    
    init(workspaceId: Int, channelId: Int, name: String, description: String?, ownerId: Int, isPrivate: Bool, createdAt: Date) {
        self.workspaceId = workspaceId
        self.channelId = channelId
        self.name = name
        self.description = description
        self.ownerId = ownerId
        self.isPrivate = isPrivate
        self.createdAt = createdAt
    }
    
    init(from channel: Responder.Workspace.Channel) {
        self.init(workspaceId: channel.workspaceId, channelId: channel.channelId, name: channel.name, description: channel.description, ownerId: channel.ownerId, isPrivate: channel.isPrivate, createdAt: channel.createdAt)
    }
    
    init(from channel: Responder.Channel.Channel) {
        self.init(workspaceId: channel.workspaceId, channelId: channel.channelId, name: channel.name, description: channel.description, ownerId: channel.ownerId, isPrivate: channel.isPrivate, createdAt: channel.createdAt)
    }
}

struct Member {
    let userId: Int
    let email: String
    let nickname: String
    let profileImage: String?
    
    init(userId: Int, email: String, nickname: String, profileImage: String?) {
        self.userId = userId
        self.email = email
        self.nickname = nickname
        self.profileImage = profileImage
    }
    
    init(from member: Responder.Workspace.Member) {
        self.init(userId: member.userId, email: member.email, nickname: member.nickname, profileImage: member.profileImage)
    }
}
