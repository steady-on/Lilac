//
//  Channel + TargetType.swift
//  Lilac
//
//  Created by Roen White on 2/26/24.
//

import Foundation
import Moya

extension LilacAPI.Channel: TargetType {
    var baseURL: URL {
        return URL(string: BaseURL.v1.server + "/workspaces")!
    }
    
    var path: String {
        switch self {
        case .create(let workspaceId, _, _), .loadAll(let workspaceId):
            return "\(workspaceId)/channels"
        case .loadBelongTo(let workspaceId):
            return "\(workspaceId)/channels/my"
        case .load(let workspaceId, let channelName), .update(let workspaceId, let channelName, _, _), .delete(let workspaceId, let channelName):
            return "\(workspaceId)/channels/\(channelName)"
        case .sendChatting(let workspaceId, let channelName, _, _), .loadChatting(let workspaceId, let channelName, _):
            return "\(workspaceId)/channels/\(channelName)/chats"
        case .countUnreads(let workspaceId, let channelName, _):
            return "\(workspaceId)/channels/\(channelName)/unreads"
        case .member(let workspaceId, let channelName):
            return "\(workspaceId)/channels/\(channelName)/members"
        case .leave(let workspaceId, let channelName):
            return "\(workspaceId)/channels/\(channelName)/leave"
        case .changeAdmin(let workspaceId, let channelName, let userId):
            return "\(workspaceId)/channels/\(channelName)/change/admin/\(userId)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .loadAll, .loadBelongTo, .load, .loadChatting, .countUnreads, .member, .leave:
            return .get
        case .create, .sendChatting:
            return .post
        case .update, .changeAdmin:
            return .put
        case .delete:
            return .delete
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .create(_, let name, let description):
            let parameters = [
                "name" : name,
                "description" : description
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .update(_, _, let name, let description):
            let parameters = [
                "name" : name ?? "",
                "description" : description ?? ""
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .sendChatting(_, _, let content, let files):
            var multiparts = [MultipartFormData]()
            
            if let content {
                let transition = MultipartFormData(provider: .data(content), name: "content")
                multiparts.append(transition)
            }
            // TODO: 추후 files 배열 처리
            return .uploadMultipart(multiparts)
        case .loadChatting(_, _, let cursorDate):
            let parameters = [ "cursor_date" : cursorDate ?? "" ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .countUnreads(_, _, let after):
            let parameters = [ "after" : after ?? "" ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        default:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return switch self {
        case .sendChatting:
            ["Content-Type" : "multipart/form-data"]
        default:
            [:]
        }
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
}
