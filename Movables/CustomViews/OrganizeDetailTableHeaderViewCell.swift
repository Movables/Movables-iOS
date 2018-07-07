//
//  OrganizeDetailTableHeaderView.swift
//  Movables
//
//  Created by Eddie Chen on 7/2/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit
import MarqueeLabel

class OrganizeDetailTableHeaderViewCell: UITableViewCell {

    var tagLabel: UILabel!
    var descriptionLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
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
        
        tagLabel = UILabel(frame: .zero)
        tagLabel.translatesAutoresizingMaskIntoConstraints = false
        tagLabel.numberOfLines = 0
        tagLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        tagLabel.textColor = Theme().textColor
        tagLabel.text = "#Tag"
        contentView.addSubview(tagLabel)
        
        descriptionLabel = UILabel(frame: .zero)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        descriptionLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        descriptionLabel.numberOfLines = 0
        contentView.addSubview(descriptionLabel)
        
        
        let hTagLabelConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[tagLabel]-18-|", options: .directionLeadingToTrailing, metrics: nil, views: ["tagLabel": tagLabel])
        
        NSLayoutConstraint.activate([
            tagLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            tagLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            tagLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 50 + 50 + UIApplication.shared.keyWindow!.safeAreaInsets.top),
            descriptionLabel.topAnchor.constraint(equalTo: tagLabel.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 18),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -36),
        ])
        
        addConstraints(hTagLabelConstraints)
    }
}
