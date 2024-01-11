//
//  PopUpAlertViewController.swift
//  Lilac
//
//  Created by Roen White on 1/9/24.
//

import UIKit

final class PopUpAlertViewController: BaseViewController {
    
    private var titleText: String
    private var messageText: String
    
    init(titleText: String, messageText: String) {
        self.titleText = titleText
        self.messageText = messageText
        
        super.init()
        modalPresentationStyle = .overFullScreen
    }
    
//    deinit {
//        print("deinit PopUpAlertViewController")
//    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .Background.secondary
        view.layer.cornerRadius = 16
        view.directionalLayoutMargins = .init(top: 16, leading: 16, bottom: 16, trailing: 16)
        view.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        return view
    }()
    
    private let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        return stack
    }()

    private let messageStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()

    private let buttonStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()
    
    private lazy var titleLabel: BasicLabel = {
        let label = BasicLabel(style: .title2)
        label.text = self.titleText
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .Text.primary
        return label
    }()
    
    private lazy var messageLabel: BasicLabel = {
        let label = BasicLabel(style: .body)
        label.text = self.messageText
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .Text.secondary
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseOut) { [weak self] in
            self?.containerView.transform = .identity
            self?.containerView.isHidden = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseIn) { [weak self] in
            self?.containerView.transform = .identity
            self?.containerView.isHidden = true
        }
    }
    
    override func configureHiararchy() {
        view.backgroundColor = .View.alpha
        
        view.addSubview(containerView)
        containerView.addSubview(containerStackView)
        
        let components = [messageStackView, buttonStackView]
        components.forEach { component in
            containerStackView.addArrangedSubview(component)
        }
        
        let messageComponents = [titleLabel, messageLabel]
        messageComponents.forEach { component in
            messageStackView.addArrangedSubview(component)
        }
    }
    
    override func setConstraints() {
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(24)
        }
        
        containerStackView.snp.makeConstraints { make in
            make.edges.equalTo(containerView.layoutMarginsGuide)
        }
    }
    
    func addAction(_ action: AlertAction) {
        let buttonColor: UIColor = switch action.style {
        case .default: .accent
        case .cancel: .Brand.inactive
        case .destructive: .Brand.error
        }
        
        let button = UIButton()
        
        var config = UIButton.Configuration.filled()
        config.background.cornerRadius = 8
        button.configuration = config
        
        button.setTitle(action.title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .brandedFont(.title2)
        button.tintColor = buttonColor
        
        if action.style == .cancel {
            buttonStackView.insertArrangedSubview(button, at: 0)
        } else {
            buttonStackView.addArrangedSubview(button)
        }
        
        
        guard let handler = action.handler else {
            button.addAction(UIAction { [weak self] _ in self?.dismiss(animated: false) }, for: .touchUpInside)
            return
        }
        
        button.addAction(handler, for: .touchUpInside)
    }
}
