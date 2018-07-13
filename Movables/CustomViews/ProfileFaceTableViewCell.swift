//
//  ProfileFaceTableViewCell.swift
//  Movables
//
//  MIT License
//
//  Copyright (c) 2018 Eddie Chen
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit

class ProfileFaceTableViewCell: UITableViewCell {

    var profilePicImageView: UIImageView!
    var nameLabel: UILabel!
    var accessoryButton: UIButton!
    var secondaryButton: UIButton!
    var separatorView: UIView!
    var balanceContainerView: UIView!
    var balanceLabel: UILabel!
    var journeyLabel: UILabel!
    var interestsLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
         super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = .white
        
        profilePicImageView = UIImageView(frame: .zero)
        profilePicImageView.translatesAutoresizingMaskIntoConstraints = false
        profilePicImageView.layer.cornerRadius = 40
        profilePicImageView.contentMode = .scaleAspectFill
        profilePicImageView.backgroundColor = Theme().backgroundShade
        profilePicImageView.clipsToBounds = true
        contentView.addSubview(profilePicImageView)
        
        nameLabel = UILabel(frame: .zero)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        nameLabel.numberOfLines = 1
        nameLabel.textAlignment = .center
        nameLabel.textColor = Theme().textColor
        contentView.addSubview(nameLabel)
        
        accessoryButton = UIButton(frame: .zero)
        accessoryButton.translatesAutoresizingMaskIntoConstraints = false
        accessoryButton.tintColor = Theme().grayTextColor
        contentView.addSubview(accessoryButton)
        
        secondaryButton = UIButton(frame: .zero)
        secondaryButton.translatesAutoresizingMaskIntoConstraints = false
        secondaryButton.tintColor = Theme().grayTextColor
        contentView.addSubview(secondaryButton)
        
        balanceContainerView = UIView(frame: .zero)
        balanceContainerView.translatesAutoresizingMaskIntoConstraints = false
        balanceContainerView.backgroundColor = Theme().grayTextColor
        balanceContainerView.layer.cornerRadius = 4
        balanceContainerView.clipsToBounds = true
        contentView.addSubview(balanceContainerView)
        
        balanceLabel = UILabel(frame: .zero)
        balanceLabel.translatesAutoresizingMaskIntoConstraints = false
        balanceLabel.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        balanceLabel.textColor = .white
        balanceLabel.textAlignment = .center
        balanceLabel.numberOfLines = 1
        balanceContainerView.addSubview(balanceLabel)
        
        journeyLabel = UILabel(frame: .zero)
        journeyLabel.translatesAutoresizingMaskIntoConstraints = false
        journeyLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        journeyLabel.textColor = Theme().grayTextColor
        journeyLabel.textAlignment = .center
        journeyLabel.numberOfLines = 0
        contentView.addSubview(journeyLabel)
        
        interestsLabel = UILabel(frame: .zero)
        interestsLabel.translatesAutoresizingMaskIntoConstraints = false
        interestsLabel.font = UIFont.systemFont(ofSize: 24, weight: .regular)
        interestsLabel.textColor = Theme().grayTextColor
        interestsLabel.textAlignment = .center
        interestsLabel.numberOfLines = 1
        contentView.addSubview(interestsLabel)
        
        separatorView = UIView(frame: .zero)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = Theme().borderColor
        contentView.addSubview(separatorView)
        
        NSLayoutConstraint.activate([
            profilePicImageView.heightAnchor.constraint(equalToConstant: 80),
            profilePicImageView.widthAnchor.constraint(equalToConstant: 80),
            profilePicImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: UIApplication.shared.keyWindow!.safeAreaInsets.top == 0 ? 44 : UIApplication.shared.keyWindow!.safeAreaInsets.top),
            profilePicImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            balanceContainerView.centerXAnchor.constraint(equalTo: profilePicImageView.centerXAnchor),
            balanceContainerView.centerYAnchor.constraint(equalTo: profilePicImageView.bottomAnchor),
            balanceLabel.leadingAnchor.constraint(equalTo: balanceContainerView.leadingAnchor, constant: 6),
            balanceLabel.trailingAnchor.constraint(equalTo: balanceContainerView.trailingAnchor, constant: -4),
            balanceLabel.topAnchor.constraint(equalTo: balanceContainerView.topAnchor, constant: 6),
            balanceLabel.bottomAnchor.constraint(equalTo: balanceContainerView.bottomAnchor, constant: -4),
            accessoryButton.heightAnchor.constraint(equalToConstant: 32),
            accessoryButton.widthAnchor.constraint(equalToConstant: 32),
            accessoryButton.centerYAnchor.constraint(equalTo: profilePicImageView.centerYAnchor),
            accessoryButton.centerXAnchor.constraint(equalTo: contentView.leadingAnchor, constant: UIScreen.main.bounds.width / 4 - 20),
            secondaryButton.heightAnchor.constraint(equalToConstant: 32),
            secondaryButton.widthAnchor.constraint(equalToConstant: 32),
            secondaryButton.centerYAnchor.constraint(equalTo: profilePicImageView.centerYAnchor),
            secondaryButton.centerXAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -(UIScreen.main.bounds.width / 4 - 20)),

            nameLabel.topAnchor.constraint(equalTo: balanceContainerView.bottomAnchor, constant: 18),
            nameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            journeyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            journeyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            journeyLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            interestsLabel.topAnchor.constraint(equalTo: journeyLabel.bottomAnchor, constant: 18),
            interestsLabel.leadingAnchor.constraint(equalTo: journeyLabel.leadingAnchor),
            interestsLabel.trailingAnchor.constraint(equalTo: journeyLabel.trailingAnchor),
            interestsLabel.bottomAnchor.constraint(equalTo: separatorView.topAnchor, constant: -40),
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
        ])
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
