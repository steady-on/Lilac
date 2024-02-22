//
//  WelcomeViewModel.swift
//  Lilac
//
//  Created by Roen White on 2/17/24.
//

import Foundation
import RxSwift
import RxCocoa

final class WelcomeViewModel {
    var disposeBag = DisposeBag()
    
    private lazy var lilacWorkspaceService = LilacWorkspaceService()
}

extension WelcomeViewModel: ViewModel {
    struct Input {
        let closeButtonTapped: ControlEvent<Void>
    }
    
    struct Output {
        let goToHome: PublishRelay<Void>
    }
    
    func transform(input: Input) -> Output {
        let goToHome = PublishRelay<Void>()
        
        input.closeButtonTapped
            .flatMap { [unowned self] _ in
                lilacWorkspaceService.loadAll()
            }
            .subscribe { result in
                switch result {
                case .success(let workspaces):
                    User.shared.fetch(for: workspaces)
                case .failure(_):
                    break
                }
                
                goToHome.accept(())
                
            } onError: { _ in
                goToHome.accept(())
            }
            .disposed(by: disposeBag)

        
        return Output(goToHome: goToHome)
    }
}
