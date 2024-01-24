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
        case askForOtherUserProfile(id: Int)
        
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
        case workSpace(type: WorkSpace)
        case member(id: Int, type: Member)
        
        enum WorkSpace {
            case create(name: String, description: String?, image: String)
            case load(id: Int?)
            case update(id: Int, name: String?, description: String?, image: String?)
            case delete(id: Int)
        }
        
        enum Member {
            case invite(email: String)
            case load(userId: Int?)
            case search(keyword: String)
            case leave
            case admin(userId: Int)
        }
    }
}
