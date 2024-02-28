//
//  WebSocketManager.swift
//  Lilac
//
//  Created by Roen White on 2/29/24.
//

import Foundation
import SocketIO

final class WebSocketManager: NSObject {
    static let shared = WebSocketManager()
    
    private override init() {
        super.init()
    }
    
    @KeychainStorage(itemType: .accessToken) var accessToken
    
    private var manager: SocketManager! = nil
    private var socket: SocketIOClient! = nil
    
    // {baseURL}/ws-channel-{channel_id}
    // {baseURL}/ws-dm-{room_id}
    func openWebSocket(for id: Int, type: SocketType) {
        print(#function)
        guard let url = URL(string: BaseURL.serverURL + "ws-\(type.rawValue)-\(id)") else { return }
        
        let headers: [String : String] = [
            "Authorization" : accessToken ?? "",
            "SesacKey" : APIKey.secretKey
        ]
        
        manager = SocketManager(socketURL: url, config: [.log(false), .compress, .extraHeaders(headers)])
        socket = manager.defaultSocket
        
        socket.on(clientEvent: .connect) { data, ack in
            print("SOCKET IS CONNECTED", data, ack)
        }
        
        receive(type: type)
    }
    
    private func receive(type: SocketType) {
        print(#function)
        socket.on(type.rawValue) { dataArray, ack in
            print("CHANNEL RECEIVED", dataArray, ack)
        }
    }
    
    func closeWebSocket() {
        print(#function)
        socket.on(clientEvent: .disconnect) { data, ack in
            print("SOCKET IS DISCONNECTED", data, ack)
        }
    }
}

extension WebSocketManager {
    enum SocketType: String {
        case channel
        case dm
    }
}
