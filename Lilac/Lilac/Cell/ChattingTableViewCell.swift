//
//  ChattingTableViewCell.swift
//  Lilac
//
//  Created by Roen White on 2/28/24.
//

import UIKit

final class ChattingTableViewCell: BaseTableViewCell {
    
    static let identifier = "ChattingTableViewCell"
    
    var chatting: ChannelChatting! {
        didSet {
            configureComponents()
        }
    }
    
    private let backdropView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.directionalLayoutMargins = .init(top: 6, leading: 0, bottom: 6, trailing: 14)
        return view
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    private let stackContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    private let nicknameLabel = BasicLabel(style: .caption1)
    
    private let contentLabel = ChattingContentLabel()
    
    private let timeLabel: BasicLabel = {
        let label = BasicLabel(style: .caption2)
        label.textColor = .Text.secondary
        label.numberOfLines = 2
        return label
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func configureHiararchy() {
        backgroundColor = .clear
        
        addSubview(backdropView)
        
        let components = [profileImageView, stackContainer, timeLabel]
        components.forEach { component in
            backdropView.addSubview(component)
        }
        
        let stackComponents = [nicknameLabel, contentLabel]
        stackComponents.forEach { component in
            stackContainer.addArrangedSubview(component)
        }
    }
    
    override func setConstraints() {
        backdropView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        profileImageView.snp.makeConstraints { make in
            make.size.equalTo(34)
            make.top.leading.equalTo(backdropView.layoutMarginsGuide)
        }
        
        stackContainer.snp.makeConstraints { make in
            make.top.equalTo(backdropView.layoutMarginsGuide)
            make.leading.equalTo(profileImageView.snp.trailing).offset(8)
            make.bottom.equalTo(backdropView.layoutMarginsGuide)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.leading.equalTo(stackContainer.snp.trailing).offset(8)
            make.bottom.equalTo(backdropView.layoutMarginsGuide)
        }
    }
}

extension ChattingTableViewCell {
    private func configureComponents() {
        setProfileImage(to: chatting.sender.profileImage)
        nicknameLabel.text = chatting.sender.nickname
        
        if chatting.content == nil {
            contentLabel.isHidden = true
        }
        
        contentLabel.text = chatting.content
        
        setTimeLabel(for: chatting.createdAt)
    }
    
    private func setProfileImage(to path: String?) {
        guard let path else {
            let defaultImages: [UIImage] = [.Profile.noPhotoA, .Profile.noPhotoB, .Profile.noPhotoC]
            profileImageView.image = defaultImages.randomElement()!
            return
        }
        
        let imageURL = URL(string: BaseURL.v1.server + path)
        profileImageView.kf.setImage(with: imageURL)
    }
    
    private func setTimeLabel(for createdAt: Date) {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: createdAt)
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: Date.now)
        
        guard let year = dateComponents.year,
              let month = dateComponents.month,
              let day = dateComponents.day,
              let hour = dateComponents.hour,
              let minute = dateComponents.minute else {
            return
        }
        
        let mark = hour < 12 ? "오전" : "오후"
        
        let hourString =
        if hour < 10 { "0\(hour)" }
        else if hour > 12 { "\(hour - 12)" }
        else { "\(hour)"}
        
        let timeString = "\(mark) \(hourString):\(minute)"
        
        let dateString = if year != todayComponents.year {
            "\(year)/\(month)/\(day)\n"
        } else if (month == todayComponents.month && day == todayComponents.day) == false {
            "\(month)/\(day)\n"
        } else {
            ""
        }
        
        timeLabel.text = dateString + timeString
    }
}
