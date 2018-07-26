//
//  OrganizePackageFollowingTableViewCell.swift
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

class OrganizePackageMovedTableViewCell: UITableViewCell {

    var supplementLabelContainerView: UIView!
    var supplementLabel: UILabel!
    var packageCountLabel: UILabel!
    var topicLabel: UILabel!
    var separatorView: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .gray
        
        supplementLabelContainerView = UIView(frame: .zero)
        supplementLabelContainerView.translatesAutoresizingMaskIntoConstraints = false
        supplementLabelContainerView.layer.cornerRadius = 4
        supplementLabelContainerView.clipsToBounds = true
        supplementLabelContainerView.backgroundColor = Theme().mapStampTint
        contentView.addSubview(supplementLabelContainerView)
        
        supplementLabel = UILabel(frame: .zero)
        supplementLabel.translatesAutoresizingMaskIntoConstraints = false
        supplementLabel.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        supplementLabel.textColor = .white
        supplementLabel.textAlignment = .center
        supplementLabel.numberOfLines = 1
        supplementLabelContainerView.addSubview(supplementLabel)
        
        packageCountLabel = UILabel(frame: .zero)
        packageCountLabel.translatesAutoresizingMaskIntoConstraints = false
        packageCountLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        packageCountLabel.textColor = Theme().grayTextColorHighlight
        packageCountLabel.numberOfLines = 1
        packageCountLabel.text = "time ago"
        contentView.addSubview(packageCountLabel)
        
        topicLabel = UILabel(frame: .zero)
        topicLabel.translatesAutoresizingMaskIntoConstraints = false
        topicLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        topicLabel.textColor = Theme().textColor
        topicLabel.numberOfLines = 0
        topicLabel.text = "event label"
        contentView.addSubview(topicLabel)
        
        separatorView = UIView(frame: .zero)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = Theme().borderColor
        contentView.addSubview(separatorView)
        
        NSLayoutConstraint.activate([
            supplementLabelContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            supplementLabelContainerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            supplementLabel.leadingAnchor.constraint(equalTo: supplementLabelContainerView.leadingAnchor, constant: 6),
            supplementLabel.trailingAnchor.constraint(equalTo: supplementLabelContainerView.trailingAnchor, constant: -6),
            supplementLabel.topAnchor.constraint(equalTo: supplementLabelContainerView.topAnchor, constant: 4),
            supplementLabel.bottomAnchor.constraint(equalTo: supplementLabelContainerView.bottomAnchor, constant: -4),
            topicLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            topicLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            topicLabel.trailingAnchor.constraint(lessThanOrEqualTo: supplementLabelContainerView.leadingAnchor, constant: -18),
            packageCountLabel.bottomAnchor.constraint(lessThanOrEqualTo: separatorView.bottomAnchor, constant: -20),
            packageCountLabel.leadingAnchor.constraint(equalTo: topicLabel.leadingAnchor),
            packageCountLabel.topAnchor.constraint(equalTo: topicLabel.bottomAnchor, constant: 6),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        supplementLabelContainerView.backgroundColor = Theme().mapStampTint
        // Configure the view for the selected state
    }
}
