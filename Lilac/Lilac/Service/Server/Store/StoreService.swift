//
//  StoreService.swift
//  Lilac
//
//  Created by Roen White on 3/1/24.
//

import Foundation
import RxSwift

protocol StoreService {
    /// 새싹 코인 결제 검증
    func payValidation(impUid: String, merchantIid: String) -> Single<Result<Responder.Store.BillingResult, Error>>
    
    /// 새싹 코인 스토어 아이템 리스트
    func loadStoreItemList() -> Single<Result<[Responder.Store.Item], Error>>
}
