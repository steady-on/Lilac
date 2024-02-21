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
        switch self {
        case .create(let name, let description, let image):
            let nameData = MultipartFormData(provider: .data(name), name: "name")
            let descriptionData = MultipartFormData(provider: .data(description), name: "description")
            let imageData = MultipartFormData(provider: .data(image), name: "image", fileName: "\(Date.now).jpeg" , mimeType: "image/jpeg")
            return .uploadMultipart([nameData, descriptionData, imageData])
        case .update(_, let name, let description, let image):
            var multiparts = [MultipartFormData]()
            
            if let name {
                let transition = MultipartFormData(provider: .data(name), name: "name")
                multiparts.append(transition)
            }
            
            if let description {
                let transition = MultipartFormData(provider: .data(description), name: "description")
                multiparts.append(transition)
            }
            
            if let image {
                let transition = MultipartFormData(provider: .data(image), name: "image", fileName: "\(Date.now).jpeg" , mimeType: "image/jpeg")
                multiparts.append(transition)
            }
            
            return .uploadMultipart(multiparts)
        case .search(let id, let keyword):
            let parameters = [ "keyword" : keyword ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        default:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return switch self {
        case .create, .update:
            ["Content-Type" : "multipart/form-data"]
        default:
            [:]
        }
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
}
