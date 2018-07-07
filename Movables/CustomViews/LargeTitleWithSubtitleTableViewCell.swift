//
//  LargeTitleWithSubtitleTableViewCell.swift
//  Movables
//
//  Created by Eddie Chen on 6/13/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit

class LargeTitleWithSubtitleTableViewCell: UITableViewCell {

    var largeTitleLabel: UILabel!
    var subtitleLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        
        largeTitleLabel = UILabel(frame: .zero)
        largeTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        largeTitleLabel.numberOfLines = 0
        largeTitleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        contentView.addSubview(largeTitleLabel)
        
        subtitleLabel = UILabel(frame: .zero)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.numberOfLines = 0
        subtitleLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        contentView.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            largeTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            largeTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            largeTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            subtitleLabel.topAnchor.constraint(equalTo: largeTitleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: largeTitleLabel.leadingAnchor, constant: 0),
            subtitleLabel.trailingAnchor.constraint(equalTo: largeTitleLabel.trailingAnchor, constant: 0),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),
        ])
    }
}
