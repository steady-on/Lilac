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
    
    private let profile = PublishRelay<MyProfile>()
    
    func update(for profile: Responder.User.MyProfile) {
        let myProfile = MyProfile(from: profile)
        self.profile.accept(myProfile)
    }
    
    func update(for profile: Responder.User.ProfileWithToken) {
        let myProfile = MyProfile(from: profile)
        self.profile.accept(myProfile)
    }
}
