//
//  User.swift
//  Lilac
//
//  Created by Roen White on 2/13/24.
//

import Foundation
import RxSwift
import RxCocoa

final class User {
    static let shared = User()
    private init() {}
    
    private let profile = PublishRelay<Responder.User.MyProfile>()
    
    func update(for profile: Responder.User.MyProfile) {
        self.profile.accept(profile)
    }
}
