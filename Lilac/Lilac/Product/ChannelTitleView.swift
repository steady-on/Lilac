//
//  ChannelTitleView.swift
//  Lilac
//
//  Created by Roen White on 2/28/24.
//

import UIKit

final class ChannelTitleView: BaseView {
    
    private let stackContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        return label
    }()
    
    private let countOfMemberLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .Text.secondary
        return label
    }()

    override func configureHiararchy() {
        addSubview(stackContainer)
        
        let components = [titleLabel, countOfMemberLabel]
        components.forEach { component in
            stackContainer.addArrangedSubview(component)
        }
    }
    
    override func setConstraints() {
        stackContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension ChannelTitleView {
    func setChannel(for name: String, countOfMember: Int) {
        titleLabel.text = "#\(name)"
        countOfMemberLabel.text = "\(countOfMember)"
    }
}
