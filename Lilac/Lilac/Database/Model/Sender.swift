//
//  Sender.swift
//  Lilac
//
//  Created by Roen White on 2/27/24.
//

import Foundation
import RealmSwift

final class Sender: EmbeddedObject {
    @Persisted var userId: Int
    @Persisted var email: String
    @Persisted var nickname: String
    @Persisted var profileImage: String?
    
    convenience init(from member: Responder.Channel.Member) {
        self.userId = member.userId
        self.email = member.email
        self.nickname = member.nickname
        self.profileImage = member.profileImage
    }
}
