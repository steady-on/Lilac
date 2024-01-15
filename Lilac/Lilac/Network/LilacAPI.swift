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
        case myProfile(type: WorkType)
        case askForOtherUserProfile(id: Int)
        
        enum Vendor {
            case email(email: String, password: String)
            case kakao(accessToken: String)
            case apple
        }
        
        enum WorkType {
            case askForMyInfo
            case editInfo(nickname: String?, phone: String?)
            case editImage(image: Data)
        }
    }
}
