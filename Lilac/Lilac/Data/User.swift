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
    @UserDefault(key: .lastVisitedWorkspaceId, defaultValue: Optional<Int>(nil)) var lastVisitedWorkspaceId
    
    private var _workSpaces = [Workspace]() {
        didSet {
            workSpaces.accept(_workSpaces)
        }
    }
    
    let profile = BehaviorRelay(value: MyProfile())
    let workSpaces = BehaviorRelay(value: [Workspace]())
    
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
    
    func add(for newWorkspace: Responder.Workspace.Workspace) {
        let workSpace = Workspace(from: newWorkspace)
        self._workSpaces.append(workSpace)
    }
    
    func fetch(for workSpacesData: [Responder.Workspace.Workspace]) {
        let workSpaces = workSpacesData.map { Workspace(from: $0) }
        self._workSpaces = workSpaces
        
        manageLastVisitedWorkspace()
    }
    
    func updateWorkspaceDetail(for workSpaceData: Responder.Workspace.Workspace) {
        let workSpace = Workspace(from: workSpaceData)
        
        guard let index = _workSpaces.firstIndex(where: { $0.workspaceId == workSpace.workspaceId }) else { return }
        _workSpaces[index] = workSpace
    }
    
    func visitWorkspace(id: Int) {
        lastVisitedWorkspaceId = id
    }
}

extension User {
    private func manageLastVisitedWorkspace() {
        guard _workSpaces.firstIndex(where: { $0.workspaceId == lastVisitedWorkspaceId }) == nil else {
            return
        }
        
        let sortedWorkspaces = _workSpaces.sorted(by: { $0.createdAt > $1.createdAt })
        guard let latestCreatedWorkspace = sortedWorkspaces.first else { return }
        
        lastVisitedWorkspaceId = latestCreatedWorkspace.workspaceId
    }
}
