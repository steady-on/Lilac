//
//  LilacWorkSpaceService.swift
//  Lilac
//
//  Created by Roen White on 1/26/24.
//

import Foundation
import RxSwift

final class LilacWorkSpaceService {
    
    private let lilacWorkSpaceRepository = LilacRepository<LilacAPI.WorkSpace>()
    
    func create(name: Data, description: Data, image: Data) -> Single<Result<Responder.WorkSpace.WorkSpace, Error>> {
        return lilacWorkSpaceRepository.request(.create(name: name, description: description, image: image), responder: Responder.WorkSpace.WorkSpace.self)
    }
    
    func loadAll() -> Single<Result<[Responder.WorkSpace.WorkSpace], Error>> {
        return lilacWorkSpaceRepository.request(.loadAll, responder: [Responder.WorkSpace.WorkSpace].self)
    }
    
    func loadSpecified(id: Int) -> Single<Result<Responder.WorkSpace.WorkSpace, Error>> {
        return lilacWorkSpaceRepository.request(.load(id: id), responder: Responder.WorkSpace.WorkSpace.self)
    }
    
    func updateInfo(id: Int, name: String?, description: String?, image: Data?) -> Single<Result<Responder.WorkSpace.WorkSpace, Error>> {
        return lilacWorkSpaceRepository.request(.update(id: id, name: name, description: description, image: image), responder: Responder.WorkSpace.WorkSpace.self)
    }
    
    func delete(id: Int) -> Single<Result<Void, Error>> {
        return lilacWorkSpaceRepository.request(.delete(id: id))
    }
    
    func search(id: Int, keyword: String) -> Single<Result<Responder.WorkSpace.WorkSpace, Error>> {
        return lilacWorkSpaceRepository.request(.search(id: id, keyword: keyword), responder: Responder.WorkSpace.WorkSpace.self)
    }
    
    func leave(id: Int) -> Single<Result<[Responder.WorkSpace.WorkSpace], Error>> {
        return lilacWorkSpaceRepository.request(.leave(id: id), responder: [Responder.WorkSpace.WorkSpace].self)
    }
    
    func admin(id: Int, to userId: Int) -> Single<Result<Responder.WorkSpace.WorkSpace, Error>> {
        return lilacWorkSpaceRepository.request(.admin(id: id, userId: userId), responder: Responder.WorkSpace.WorkSpace.self)
    }
    
    func inviteMember(to id: Int, email: String) -> Single<Result<Responder.WorkSpace.Member, Error>> {
        return lilacWorkSpaceRepository.request(.member(id: id, type: .invite(email: email)), responder: Responder.WorkSpace.Member.self)
    }
    
    func loadAllMembers(id: Int) -> Single<Result<[Responder.WorkSpace.Member], Error>> {
        return lilacWorkSpaceRepository.request(.member(id: id, type: .loadAll), responder: [Responder.WorkSpace.Member].self)
    }
    
    func loadAnyMember(id: Int) -> Single<Result<Responder.WorkSpace.Member, Error>> {
        return lilacWorkSpaceRepository.request(.member(id: id, type: .load(userId: id)), responder: Responder.WorkSpace.Member.self)
    }
}
