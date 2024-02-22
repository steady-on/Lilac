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
    
    private var _workspaces = [Workspace]() {
        didSet {
            workspaces.accept(_workspaces)
        }
    }
    
    let profile = BehaviorRelay(value: MyProfile())
    let workspaces = BehaviorRelay(value: [Workspace]())
    
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
        let workspace = Workspace(from: newWorkspace)
        self._workspaces.append(workspace)
    }
    
    func fetch(for workspacesData: [Responder.Workspace.Workspace]) {
        let workspaces = workspacesData.map { Workspace(from: $0) }
        self._workspaces = workspaces
        
        manageLastVisitedWorkspace()
    }
    
    func updateWorkspaceDetail(for workspaceData: Responder.Workspace.Workspace) {
        let workspace = Workspace(from: workspaceData)
        
        guard let index = _workspaces.firstIndex(where: { $0.workspaceId == workspace.workspaceId }) else { return }
        _workspaces[index] = workspace
    }
    
    func visitWorkspace(id: Int) {
        lastVisitedWorkspaceId = id
    }
}

extension User {
    private func manageLastVisitedWorkspace() {
        guard _workspaces.firstIndex(where: { $0.workspaceId == lastVisitedWorkspaceId }) == nil else {
            return
        }
        
        let sortedWorkspaces = _workspaces.sorted(by: { $0.createdAt > $1.createdAt })
        guard let latestCreatedWorkspace = sortedWorkspaces.first else { return }
        
        lastVisitedWorkspaceId = latestCreatedWorkspace.workspaceId
    }
}
