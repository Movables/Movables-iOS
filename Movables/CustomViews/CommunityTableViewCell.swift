//
//  CommunityTableViewCell.swift
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

class CommunityTableViewCell: UITableViewCell {

    var communityTypeImageView: UIImageView!
    var supplementLabelContainerView: UIView!
    var supplementLabel: UILabel!
    var descriptionLabel: UILabel!
    var nameLabel: UILabel!
    var separatorView: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        
        selectionStyle = .gray
        
        communityTypeImageView = UIImageView(frame: .zero)
        communityTypeImageView.translatesAutoresizingMaskIntoConstraints = false
        communityTypeImageView.contentMode = .scaleAspectFill
        communityTypeImageView.backgroundColor = .white
        communityTypeImageView.layer.borderColor = Theme().textColor.cgColor
        communityTypeImageView.layer.borderWidth = 1
        communityTypeImageView.layer.cornerRadius = 20
        communityTypeImageView.clipsToBounds = true
        communityTypeImageView.tintColor = Theme().textColor
        contentView.addSubview(communityTypeImageView)
        
        supplementLabelContainerView = UIView(frame: .zero)
        supplementLabelContainerView.translatesAutoresizingMaskIntoConstraints = false
        supplementLabelContainerView.layer.cornerRadius = 4
        supplementLabelContainerView.clipsToBounds = true
        contentView.addSubview(supplementLabelContainerView)
        
        supplementLabel = UILabel(frame: .zero)
        supplementLabel.translatesAutoresizingMaskIntoConstraints = false
        supplementLabel.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        supplementLabel.textColor = .white
        supplementLabel.textAlignment = .center
        supplementLabel.numberOfLines = 1
        supplementLabelContainerView.addSubview(supplementLabel)
        
        descriptionLabel = UILabel(frame: .zero)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        descriptionLabel.textColor = Theme().grayTextColorHighlight
        descriptionLabel.numberOfLines = 1
        descriptionLabel.text = "time ago"
        contentView.addSubview(descriptionLabel)
        
        nameLabel = UILabel(frame: .zero)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        nameLabel.textColor = Theme().textColor
        nameLabel.numberOfLines = 0
        nameLabel.text = "event label"
        contentView.addSubview(nameLabel)
        
        separatorView = UIView(frame: .zero)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = Theme().borderColor
        contentView.addSubview(separatorView)
        
        NSLayoutConstraint.activate([
            communityTypeImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            communityTypeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            communityTypeImageView.heightAnchor.constraint(equalToConstant: 40),
            communityTypeImageView.widthAnchor.constraint(equalToConstant: 40),
            supplementLabelContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            supplementLabelContainerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            supplementLabel.leadingAnchor.constraint(equalTo: supplementLabelContainerView.leadingAnchor, constant: 6),
            supplementLabel.trailingAnchor.constraint(equalTo: supplementLabelContainerView.trailingAnchor, constant: -6),
            supplementLabel.topAnchor.constraint(equalTo: supplementLabelContainerView.topAnchor, constant: 4),
            supplementLabel.bottomAnchor.constraint(equalTo: supplementLabelContainerView.bottomAnchor, constant: -4),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 23),
            nameLabel.leadingAnchor.constraint(equalTo: communityTypeImageView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: supplementLabelContainerView.leadingAnchor, constant: -18),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: separatorView.bottomAnchor, constant: -20),
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 3),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
