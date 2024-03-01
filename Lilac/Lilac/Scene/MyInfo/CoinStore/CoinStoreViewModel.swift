//
//  CoinStoreViewModel.swift
//  Lilac
//
//  Created by Roen White on 3/1/24.
//

import Foundation
import RxSwift
import RxCocoa

final class CoinStoreViewModel {
    var disposeBag = DisposeBag()
    
    private let storeService = StoreServiceImpl()
}

extension CoinStoreViewModel: ViewModel {
    struct Input {
        
    }
    
    struct Output {
        let itemList: PublishRelay<[Responder.Store.Item]>
    }
    
    func transform(input: Input) -> Output {
        let itemList = PublishRelay<[Responder.Store.Item]>()
        
        storeService.loadStoreItemList()
            .subscribe { result in
                switch result {
                case .success(let items):
                    itemList.accept(items)
                case .failure(let failure):
                    print("loadStoreItemList failure:", failure)
                }
            } onFailure: { error in
                print("loadStoreItemList error", error)
            }
            .disposed(by: disposeBag)
        
        return Output(
            itemList: itemList
        )
    }
}
