//
//  StoreServiceImpl.swift
//  Lilac
//
//  Created by Roen White on 3/1/24.
//

import Foundation
import RxSwift

final class StoreServiceImpl: StoreService {
    
    private let repository = LilacRepository<LilacAPI.Store>()
    
    func payValidation(impUid: String, merchantIid: String) -> Single<Result<Responder.Store.BillingResult, Error>> {
        return repository.request(.payValidation(impUid: impUid, merchantIid: merchantIid), responder: Responder.Store.BillingResult.self)
    }
    
    func loadStoreItemList() -> Single<Result<[Responder.Store.Item], Error>> {
        return repository.request(.itemList, responder: [Responder.Store.Item].self)
    }
}
