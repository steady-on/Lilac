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
    
    enum WorkSpace {
        struct WorkSpace: Decodable {
            let workspaceId: Int
            let name: String
            let description: String?
            let thumbnail: String
            let ownerId: Int
            let createdAt: Date
            let channels: [Channel]?
            let workspaceMembers: [Member]?
        }
        
        struct Channel: Decodable {
            let workSpaceId: Int
            let channelId: Int
            let name: String
            let description: String?
            let ownerId: Int
            let isPrivate: Bool
            let createdAt: Date
            
            enum CodingKeys: String, CodingKey {
                case workSpaceId, channelId, name, description, ownerId, createdAt
                case isPrivate = "private"
            }
        }
        
        struct Member: Decodable {
            let userId: Int
            let email: String
            let nickname: String
            let profileImage: String?
        }
    }

    struct Error: Decodable {
        let errorCode: String
    }
}

extension Responder.User {
    struct Token: Decodable {
        let accessToken, refreshToken: String
    }
    
    enum Vendor: String, Decodable {
        case email = ""
        case kakao
        case apple
    }
}

extension Responder.WorkSpace {
    
}
