//
//  EntryViewModel.swift
//  Lilac
//
//  Created by Roen White on 1/25/24.
//

import Foundation
import RxSwift

final class EntryViewModel {
    var disposeBag = DisposeBag()
    
    private lazy var networkMonitor = NetworkMonitor.shared
}

extension EntryViewModel: ViewModel {
    struct Input {}
    
    struct Output {}
    
    func transform(input: Input) -> Output {
        
    }
}
