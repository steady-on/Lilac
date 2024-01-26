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
        return URL(string: BaseURL.v1.server + "users")!
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
            case .load, .updateInfo: "my"
            case .updateImage: "my/image"
            }
        case .otherUserProfile(let id):
            return "\(id)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .signUp, .validateEmail, .signIn, .saveDeviceToken:
            return .post
        case .signOut, .myProfile(type: .load), .otherUserProfile:
            return .get
        case .myProfile(type: .updateInfo), .myProfile(type: .updateImage):
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
                    "deviceToken" : "",
                ]
            case .kakao(let accessToken):
                [
                    "oauthToken" : accessToken,
                    "deviceToken" : "",
                ]
            case .apple:
                [
                    "idToken" : "",
                    "nickname" : "",
                    "deviceToken" : ""
                ]
            }
        case .saveDeviceToken:
            // TODO: keycahin setting 후 가져오기
            ["deviceToken" : ""]
        case .myProfile(let type):
            switch type {
            case .load:
                [:]
            case .updateInfo(let nickname, let phone):
                [
                    "nickname" : nickname ?? "",
                    "phone" : phone ?? ""
                ]
            case .updateImage(let image):
                ["image" : image]
            }
        default:
            [:]
        }
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
    }
    
    var headers: [String : String]? {
        return switch self {
        case .myProfile(type: .updateImage):
            [ "Content-Type" : "multipart/form-data" ]
        default:
            [:]
        }
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
}
