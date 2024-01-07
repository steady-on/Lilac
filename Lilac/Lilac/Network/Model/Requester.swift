//
//  Requester.swift
//  Lilac
//
//  Created by Roen White on 1/6/24.
//

import Foundation

enum Requester {
    struct NewUser: Encodable {
        let email: String
        let password: String
        let nickname: String
        let phone: String?
    }
}
