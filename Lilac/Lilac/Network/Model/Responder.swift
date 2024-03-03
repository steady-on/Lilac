//
//  Responder.swift
//  Lilac
//
//  Created by Roen White on 1/6/24.
//

import Foundation

enum Responder {
    /// responder for LilacAPI.Auth
    enum Auth {
        /// Be returned .refresh
        struct TokenRefresh: Decodable {
            let accessToken: String
        }
    }
    
    /// responder for LilacAPI.User
    enum User {
        /// Be returned .login(.email)
        struct SimpleProfileWithToken: Decodable {
            let userId: Int
            let nickname, accessToken, refreshToken: String
        }
        
        /// Be returned .login(.kakao, .apple), .signUp
        struct ProfileWithToken: Decodable {
            let userId: Int
            let email, nickname: String
            let profileImage, phone: String?
            let vendor: Vendor
            let createdAt: Date
            let token: Token
            
            enum CodingKeys: CodingKey {
                case userId, email, nickname, profileImage, phone, vendor, createdAt, token
            }
            
            init(from decoder: Decoder) throws {
                let container: KeyedDecodingContainer<Responder.User.ProfileWithToken.CodingKeys> = try decoder.container(keyedBy: Responder.User.ProfileWithToken.CodingKeys.self)
                self.userId = try container.decode(Int.self, forKey: .userId)
                self.email = try container.decode(String.self, forKey: .email)
                self.nickname = try container.decode(String.self, forKey: .nickname)
                self.profileImage = try container.decodeIfPresent(String.self, forKey: .profileImage)
                self.phone = try container.decodeIfPresent(String.self, forKey: .phone)
                self.vendor = .email
                self.createdAt = try container.decode(Date.self, forKey: .createdAt)
                self.token = try container.decode(Responder.User.Token.self, forKey: .token)
            }
        }
        
        /// Be returned .myProfile
        struct MyProfile: Decodable {
            let userId: Int
            let email, nickname: String
            let profileImage, phone: String?
            let vendor: Vendor
            let sesacCoin: Int?
            let createdAt: Date
            
            enum CodingKeys: CodingKey {
                case userId, email, nickname, profileImage, phone, vendor, sesacCoin, createdAt
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
                self.createdAt = try container.decode(Date.self, forKey: .createdAt)
            }
        }
        
        /// Be returned .otherUserProfile
        struct UserProfile: Decodable {
            let userId: Int
            let email, nickname: String
            let profileImage: String?
            let createdAt: Date
        }
    }
    
    /// responder for LilacAPI.Workspace
    enum Workspace {
        /// Be returned single for case .create, .load, .update, .search, .leave, admin
        /// Be returned array for case .loadAll, .leave
        struct Workspace: Decodable {
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
            let workspaceId: Int
            let channelId: Int
            let name: String
            let description: String?
            let ownerId: Int
            let isPrivate: Bool
            let createdAt: Date
            let channelMembers: [Member]?
            
            enum CodingKeys: String, CodingKey {
                case workspaceId, channelId, name, description, ownerId, createdAt, channelMembers
                case isPrivate = "private"
            }
            
            init(from decoder: Decoder) throws {
                let container: KeyedDecodingContainer<Responder.Workspace.Channel.CodingKeys> = try decoder.container(keyedBy: Responder.Workspace.Channel.CodingKeys.self)
                
                self.workspaceId = try container.decode(Int.self, forKey: .workspaceId)
                self.channelId = try container.decode(Int.self, forKey: .channelId)
                self.name = try container.decode(String.self, forKey: .name)
                self.description = try container.decodeIfPresent(String.self, forKey: .description)
                self.ownerId = try container.decode(Int.self, forKey: .ownerId)
                self.createdAt = try container.decode(Date.self, forKey: .createdAt)
                
                let isPrivate = try container.decode(Int.self, forKey: .isPrivate)
                self.isPrivate = isPrivate == 1
                
                self.channelMembers = try container.decodeIfPresent([Member].self, forKey: .channelMembers)
            }
        }
        
        /// Be returned single for case .member(.invite, .load)
        /// Be returned array for case .member(.loadAll)
        struct Member: Decodable {
            let userId: Int
            let email: String
            let nickname: String
            let profileImage: String?
        }
    }
    
    /// responder for LilacAPI.Channel
    enum Channel {
        /// Be returned single for case .create, .update, .changeAdmin
        /// Be returned array for case .loadAll, .loadBelongTo, .leave
        /// Be returned with members for case .load
        struct Channel: Decodable {
            let workspaceId: Int
            let channelId: Int
            let name: String
            let description: String?
            let ownerId: Int
            let isPrivate: Bool
            let createdAt: Date
            let channelMembers: [Member]?
            
            enum CodingKeys: String, CodingKey {
                case workspaceId, channelId, name, description, ownerId, createdAt, channelMembers
                case isPrivate = "private"
            }
            
            init(from decoder: Decoder) throws {
                let container: KeyedDecodingContainer<Responder.Workspace.Channel.CodingKeys> = try decoder.container(keyedBy: Responder.Workspace.Channel.CodingKeys.self)
                
                self.workspaceId = try container.decode(Int.self, forKey: .workspaceId)
                self.channelId = try container.decode(Int.self, forKey: .channelId)
                self.name = try container.decode(String.self, forKey: .name)
                self.description = try container.decodeIfPresent(String.self, forKey: .description)
                self.ownerId = try container.decode(Int.self, forKey: .ownerId)
                
                self.createdAt = try container.decode(Date.self, forKey: .createdAt)
                
                let isPrivate = try container.decode(Int.self, forKey: .isPrivate)
                self.isPrivate = isPrivate == 1
                
                self.channelMembers = try container.decodeIfPresent([Member].self, forKey: .channelMembers)
            }
        }
        
        /// Be returned array for case .loadAllMembers
        struct Member: Decodable {
            let userId: Int
            let email: String
            let nickname: String
            let profileImage: String?
        }
        
        /// Be returned single for case .sendChatting
        /// Be returned array for case .loadChatting
        struct Chatting: Decodable {
            /// 채널 아이디
            let channelId: Int
            /// 채널명
            let channelName: String
            /// 채팅 ID
            let chatId: Int
            /// 채팅 내용; 빈값 가능
            let content: String?
            /// 채팅 생성 날짜
            let createdAt: Date
            /// 채팅에 보낸 파일들; 파일이 없는 경우 빈 배열 not null
            let files: [String]
            /// 채팅을 보낸 유저의 계정 정보
            let user: Member
        }
        
        /// 채널의 읽지 않은 채팅 개수
        /// Be returned .countUnreads
        struct CountOfUnread: Decodable {
            /// 채널 아이디
            let channelId: Int
            /// 채널명
            let name: String
            /// 특정 날짜 기준으로 쌓인 채팅개수
            let count: Int
        }
    }
    
    enum Store {
        struct BillingResult: Decodable {
            /// 결제 내역에 대한 아이디
            let billingId: Int
            /// 결제 시 등록한 상점 고유 번호
            let merchantUid: String
            /// 결제 금액
            let amount: Int
            /// 충전된 새싹 코인
            let sesacCoin: Int
            /// 결제 영수증 검증 성공 여부
            let success: Bool
            /// 결제 내역 생성 날짜
            let createdAt: Date
        }
        
        struct Item: Decodable {
            /// 금액을 결제하면 얻을 수 있는 새싹 코인
            let item: String
            /// 해당 새싹코인 아이템 가격
            let amount: String
            
            init(item: String, amount: String) {
                self.item = item
                self.amount = amount
            }
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
