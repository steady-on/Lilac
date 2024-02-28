//
//  HomeViewController+.swift
//  Lilac
//
//  Created by Roen White on 2/24/24.
//

import UIKit

extension HomeViewController {
    enum Header: Int, CaseIterable {
        case channel
        case directMessage
        case member
        
        var title: String {
            switch self {
            case .channel: return "채널"
            case .directMessage: return "다이렉트 메시지"
            case .member: return ""
            }
        }
    }
    
    enum Footer: Int {
        case addChannel
        case newMessage
        case inviteMember
        
        var title: String {
            switch self {
            case .addChannel: return "채널 추가"
            case .newMessage: return "새 메시지 시작"
            case .inviteMember: return "팀원 추가"
            }
        }
    }
    
    struct Item: Hashable {
        /// channelId or roomId, header/footer인 경우 rawValue
        let id: Int
        /// channelName or DM.user.nickname, header/footer인 경우 title
        let text: String
        /// workspaceId, header/footer인 경우 -1
        let workspaceId: Int
        /// channel, header/footer인 경우 nil, DM인 경우 profile Image url
        let image: String?
        let type: ItemType
//        let unreads: Int?
        
        init(id: Int, text: String, workspaceId: Int, image: String?, type: ItemType) {
            self.id = id
            self.text = text
            self.workspaceId = workspaceId
            self.image = image
//            self.unreads = unreads
            self.type = type
        }
        
        init(from section: Header) {
            self.init(id: section.rawValue, text: section.title, workspaceId: -1, image: nil, type: .header)
        }
        
        init(from channel: Channel) {
            self.init(id: channel.channelId, text: channel.name, workspaceId: channel.workspaceId, image: nil, type: .channel)
        }
        
        init(from footer: Footer) {
            self.init(id: footer.rawValue, text: footer.title, workspaceId: -1, image: nil, type: .footer)
        }
        
        enum ItemType {
            case header
            case footer
            case channel
            case dm
        }
    }
}
