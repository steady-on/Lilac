//
//  WorkSpace + TargetType.swift
//  Lilac
//
//  Created by Roen White on 1/24/24.
//

import Foundation
import Moya

extension LilacAPI.WorkSpace: TargetType {
    var baseURL: URL {
        return URL(string: BaseURL.v1.server + "workspaces")!
    }
    
    var path: String {
        switch self {
        case .create, .loadAll: return ""
        case .load(let id), .update(let id, _, _, _), .delete(let id): return "\(id)"
        case .search(let id, _): return "\(id)/search"
        case .leave(let id): return "\(id)/leave"
        case .admin(let workspaceId, let userId): return "\(workspaceId)/change/admin/\(userId)"
        case .member(let id, let type):
            return switch type {
            case .invite, .loadAll: "\(id)/members"
            case .load(let userId): "\(id)/members/\(userId)"
            }
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .create, .member(_, .invite): return .post
        case .loadAll, .load, .search, .leave, .member(_, type: .loadAll), .member(_, type: .load): return .get
        case .update, .admin: return .put
        case .delete: return .delete
        }
    }
    
    var task: Moya.Task {
        let parameters: [String : Any] = switch self {
        case .create(let name, let description, let image):
            [
                "name" : name,
                "description" : description ?? "",
                "image" : image
            ]
        case .update(_, let name, let description, let image):
            [
                "name" : name ?? "",
                "description" : description ?? "",
                "image" : image ?? ""
            ]
        case .search(_, let keyword):
            [ "keyword" : keyword ]
        default:
            [:]
        }
        
//        return switch self {
//        case .search: .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
//        default: 
//        }
        
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
    }
    
    var headers: [String : String]? {
        let commons = [
            "SesacKey" : APIKey.secretKey,
            // TODO: keycahin setting 후 가져오기
            "Authorization" : ""
        ]
        
        let specified: [String : String] = switch self {
        case .create, .update:
            ["Content-Type" : "multipart/form-data"]
        default:
            [:]
        }
        
        return commons.merging(specified) { current, _ in current }
    }
}
