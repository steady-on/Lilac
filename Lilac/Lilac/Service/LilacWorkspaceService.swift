//
//  LilacWorkspaceService.swift
//  Lilac
//
//  Created by Roen White on 1/26/24.
//

import Foundation
import RxSwift

final class LilacWorkspaceService {
    
    private let lilacWorkspaceRepository = LilacRepository<LilacAPI.Workspace>()
    
    func create(name: Data, description: Data, image: Data) -> Single<Result<Responder.Workspace.Workspace, Error>> {
        return lilacWorkspaceRepository.request(.create(name: name, description: description, image: image), responder: Responder.Workspace.Workspace.self)
    }
    
    func loadAll() -> Single<Result<[Responder.Workspace.Workspace], Error>> {
        return lilacWorkspaceRepository.request(.loadAll, responder: [Responder.Workspace.Workspace].self)
    }
    
    func loadSpecified(id: Int) -> Single<Result<Responder.Workspace.Workspace, Error>> {
        return lilacWorkspaceRepository.request(.load(id: id), responder: Responder.Workspace.Workspace.self)
    }
    
    func updateInfo(id: Int, name: Data?, description: Data?, image: Data?) -> Single<Result<Responder.Workspace.Workspace, Error>> {
        return lilacWorkspaceRepository.request(.update(id: id, name: name, description: description, image: image), responder: Responder.Workspace.Workspace.self)
    }
    
    func delete(id: Int) -> Single<Result<Void, Error>> {
        return lilacWorkspaceRepository.request(.delete(id: id))
    }
    
    func search(id: Int, keyword: String) -> Single<Result<Responder.Workspace.Workspace, Error>> {
        return lilacWorkspaceRepository.request(.search(id: id, keyword: keyword), responder: Responder.Workspace.Workspace.self)
    }
    
    func leave(id: Int) -> Single<Result<[Responder.Workspace.Workspace], Error>> {
        return lilacWorkspaceRepository.request(.leave(id: id), responder: [Responder.Workspace.Workspace].self)
    }
    
    func admin(id: Int, to userId: Int) -> Single<Result<Responder.Workspace.Workspace, Error>> {
        return lilacWorkspaceRepository.request(.admin(id: id, userId: userId), responder: Responder.Workspace.Workspace.self)
    }
    
    func inviteMember(to id: Int, email: String) -> Single<Result<Responder.Workspace.Member, Error>> {
        return lilacWorkspaceRepository.request(.member(id: id, type: .invite(email: email)), responder: Responder.Workspace.Member.self)
    }
    
    func loadAllMembers(id: Int) -> Single<Result<[Responder.Workspace.Member], Error>> {
        return lilacWorkspaceRepository.request(.member(id: id, type: .loadAll), responder: [Responder.Workspace.Member].self)
    }
    
    func loadAnyMember(id: Int) -> Single<Result<Responder.Workspace.Member, Error>> {
        return lilacWorkspaceRepository.request(.member(id: id, type: .load(userId: id)), responder: Responder.Workspace.Member.self)
    }
}
