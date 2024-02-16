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
    
    
    private var _workSpaces: [WorkSpace]? = nil {
        didSet {
            guard let _workSpaces else { return }
            workSpaces.accept(_workSpaces)
        }
    }
    
    let profile = PublishRelay<MyProfile>()
    let workSpaces = PublishRelay<[WorkSpace]>()
    
    func update(for profile: Responder.User.MyProfile) {
        let myProfile = MyProfile(from: profile)
        self.profile.accept(myProfile)
    }
    
    func update(for profile: Responder.User.ProfileWithToken) {
        let myProfile = MyProfile(from: profile)
        self.profile.accept(myProfile)
    }
    
    func fetch(for workSpacesData: [Responder.WorkSpace.WorkSpace]) {
        let workSpaces = workSpacesData.map { WorkSpace(from: $0) }
        self._workSpaces = workSpaces
        
    }
    
    func updateWorkSpaceDetail(for workSpaceData: Responder.WorkSpace.WorkSpace) {
        let workSpace = WorkSpace(from: workSpaceData)
        
        guard let index = _workSpaces?.firstIndex(where: { $0.workspaceId == workSpace.workspaceId }) else { return }
        _workSpaces?[index] = workSpace
    }
    
    func visitWorkSpace(id: Int) {
        lastVisitedWorkSpaceId = id
    }
}

}
