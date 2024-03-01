//
//  LilacAPI.swift
//  Lilac
//
//  Created by Roen White on 1/6/24.
//

import Foundation

enum LilacAPI {
    enum Auth: String {
        case refresh
    }
    
    enum User {
        /// 회원가입
        case signUp(userInfo: Requester.NewUser, deviceToken: String)
        /// 이메일 중복 확인
        case validateEmail(email: String)
        /// 로그인
        case signIn(vendor: Vendor, deviceToken: String)
        /// 로그아웃
        case signOut
        /// FCM deviceToken 저장
        case saveDeviceToken(deviceToken: String)
        /// 내 프로필 정보 조회, 수정
        case myProfile(type: MyProfile)
        /// 다른 유저 프로필 조회
        case otherUserProfile(id: Int)
        
        enum Vendor {
            /// 이메일 로그인
            case email(email: String, password: String)
            /// 카카오 로그인
            case kakao(accessToken: String)
            /// 애플 로그인
            case apple
        }
        
        enum MyProfile {
            /// 내 프로필 정보 조회
            case load
            /// 내 프로필 정보 수정(이미지 제외)
            case updateInfo(nickname: String?, phone: String?)
            /// 내 프로필 이미지 수정
            case updateImage(image: Data)
        }
    }
    
    enum Workspace {
        /// 워크스페이스 생성
        case create(name: Data, description: Data, image: Data)
        /// User가 속한 모든 워크스페이스 조회
        case loadAll
        /// User가 속한 특정 워크스페이스 1개 조회
        case load(id: Int)
        /// 워크스페이스 정보 편집
        case update(id: Int, name: Data?, description: Data?, image: Data?)
        /// 워크스페이스 삭제
        case delete(id: Int)
        /// 워크스페이스 내 검색
        case search(id: Int, keyword: String)
        /// 워크스페이스 퇴장
        case leave(id: Int)
        /// 워크스페이스 관리자 권한 변경
        case admin(id: Int, userId: Int)
        /// 워크스페이스의 멤버 초대, 조회
        case member(id: Int, type: Member)

        enum Member {
            /// 워크스페이스에 멤버 초대
            case invite(email: String)
            /// 워크스페이스에 속한 모든 멤버 조회
            case loadAll
            /// 워크스페이스에 속한 특정 멤버 조회
            case load(userId: Int)
        }
    }
    
    enum Channel {
        /// 채널 생성
        case create(workspaceId: Int, name: String, description: String)
        /// 모든 채널 조회
        case loadAll(workspaceId: Int)
        /// 내가 속한 모든 채널 조회
        case loadBelongTo(workspaceId: Int)
        /// 특정 채널 조회; 반환값은 채널에 속한 멤버의 정보를 포함함
        case load(workspaceId: Int, channelName: String)
        /// 채널 편집
        case update(workspaceId: Int, channelName: String, name: String?, description: String?)
        /// 채널 삭제
        case delete(workspaceId: Int, channelName: String)
        /// 채널에 채팅 보내기
        case sendChatting(workspaceId: Int, channelName: String, content: Data?, files: [Data]?)
        /// 채널 채팅 조회; cursorDate가 nil이며 해당 채널 전체 채팅 데이터를 가져옴
        case loadChatting(workspaceId: Int, channelName: String, cursorDate: String?)
        /// 읽지 않은 채널 채팅 개수; cursorDate가 nil이면 count가 0으로 반환됨
        case countUnreads(workspaceId: Int, channelName: String, after: String?)
        /// 채널 멤버 조회
        case member(workspaceId: Int, channelName: String)
        /// 채널 퇴장; 퇴장 후 워크스페이스 내에서 유저가 속한 채널 정보를 반환
        case leave(workspaceId: Int, channelName: String)
        /// 채널 관리자 권한 변경; 채널 관리자가 바뀐 채널 정보를 반환
        case changeAdmin(workspaceId: Int, channelName: String, userId: Int)
    }
}
