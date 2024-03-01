//
//  MyInfoViewModel.swift
//  Lilac
//
//  Created by Roen White on 3/1/24.
//

import Foundation
import RxSwift
import RxCocoa

final class MyInfoViewModel {
    var disposeBag = DisposeBag()
    
    private lazy var userService = UserServiceImpl()
}

extension MyInfoViewModel: ViewModel {
    struct Input {
        
    }
    
    struct Output {
        let myProfile: PublishRelay<MyProfile>
    }
    
    func transform(input: Input) -> Output {
        let myProfile = PublishRelay<MyProfile>()
        
        userService.loadMyProfile()
            .subscribe { result in
                switch result {
                case .success(let profileData):
                    User.shared.update(for: profileData)
                case .failure(let failure):
                    print("loadMyProfile failure", failure)
                }
            } onFailure: { error in
                print("loadMyProfile error", error)
            }
            .disposed(by: disposeBag)
        
        User.shared.profile
            .bind(to: myProfile)
            .disposed(by: disposeBag)
        
        return Output(
            myProfile: myProfile
        )
    }
}

