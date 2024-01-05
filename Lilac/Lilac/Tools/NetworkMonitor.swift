//
//  NetworkMonitor.swift
//  Lilac
//
//  Created by Roen White on 1/5/24.
//

import Foundation
import RxCocoa
import Network

final class NetworkMonitor {
    static let shared = NetworkMonitor()
    private init() {}
    
    private let queue = DispatchQueue(label: "NetworkMonitor", qos: .background)
    private let monitor = NWPathMonitor()
    
    let currentStatus = PublishRelay<NWPath.Status>()
    
    func startMonitoring() {
        monitor.start(queue: queue)
        
        currentStatus.accept(monitor.currentPath.status)
        
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.sync {
                self?.currentStatus.accept(path.status)
            }
        }
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
}
