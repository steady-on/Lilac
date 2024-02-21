//
//  MyProfile.swift
//  Lilac
//
//  Created by Roen White on 2/16/24.
//

import Foundation

struct MyProfile {
    let userId: Int
    let email, nickname: String
    let profileImage, phone: String?
    let vendor: Vendor
    let sesacCoin: Int?
    let createdAt: Date
    
    init(userId: Int, email: String, nickname: String, profileImage: String?, phone: String?, vendor: Vendor, sesacCoin: Int?, createdAt: Date) {
        self.userId = userId
        self.email = email
        self.nickname = nickname
        self.profileImage = profileImage
        self.phone = phone
        self.vendor = vendor
        self.sesacCoin = sesacCoin
        self.createdAt = createdAt
    }
    
    init(from myProfile: Responder.User.MyProfile) {
        self.init(userId: myProfile.userId, email: myProfile.email, nickname: myProfile.nickname, profileImage: myProfile.profileImage, phone: myProfile.phone, vendor: .init(from: myProfile.vendor), sesacCoin: myProfile.sesacCoin, createdAt: myProfile.createdAt)
    }
    
    init(from profile: Responder.User.ProfileWithToken) {
        self.init(userId: profile.userId, email: profile.email, nickname: profile.nickname, profileImage: profile.profileImage, phone: profile.phone, vendor: .init(from: profile.vendor), sesacCoin: nil, createdAt: profile.createdAt)
    }
    
    init() {
        self.init(userId: 0, email: "", nickname: "", profileImage: nil, phone: nil, vendor: .apple, sesacCoin: nil, createdAt: Date.now)
    }
}

extension MyProfile {
    enum Vendor: String {
        case email
        case kakao
        case apple
        
        init(from vendor: Responder.User.Vendor) {
            switch vendor {
            case .email: self = .email
            case .kakao: self = .kakao
            case .apple: self = .apple
            }
        }
    }
}
