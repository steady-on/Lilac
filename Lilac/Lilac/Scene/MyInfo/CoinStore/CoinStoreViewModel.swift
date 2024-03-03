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
    
    private let userService = UserServiceImpl()
    private let storeService = StoreServiceImpl()
}

extension CoinStoreViewModel: ViewModel {
    struct Input {
        let paySuccess: PublishRelay<(imp_uid: String, merchant_uid: String)>
    }
    
    struct Output {
        let coinAndItemList: Observable<(Int, [Responder.Store.Item])>
        let showToast: PublishRelay<ToastAlert.Toast>
    }
    
    func transform(input: Input) -> Output {
        let itemList = PublishRelay<[Responder.Store.Item]>()
        let showToast = PublishRelay<ToastAlert.Toast>()
        
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
        
        let coinAndItemList = Observable.combineLatest(User.shared.profile, itemList)
            .map { comb in (User.shared.myCoin, comb.1) }
        
        let fetchProfile = PublishRelay<Void>()
        
        input.paySuccess
            .flatMap { [unowned self] response in
                storeService.payValidation(impUid: response.imp_uid, merchantIid: response.merchant_uid)
            }
            .subscribe { result in
                switch result {
                case .success(let success):
                    fetchProfile.accept(())
                    showToast.accept(.init(message: "\(success.amount) 코인이 충전 되었습니다.", style: .success))
                case .failure(let failure):
                    print("payValidation failure:", failure)
                }
            } onError: { error in
                print("payValidation error", error)
            }
            .disposed(by: disposeBag)
        
        fetchProfile
            .flatMap { [unowned self] _ in
                userService.loadMyProfile()
            }
            .subscribe { result in
                switch result {
                case .success(let myProfile):
                    User.shared.update(for: myProfile)
                case .failure(let failure):
                    print("loadMyProfile failure:", failure)
                }
            } onError: { error in
                print("loadMyProfile error", error)
            }
            .disposed(by: disposeBag)
        
        return Output(
            coinAndItemList: coinAndItemList,
            showToast: showToast
        )
    }
}
