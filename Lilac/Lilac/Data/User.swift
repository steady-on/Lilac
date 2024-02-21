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
    
    @UserDefault(key: .nickname, defaultValue: "") var nickname
    @UserDefault(key: .email, defaultValue: "") var email
    @UserDefault(key: .lastVisitedWorkSpaceId, defaultValue: Optional<Int>(nil)) var lastVisitedWorkSpaceId
    
    private var _workSpaces = [WorkSpace]() {
        didSet {
            workSpaces.accept(_workSpaces)
        }
    }
    
    let profile = BehaviorRelay(value: MyProfile())
    let workSpaces = BehaviorRelay(value: [WorkSpace]())
    
    func update(for profile: Responder.User.MyProfile) {
        let myProfile = MyProfile(from: profile)
        nickname = myProfile.nickname
        email = myProfile.email
        self.profile.accept(myProfile)
    }
    
    func update(for profile: Responder.User.ProfileWithToken) {
        let myProfile = MyProfile(from: profile)
        nickname = myProfile.nickname
        email = myProfile.email
        self.profile.accept(myProfile)
    }
    
    func add(for newWorkSpace: Responder.WorkSpace.WorkSpace) {
        let workSpace = WorkSpace(from: newWorkSpace)
        self._workSpaces.append(workSpace)
    }
    
    func fetch(for workSpacesData: [Responder.WorkSpace.WorkSpace]) {
        let workSpaces = workSpacesData.map { WorkSpace(from: $0) }
        self._workSpaces = workSpaces
        
        manageLastVisitedWorkSpace()
    }
    
    func updateWorkSpaceDetail(for workSpaceData: Responder.WorkSpace.WorkSpace) {
        let workSpace = WorkSpace(from: workSpaceData)
        
        guard let index = _workSpaces.firstIndex(where: { $0.workspaceId == workSpace.workspaceId }) else { return }
        _workSpaces[index] = workSpace
    }
    
    func visitWorkSpace(id: Int) {
        lastVisitedWorkSpaceId = id
    }
}

extension User {
    private func manageLastVisitedWorkSpace() {
        guard _workSpaces.firstIndex(where: { $0.workspaceId == lastVisitedWorkSpaceId }) == nil else {
            return
        }
        
        let sortedWorkSpaces = _workSpaces.sorted(by: { $0.createdAt > $1.createdAt })
        guard let latestCreatedWorkSpace = sortedWorkSpaces.first else { return }
        
        lastVisitedWorkSpaceId = latestCreatedWorkSpace.workspaceId
    }
}
