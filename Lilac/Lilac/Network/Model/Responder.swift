//
//  Responder.swift
//  Lilac
//
//  Created by Roen White on 1/6/24.
//

import Foundation

enum Responder {
    struct Auth: Decodable {
        let accessToken: String
    }
    
    struct SignUp: Decodable {
        let nickname: String
        let token: Token
    }
    
    struct SignIn: Decodable {
        let nickname, accessToken, refreshToken: String
    }
    
    struct SignInWithVendor: Decodable {
        let email, nickname: String
        let profileImage, phone: String?
        let vendor: Vendor
        let createdAt: String
        let token: Token
    }
    
    struct MyProfile: Decodable {
        let email, nickname: String
        let profileImage, phone: String?
        let vendor: Vendor
        let sesacCoin: Int
        let createdAt: Date
    }
    
    struct OtherUserProfile: Decodable {
        let email, nickname: String
        let profileImage: String?
        let createdAt: Date
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
