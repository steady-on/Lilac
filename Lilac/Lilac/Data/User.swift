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
    
    @UserDefault(key: .nickname, defaultValue: "") private var nickname
    @UserDefault(key: .email, defaultValue: "") private var email
    @UserDefault(key: .lastVisitedWorkspaceId, defaultValue: -1) private var lastVisitedWorkspaceId
    
    private var _workspaces = [Workspace]() {
        didSet {
            workspaces.accept(_workspaces)
        }
    }
    
    let profile = BehaviorRelay(value: MyProfile())
    let workspaces = BehaviorRelay(value: [Workspace]())
    let selectedWorkspaceId = BehaviorRelay(value: -1)
    
    var selectedWorkspace: Workspace! {
        // workspaceId가 0보다 크다는 건, _workspaces 안에 workspace가 있다는 것
        guard lastVisitedWorkspaceId > 0 else { return nil }
        return _workspaces.first { $0.workspaceId == lastVisitedWorkspaceId }
    }
    
    var isNotBelongToWorkspace: Bool {
        _workspaces.isEmpty
    }
    
    /// 유저 프로필 업데이트
    func update(for profile: Responder.User.MyProfile) {
        let myProfile = MyProfile(from: profile)
        nickname = myProfile.nickname
        email = myProfile.email
        self.profile.accept(myProfile)
    }
    
    /// 유저 프로필 업데이트
    func update(for profile: Responder.User.ProfileWithToken) {
        let myProfile = MyProfile(from: profile)
        nickname = myProfile.nickname
        email = myProfile.email
        self.profile.accept(myProfile)
    }
    
    /// 워크스페이스 추가
    func add(for newWorkspace: Responder.Workspace.Workspace) {
        let workspace = Workspace(from: newWorkspace)
        self._workspaces.append(workspace)
    }
    
    /// 유저가 속한 워크스페이스 업데이트
    func fetch(for workspacesData: [Responder.Workspace.Workspace]) {
        guard workspacesData.isEmpty == false else {
            visitWorkspace(id: -1) // 유저가 속한 워크스페이스가 없으면 초기화 해줌
            return
        }
        
        let workspaces = workspacesData.map { Workspace(from: $0) }
        self._workspaces = workspaces
        
        manageLastVisitedWorkspace()
    }
    
    /// 워크스페이스 자체를 바꿈
    func updateWorkspaceDetail(for workspaceData: Responder.Workspace.Workspace) {
        let workspace = Workspace(from: workspaceData)
        
        guard let index = _workspaces.firstIndex(where: { $0.workspaceId == workspace.workspaceId }) else { return }
        _workspaces[index] = workspace
    }
    
    /// 채널리스트를 업데이트한 워크스페이스를 반환
    func fetchChannelToWorkspace(_ channelData: [Responder.Channel.Channel]) -> Workspace? {
        let channels = channelData.map { Channel(from: $0) }
        
        guard let workspaceId = channels.first?.workspaceId,
              let index = _workspaces.firstIndex(where: { $0.workspaceId == workspaceId }) else { return nil }
        
        _workspaces[index].channels = channels
        return _workspaces[index]
    }
    
    func visitWorkspace(id: Int) {
        lastVisitedWorkspaceId = id
        selectedWorkspaceId.accept(lastVisitedWorkspaceId)
    }
}

extension User {
    private func manageLastVisitedWorkspace() {
        guard _workspaces.contains(where: { $0.workspaceId == lastVisitedWorkspaceId }) == false else {
            selectedWorkspaceId.accept(lastVisitedWorkspaceId)
            return
        }
        
        let sortedWorkspaces = _workspaces.sorted(by: { $0.createdAt > $1.createdAt })
        guard let latestCreatedWorkspace = sortedWorkspaces.first else { return }
        
        visitWorkspace(id: latestCreatedWorkspace.workspaceId)
    }
}
