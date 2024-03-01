//
//  Store + TargetType.swift
//  Lilac
//
//  Created by Roen White on 3/1/24.
//

import Foundation
import Moya

extension LilacAPI.Store: TargetType {
    var baseURL: URL {
        return URL(string: BaseURL.v1.server + "/store")!
    }
    
    var path: String {
        switch self {
        case .payValidation:
            return "pay/validation"
        case .itemList:
            return "item/list"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .payValidation:
            return .post
        case .itemList:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .payValidation(let impUid, let merchantIid):
            let parameters = [
                "imp_uid" : impUid,
                "merchant_uid" : merchantIid
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .itemList:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        [:]
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
}
