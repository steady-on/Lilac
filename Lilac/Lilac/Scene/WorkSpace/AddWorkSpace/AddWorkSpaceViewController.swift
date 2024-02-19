//
//  AddWorkSpaceViewController.swift
//  Lilac
//
//  Created by Roen White on 2/19/24.
//

import UIKit

final class AddWorkSpaceViewController: BaseViewController {
    
    deinit {
        print("deinit AddWorkSpaceViewController")
    }
    
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
}

extension AddWorkSpaceViewController {
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
}
