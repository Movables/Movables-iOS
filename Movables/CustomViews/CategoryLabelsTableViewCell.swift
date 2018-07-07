//
//  CategoryLabelsTableViewCell.swift
//  Movables
//
//  Created by Eddie Chen on 6/14/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit

class CategoryLabelsTableViewCell: UITableViewCell {

    var categoryLabel: UILabel!
    var titleLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        
        categoryLabel = UILabel(frame: .zero)
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryLabel.numberOfLines = 1
        categoryLabel.textAlignment = .center
        categoryLabel.font = UIFont.systemFont(ofSize: 32)
        categoryLabel.text = ""
        contentView.addSubview(categoryLabel)
        
        titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        titleLabel.numberOfLines = 1
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            categoryLabel.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 14),
            categoryLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -14),
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: categoryLabel.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: categoryLabel.centerYAnchor),
        ])
    }
    
}
