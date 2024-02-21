//
//  LilacAPI.swift
//  Lilac
//
//  Created by Roen White on 1/6/24.
//

import Foundation

enum LilacAPI {
    enum Auth: String {
        case refresh
    }
    
    enum User {
        case signUp(userInfo: Requester.NewUser)
        case validateEmail(email: String)
        case signIn(vendor: Vendor)
        case signOut
        case saveDeviceToken
        case myProfile(type: MyProfile)
        case otherUserProfile(id: Int)
        
        enum Vendor {
            case email(email: String, password: String)
            case kakao(accessToken: String)
            case apple
        }
        
        enum MyProfile {
            case load
            case updateInfo(nickname: String?, phone: String?)
            case updateImage(image: Data)
        }
    }
    
    enum WorkSpace {
        case create(name: Data, description: Data, image: Data)
        case loadAll
        case load(id: Int)
        case update(id: Int, name: Data?, description: Data?, image: Data?)
        case delete(id: Int)
        case search(id: Int, keyword: String)
        case leave(id: Int)
        case admin(id: Int, userId: Int)
        case member(id: Int, type: Member)
        
        enum Member {
            case invite(email: String)
            case loadAll
            case load(userId: Int)
        }
    }
}
