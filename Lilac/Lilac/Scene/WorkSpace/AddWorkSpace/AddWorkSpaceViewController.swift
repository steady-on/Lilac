//
//  AddWorkSpaceViewController.swift
//  Lilac
//
//  Created by Roen White on 2/19/24.
//

import UIKit
import RxSwift
import RxCocoa
import PhotosUI

final class AddWorkSpaceViewController: BaseViewController {
    
    private let viewModel: AddWorkSpaceViewModel
    
    init(viewModel: AddWorkSpaceViewModel) {
        self.viewModel = viewModel
        
        super.init()
    }
    
    deinit {
        print("deinit AddWorkSpaceViewController")
    }
    
    private let disposeBag = DisposeBag()
    
    private let selectedImage = BehaviorRelay<UIImage?>(value: nil)
    
    private let phPickerViewContoller: PHPickerViewController = {
        var configuration = PHPickerConfiguration()
        configuration.filter = .any(of: [.livePhotos, .images])
        
        let picker = PHPickerViewController(configuration: configuration)
        return picker
    }()
    
    private let selectImageButton = SelectImageButton(baseImage: nil)
    
    private let nameTextField: LabeledTextField = {
        let textField = LabeledTextField(title: "워크스페이스 이름")
        textField.placeholder = "워크스페이스 이름을 입력하세요 (필수)"
        return textField
    }()
    
    private let descriptionTextField: LabeledTextField = {
        let textField = LabeledTextField(title: "워크스페이스 설명")
        textField.placeholder = "워크스페이스를 설명하세요 (옵션)"
        return textField
    }()
    
    private let doneButton = FilledColorButton(title: "완료")
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configureHiararchy() {
        super.configureHiararchy()
        
        phPickerViewContoller.delegate = self
        modalPresentationStyle = .formSheet
        
        let components = [selectImageButton, nameTextField, descriptionTextField, doneButton]
        components.forEach { component in
            view.addSubview(component)
        }
    }
    
    override func setConstraints() {
        selectImageButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.centerX.equalToSuperview()
        }
        
        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(selectImageButton.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(24)
        }
        
        descriptionTextField.snp.makeConstraints { make in
            make.top.equalTo(nameTextField.snp.bottom).offset(24)
            make.horizontalEdges.equalToSuperview().inset(24)
        }
        
        doneButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(24)
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-12)
        }
    }
    
    override func configureNavigationBar() {
        title = "워크스페이스 생성"
        
        let closeButton = UIBarButtonItem(image: .Icon.close, style: .plain, target: self, action: #selector(closeButtonTapped))
        closeButton.tintColor = .black
        
        navigationItem.leftBarButtonItem = closeButton
        
        let barAppearance = UINavigationBarAppearance()
        barAppearance.backgroundColor = .Background.secondary
        navigationItem.scrollEdgeAppearance = barAppearance
    }
    
    override func bind() {
        selectImageButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.present(self.phPickerViewContoller, animated: true)
            }
            .disposed(by: disposeBag)
        
        selectedImage.asDriver()
            .drive(with: self) { owner, image in
                owner.selectImageButton.changeImage(for: image)
            }
            .disposed(by: disposeBag)
        
        let input = AddWorkSpaceViewModel.Input(
            selectedImage: selectedImage,
            nameInputValue: nameTextField.rx.text.orEmpty,
            descriptionValue: descriptionTextField.rx.text,
            doneButtonTapped: doneButton.rx.tap
        )
        
        let output = viewModel.transform(input: input)
        
        output.doneButtonEnabled
            .bind(to: doneButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.showToastAlert
            .bind(with: self) { owner, toast in
                owner.showToast(toast, target: self)
            }
            .disposed(by: disposeBag)
    }
}

extension AddWorkSpaceViewController {
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
}

extension AddWorkSpaceViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let itemProvider = results.first?.itemProvider,
        itemProvider.canLoadObject(ofClass: UIImage.self) else {
            return
        }
        
        itemProvider.loadObject(ofClass: UIImage.self) { [unowned self] imageData, error in
            guard error == nil, let image = imageData as? UIImage else { return }
            
            selectedImage.accept(image)
        }
    }
}
