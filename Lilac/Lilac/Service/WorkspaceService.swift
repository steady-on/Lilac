//
//  WorkspaceService.swift
//  Lilac
//
//  Created by Roen White on 2/26/24.
//

import Foundation
import RxSwift

protocol WorkspaceService: AnyObject {
    func create(name: Data, description: Data, image: Data) -> Single<Result<Responder.Workspace.Workspace, Error>>
    func loadAll() -> Single<Result<[Responder.Workspace.Workspace], Error>>
    func loadSpecified(id: Int) -> Single<Result<Responder.Workspace.Workspace, Error>>
    func updateInfo(id: Int, name: Data?, description: Data?, image: Data?) -> Single<Result<Responder.Workspace.Workspace, Error>>
    func delete(id: Int) -> Single<Result<Void, Error>>
    func search(id: Int, keyword: String) -> Single<Result<Responder.Workspace.Workspace, Error>>
    func leave(id: Int) -> Single<Result<[Responder.Workspace.Workspace], Error>>
    func admin(id: Int, to userId: Int) -> Single<Result<Responder.Workspace.Workspace, Error>>
    func inviteMember(to id: Int, email: String) -> Single<Result<Responder.Workspace.Member, Error>>
    func loadAllMembers(id: Int) -> Single<Result<[Responder.Workspace.Member], Error>>
    func loadAnyMember(id: Int) -> Single<Result<Responder.Workspace.Member, Error>>
}
