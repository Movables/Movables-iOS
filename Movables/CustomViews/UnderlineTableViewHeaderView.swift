//
//  UnderlineTableViewHeaderView.swift
//  Movables
//
//  Created by Eddie Chen on 7/2/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit

class UnderlineTableViewHeaderView: UITableViewHeaderFooterView {

    var titleLabel: UILabel!
    var underlineView: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .white
        
        titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        titleLabel.numberOfLines = 1
        titleLabel.textColor = Theme().grayTextColor
        contentView.addSubview(titleLabel)
        
        underlineView = UIView(frame: .zero)
        underlineView.translatesAutoresizingMaskIntoConstraints = false
        underlineView.backgroundColor = Theme().grayTextColorHighlight
        contentView.addSubview(underlineView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            underlineView.heightAnchor.constraint(equalToConstant: 1),
            underlineView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            underlineView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            underlineView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            underlineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
}
