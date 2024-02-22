//
//  AddWorkspaceViewModel.swift
//  Lilac
//
//  Created by Roen White on 2/19/24.
//

import UIKit
import RxSwift
import RxCocoa

final class AddWorkspaceViewModel {
    
    deinit {
        print("deinit AddWorkspaceViewModel")
    }
    
    var disposeBag = DisposeBag()
    
    private lazy var lilacWorkspaceService = LilacWorkspaceService()
}

extension AddWorkspaceViewModel: ViewModel {
    struct Input {
        let selectedImage: BehaviorRelay<UIImage?>
        let nameInputValue: ControlProperty<String>
        let descriptionValue: ControlProperty<String?>
        let doneButtonTapped: ControlEvent<Void>
    }
    
    struct Output {
        let doneButtonEnabled: Observable<Bool>
        let showToastAlert: PublishRelay<ToastAlert.Toast>
        let isDismiss: PublishRelay<Void>
    }
    
    func transform(input: Input) -> Output {
        let showToastAlert = PublishRelay<ToastAlert.Toast>()
        let isDismiss = PublishRelay<Void>()
        
        // 완료 버튼 활성화
        let doneButtonEnabled = input.nameInputValue.map { $0.isEmpty == false }
        
        // 이미지 선택 확인
        let isImageSelected = input.selectedImage
            .map { $0 != nil }
        
        // 워크스페이스의 이름 길이 확인
        let isValidName = input.nameInputValue
            .map { 1...30 ~= $0.count }
        
        // 유효성 검사 결과 모음
        let validation = Observable.combineLatest(isImageSelected, isValidName)
        
        // name -> Data로 변환
        let nameData = input.nameInputValue
            .compactMap { name in
                return name.data(using: .utf8)
            }
        
        // description -> Data로 변환
        let descriptionData = input.descriptionValue
            .compactMap { description in
                let description = description ?? ""
                return description.data(using: .utf8)
            }
        
        // UIImage -> Data로 변환
        let imageData = input.selectedImage
            .compactMap { image in
                let resizedImage = image?.resize(targetSize: CGSize(width: 70, height: 70))
                let imageData = resizedImage?.jpegData(compressionQuality: 0.5)
                return imageData
            }
        
        let inputValues = Observable.combineLatest(nameData, descriptionData, imageData)
        
        let validInputValues = input.doneButtonTapped
            .withLatestFrom(validation) { _, validation in
                validation
            }.filter { imageValidation, nameValidation in
                guard nameValidation else {
                    showToastAlert.accept(.init(message: "워크스페이스 이름은 1~30자로 설정해주세요.", style: .caution))
                    return false
                }
                
                guard imageValidation else {
                    showToastAlert.accept(.init(message: "워크스페이스 이미지를 등록해주세요.", style: .caution))
                    return false
                }
                
                return imageValidation && nameValidation
            }
            .withLatestFrom(inputValues) { _, allInputValues in
                allInputValues
            }
                    
        validInputValues
            .debounce(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .flatMap { [unowned self] name, description, imageData in
                lilacWorkspaceService.create(name: name, description: description, image: imageData)
            }
            .subscribe { result in
                switch result {
                case .success(let workspace):
                    User.shared.add(for: workspace)
                    isDismiss.accept(())
                case .failure(_):
                    showToastAlert.accept(.init(message: "에러가 발생했어요. 잠시 후 다시 시도해주세요.", style: .caution))
                }                
            } onError: { _ in
                showToastAlert.accept(.init(message: "에러가 발생했어요. 잠시 후 다시 시도해주세요.", style: .caution))
            }
            .disposed(by: disposeBag)
            
        
        return Output(
            doneButtonEnabled: doneButtonEnabled,
            showToastAlert: showToastAlert,
            isDismiss: isDismiss
        )
    }
}
