//
//  BaseViewController.swift
//  Lilac
//
//  Created by Roen White on 1/7/24.
//

import UIKit
import SnapKit

class BaseViewController: UIViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHiararchy()
        setConstraints()
        bind()
        configureNavigationBar()
    }

    func configureHiararchy() {
        view.backgroundColor = .Background.primary
    }
    
    func setConstraints() {}
    
    func bind() {}
    
    func configureNavigationBar() {}
}

extension BaseViewController {
    func showToast(message: String, style: ToastMessage.ToastStyle, bottonInset: ConstraintInsetTarget) {
        let toastMessage = ToastMessage(message: message, style: style)
        
        view.addSubview(toastMessage)
        
        toastMessage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(bottonInset)
        }
        
        UIView.animate(withDuration: 0.5, delay: 2, options: .curveLinear) {
            toastMessage.alpha = 0
        } completion: { _ in
            toastMessage.removeFromSuperview()
        }
    }
    
    func showPopUpAlert(title: String, message: String, firstAction: AlertAction, secondAction: AlertAction? = nil) {
        let alert = PopUpAlertViewController(titleText: title, messageText: message)
        alert.addAction(firstAction)
        
        if let secondAction {
            alert.addAction(secondAction)            
        }
        
        present(alert, animated: false)
    }
}
