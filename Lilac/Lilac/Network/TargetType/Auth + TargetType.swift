//
//  Auth + TargetType.swift
//  Lilac
//
//  Created by Roen White on 1/6/24.
//

import Foundation
import Moya

extension LilacAPI.Auth: TargetType {
    var baseURL: URL {
        return URL(string: BaseURL.server + "auth")!
    }
    
    var path: String {
        return self.rawValue
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Moya.Task {
        return .requestPlain
    }
    
    var headers: [String : String]? {
        let headers = [
            "SesacKey": APIKey.secretKey,
            // TODO: keychain에 저장된 Token 값 가져오기
            "RefreshToken": ""
        ]
        
        return headers
    }
}
