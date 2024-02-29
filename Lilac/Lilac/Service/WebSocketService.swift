//
//  WebSocketService.swift
//  Lilac
//
//  Created by Roen White on 2/29/24.
//

import Foundation
import RxSwift
import RxCocoa

final class WebSocketService {
    static let shared = WebSocketService()
    
    private init() {}
    
    let channelReceiver = PublishRelay<Responder.Channel.Chatting>()
    
    func connectChannelSocket(for channelId: Int) {
        WebSocketManager.shared.openWebSocket(for: channelId, type: .channel) { [unowned self] data in
            handleChannelRecieved(data)
        }
    }
    
    func disconnetSocket() {
        WebSocketManager.shared.closeWebSocket()
    }
}

extension WebSocketService {
    private func handleChannelRecieved(_ data: Data) {
        let decoder = setJSONDecoder()
        
        do {
            let chatting = try decoder.decode(Responder.Channel.Chatting.self, from: data)
            channelReceiver.accept(chatting)
        } catch {
            print("Received Socket Data cannot decoding: ", error)
        }
    }
}

extension WebSocketService {
    private func setDateFormat() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        return dateFormatter
    }
    
    private func setJSONDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .formatted(setDateFormat())
        return decoder
    }
}
