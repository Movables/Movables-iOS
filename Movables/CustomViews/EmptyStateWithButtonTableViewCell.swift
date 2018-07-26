//
//  EmptyStateWithButtonTableViewCell.swift
//  Movables
//
//  Created by Eddie Chen on 7/26/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit

class EmptyStateWithButtonTableViewCell: UITableViewCell {

    var emptyStateView: EmptyStateView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        emptyStateView = EmptyStateView(frame: .zero)
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emptyStateView)
        
        NSLayoutConstraint.activate([
            emptyStateView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            emptyStateView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            emptyStateView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            emptyStateView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
        ])
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
