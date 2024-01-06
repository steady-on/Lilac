//
//  Responder.swift
//  Lilac
//
//  Created by Roen White on 1/6/24.
//

import Foundation

struct Responder {
    struct Auth: Decodable {
        let accessToken: String
    }
    
    struct SignUp: Decodable {
        let token: Token
    }
    
    struct SignIn: Decodable {
        let nickname, accessToken, refreshToken: String
    }

    struct Error: Decodable {
        let errorCode: String
    }
}

extension Responder {
    struct Token: Decodable {
        let accessToken, refreshToken: String
    }
}
