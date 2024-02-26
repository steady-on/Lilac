//
//  ChannelService.swift
//  Lilac
//
//  Created by Roen White on 2/26/24.
//

import Foundation
import RxSwift

protocol ChannelService: AnyObject {
    /// 채널 생성
    func create(workspaceId: Int, name: String, description: String) -> Single<Result<Responder.Channel.Channel, Error>>
    
    /// 모든 채널 조회
    func loadAll(workspaceId: Int) -> Single<Result<[Responder.Channel.Channel], Error>>
    
    /// 내가 속한 모든 채널 조회
    func loadBelongTo(workspaceId: Int) -> Single<Result<[Responder.Channel.Channel], Error>>
    
    /// 특정 채널 조회; 반환값은 채널에 속한 멤버의 정보를 포함함
    func load(workspaceId: Int, channelName: String) -> Single<Result<Responder.Channel.Channel, Error>>
    
    /// 채널 편집
    func update(workspaceId: Int, channelName: String, name: String?, description: String?) -> Single<Result<Responder.Channel.Channel, Error>>
    
    /// 채널 삭제
    func delete(workspaceId: Int, channelName: String) -> Single<Result<Void, Error>>
    
    /// 채널에 채팅 보내기
    func sendChatting(workspaceId: Int, channelName: String, content: Data?, files: [Data]?) -> Single<Result<Responder.Channel.Chatting, Error>>
    
    /// 채널 채팅 조회; cursorDate가 nil이며 해당 채널 전체 채팅 데이터를 가져옴
    func loadChatting(workspaceId: Int, channelName: String, cursorDate: String?) -> Single<Result<[Responder.Channel.Chatting], Error>>
    
    /// 읽지 않은 채널 채팅 개수; cursorDate가 nil이면 count가 0으로 반환됨
    func countUnreads(workspaceId: Int, channelName: String, after: String?) -> Single<Result<Responder.Channel.CountOfUnreadChannelMessage, Error>>
    
    /// 채널 멤버 조회
    func loadAllMembers(workspaceId: Int, channelName: String) -> Single<Result<[Responder.Channel.Member], Error>>
    
    /// 채널 퇴장; 퇴장 후 워크스페이스 내에서 유저가 속한 채널 정보를 반환
    func leave(workspaceId: Int, channelName: String) -> Single<Result<[Responder.Channel.Channel], Error>>
    
    /// 채널 관리자 권한 변경; 채널 관리자가 바뀐 채널 정보를 반환
    func changeAdmin(workspaceId: Int, channelName: String, userId: Int) -> Single<Result<Responder.Channel.Channel, Error>>
}
