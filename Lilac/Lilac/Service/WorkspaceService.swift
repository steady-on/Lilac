//
//  WorkspaceService.swift
//  Lilac
//
//  Created by Roen White on 2/26/24.
//

import Foundation
import RxSwift

protocol WorkspaceService: AnyObject {
    /// 워크스페이스 생성
    func create(name: Data, description: Data, image: Data) -> Single<Result<Responder.Workspace.Workspace, Error>>
    
    /// User가 속한 모든 워크스페이스 조회
    func loadAll() -> Single<Result<[Responder.Workspace.Workspace], Error>>
    
    /// User가 속한 특정 워크스페이스 1개 조회
    func loadSpecified(id: Int) -> Single<Result<Responder.Workspace.Workspace, Error>>
    
    /// 워크스페이스 정보 편집
    func updateInfo(id: Int, name: Data?, description: Data?, image: Data?) -> Single<Result<Responder.Workspace.Workspace, Error>>
    
    /// 워크스페이스 삭제
    func delete(id: Int) -> Single<Result<Void, Error>>
    
    /// 워크스페이스 내 검색
    func search(id: Int, keyword: String) -> Single<Result<Responder.Workspace.Workspace, Error>>
    
    /// 워크스페이스 퇴장
    func leave(id: Int) -> Single<Result<[Responder.Workspace.Workspace], Error>>
    
    /// 워크스페이스 관리자 권한 변경
    func admin(id: Int, to userId: Int) -> Single<Result<Responder.Workspace.Workspace, Error>>
    
    /// 워크스페이스에 멤버 초대
    func inviteMember(to id: Int, email: String) -> Single<Result<Responder.Workspace.Member, Error>>
    
    /// 워크스페이스에 속한 모든 멤버 조회
    func loadAllMembers(id: Int) -> Single<Result<[Responder.Workspace.Member], Error>>
    
    /// 워크스페이스에 속한 특정 멤버 조회
    func loadAnyMember(id: Int) -> Single<Result<Responder.Workspace.Member, Error>>
}
