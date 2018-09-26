//
//  OrganizeDetailTableHeaderView.swift
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
import MarqueeLabel

class OrganizeDetailTableHeaderViewCell: UITableViewCell {

    var topicLabel: UILabel!
    var descriptionLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        backgroundColor = Theme().borderColor
        
        if UIDevice.isIphoneX {
            layer.cornerRadius = 18
        } else {
            layer.cornerRadius = 0
        }
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        clipsToBounds = true
        
        topicLabel = UILabel(frame: .zero)
        topicLabel.translatesAutoresizingMaskIntoConstraints = false
        topicLabel.numberOfLines = 0
        topicLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        topicLabel.textColor = Theme().textColor
        topicLabel.text = "#Tag"
        contentView.addSubview(topicLabel)
        
        descriptionLabel = UILabel(frame: .zero)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        descriptionLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        descriptionLabel.numberOfLines = 0
        contentView.addSubview(descriptionLabel)
        
        
        let hTagLabelConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[topicLabel]-18-|", options: .directionLeadingToTrailing, metrics: nil, views: ["topicLabel": topicLabel])
        
        NSLayoutConstraint.activate([
            topicLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            topicLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            topicLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 50 + 50 + UIApplication.shared.keyWindow!.safeAreaInsets.top),
            descriptionLabel.topAnchor.constraint(equalTo: topicLabel.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 18),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -36),
        ])
        
        addConstraints(hTagLabelConstraints)
    }
}
