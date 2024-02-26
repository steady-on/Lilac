//
//  HomeViewModel.swift
//  Lilac
//
//  Created by Roen White on 2/24/24.
//

import Foundation
import RxSwift
import RxCocoa

final class HomeViewModel {
    var disposeBag = DisposeBag()
    
    private lazy var lilacWorkspaceService = WorkspaceServiceImpl()
}

extension HomeViewModel: ViewModel {
    struct Input {
        
    }
    
    struct Output {
        let selectedWorkspace: PublishRelay<Workspace>
    }
    
    func transform(input: Input) -> Output {
        let selectedWorkspace = PublishRelay<Workspace>()
        
        User.shared.selectedWorkspaceId
            .flatMap { [unowned self] id in
                lilacWorkspaceService.loadSpecified(id: id)
            }
            .subscribe { result in
                switch result {
                case .success(let workspace):
                    User.shared.updateWorkspaceDetail(for: workspace)
                    selectedWorkspace.accept(Workspace(from: workspace))
                case .failure(let error):
                    print("failure", error)
                }
            } onError: { error in
                print("Error", error)
            }
            .disposed(by: disposeBag)
        
        return Output(
            selectedWorkspace: selectedWorkspace
        )
    }
}
