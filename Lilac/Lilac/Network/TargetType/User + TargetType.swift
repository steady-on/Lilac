//
//  User + TargetType.swift
//  Lilac
//
//  Created by Roen White on 1/6/24.
//

import Foundation
import Moya

extension LilacAPI.User: TargetType {
    var baseURL: URL {
        return URL(string: BaseURL.server + "users")!
    }
    
    var path: String {
        switch self {
        case .signUp: 
            return "join"
        case .validateEmail: 
            return "validation/email"
        case .signIn(let vendor):
            return switch vendor {
            case .email: "login"
            case .kakao: "login/kakao"
            case .apple: "login/apple"
            }
        case .signOut: 
            return "logout"
        case .saveDeviceToken:
            return "deviceToken"
        case .myProfile(let type):
            return switch type {
            case .askForMyInfo, .editInfo: "my"
            case .editImage: "my/image"
            }
        case .askForOtherUserProfile(let id):
            return "\(id)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .signUp, .validateEmail, .signIn, .saveDeviceToken:
            return .post
        case .signOut, .myProfile(type: .askForMyInfo), .askForOtherUserProfile:
            return .get
        case .myProfile(type: .editInfo), .myProfile(type: .editImage):
            return .post
        }
    }
    
    var task: Moya.Task {
        let parameters: [String : Any] = switch self {
        case .signUp(let userInfo):
            [
                "email" : userInfo.email,
                "password" : userInfo.password,
                "nickname" : userInfo.nickname,
                "phone" : userInfo.phone ?? "",
                // TODO: keycahin setting 후 가져오기
                "deviceToken" : "",
            ]
        case .validateEmail(let email):
            ["email" : email]
        case .signIn(let vendor):
            switch vendor {
            case .email(let email, let password):
                [
                    "email" : email,
                    "password" : password,
                    // TODO: keycahin setting 후 가져오기
                    "deviceToken" : "",
                ]
            case .kakao:
                // TODO: keycahin setting 후 가져오기
                [
                    "oauthToken" : "",
                    "deviceToken" : "",
                ]
            case .apple:
                [
                    "idToken" : "",
                    "nickname" : "",
                    // TODO: keycahin setting 후 가져오기
                    "deviceToken" : ""
                ]
            }
        case .signOut:
            [:]
        case .saveDeviceToken:
            // TODO: keycahin setting 후 가져오기
            ["deviceToken" : ""]
        case .myProfile(let type):
            switch type {
            case .askForMyInfo:
                [:]
            case .editInfo(let nickname, let phone):
                [
                    "nickname" : nickname ?? "",
                    "phone" : phone ?? ""
                ]
            case .editImage(let image):
                ["image" : image]
            }
        case .askForOtherUserProfile:
            [:]
        }
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
    }
    
    var headers: [String : String]? {
        let commons = ["SesacKey" : APIKey.secretKey]
        
        let specified: [String : String] = switch self {
        case .myProfile(type: .editImage):
            // TODO: keycahin setting 후 가져오기
            [
                "Authorization" : "",
                "Content-Type" : "multipart/form-data"
            ]
        case .signOut, .saveDeviceToken, .myProfile, .askForOtherUserProfile:
            // TODO: keycahin setting 후 가져오기
            ["Authorization" : ""]
        default:
            [:]
        }
        
        return commons.merging(specified) { current, _ in current }
    }
}
