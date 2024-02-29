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
    
    private var manager: SocketManager! = nil
    private var socket: SocketIOClient! = nil
    
    func openWebSocket(for id: Int, type: SocketType, completion: @escaping (Data) -> Void) {
        guard let url = URL(string: BaseURL.serverURL) else { return }
        
        manager = SocketManager(socketURL: url, config: [.compress])
        socket = manager.socket(forNamespace: "/ws-\(type.rawValue)-\(id)")

        socket.on(type.rawValue) { response, _ in
            guard let response = response.first,
                  let data = try? JSONSerialization.data(withJSONObject: response) else { return}

            completion(data)
        }
        
        socket.connect()
    }
    
    func closeWebSocket() {
        socket.disconnect()
        socket.removeAllHandlers()
        manager.disconnect()
    }
}

extension WebSocketManager {
    enum SocketType: String {
        case channel
        case dm
    }
}
