//
//  Responder.swift
//  Lilac
//
//  Created by Roen White on 1/6/24.
//

import Foundation

enum Responder {
    enum Auth {
        // auth/refresh
        struct TokenRefresh: Decodable {
            let accessToken: String
        }
    }
    
    enum User {
        // v1/users/login
        struct SimpleProfileWithToken: Decodable {
            let userId: Int
            let nickname, accessToken, refreshToken: String
        }
        
        // users/login/kakao, apple, users/signUp
        struct ProfileWithToken: Decodable {
            let userId: Int
            let email, nickname: String
            let profileImage, phone: String?
            let vendor: Vendor
            let createdAt: String
            let token: Token
        }
        
        // users/my
        struct MyProfile: Decodable {
            let userId: Int
            let email, nickname: String
            let profileImage, phone: String?
            let vendor: Vendor
            let sesacCoin: Int?
            let createdAt: Date
        }
        
        // users/{id}
        struct UserProfile: Decodable {
            let userId: Int
            let email, nickname: String
            let profileImage: String?
            let createdAt: Date
        }
    }
    
    

    struct Error: Decodable {
        let errorCode: String
    }
}

extension Responder {
    struct Token: Decodable {
        let accessToken, refreshToken: String
    }
    
    enum Vendor: String, Decodable {
        case email = ""
        case kakao
        case apple
    }
}
