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
            let createdAt: Date
            let token: Token
            
            enum CodingKeys: CodingKey {
                case userId
                case email
                case nickname
                case profileImage
                case phone
                case vendor
                case createdAt
                case token
            }
            
            init(from decoder: Decoder) throws {
                let container: KeyedDecodingContainer<Responder.User.ProfileWithToken.CodingKeys> = try decoder.container(keyedBy: Responder.User.ProfileWithToken.CodingKeys.self)
                self.userId = try container.decode(Int.self, forKey: Responder.User.ProfileWithToken.CodingKeys.userId)
                self.email = try container.decode(String.self, forKey: Responder.User.ProfileWithToken.CodingKeys.email)
                self.nickname = try container.decode(String.self, forKey: Responder.User.ProfileWithToken.CodingKeys.nickname)
                self.profileImage = try container.decodeIfPresent(String.self, forKey: Responder.User.ProfileWithToken.CodingKeys.profileImage)
                self.phone = try container.decodeIfPresent(String.self, forKey: Responder.User.ProfileWithToken.CodingKeys.phone)
                self.vendor = try container.decode(Responder.User.Vendor.self, forKey: Responder.User.ProfileWithToken.CodingKeys.vendor)
                
                let createdAt = try container.decode(String.self, forKey: .createdAt)
                self.createdAt = createdAt.convertedDate
                
                self.token = try container.decode(Responder.User.Token.self, forKey: Responder.User.ProfileWithToken.CodingKeys.token)
            }
        }
        
        // users/my
        struct MyProfile: Decodable {
            let userId: Int
            let email, nickname: String
            let profileImage, phone: String?
            let vendor: Vendor
            let sesacCoin: Int?
            let createdAt: Date
            
            enum CodingKeys: CodingKey {
                case userId
                case email
                case nickname
                case profileImage
                case phone
                case vendor
                case sesacCoin
                case createdAt
            }
            
            init(from decoder: Decoder) throws {
                let container: KeyedDecodingContainer<Responder.User.MyProfile.CodingKeys> = try decoder.container(keyedBy: Responder.User.MyProfile.CodingKeys.self)
                
                self.userId = try container.decode(Int.self, forKey: .userId)
                self.email = try container.decode(String.self, forKey: .email)
                self.nickname = try container.decode(String.self, forKey: .nickname)
                self.profileImage = try container.decodeIfPresent(String.self, forKey: .profileImage)
                self.phone = try container.decodeIfPresent(String.self, forKey: .phone)
                self.vendor = try container.decodeIfPresent(Responder.User.Vendor.self, forKey: .vendor) ?? .email
                self.sesacCoin = try container.decodeIfPresent(Int.self, forKey: .sesacCoin)
                
                let createdAt = try container.decode(String.self, forKey: .createdAt)
                self.createdAt = createdAt.convertedDate
            }
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
        // workspace create, load, update, search, leave, admin
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
        
        // workspace member invite, load
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
        case email
        case kakao
        case apple
    }
}

extension Responder.WorkSpace {
    
}
