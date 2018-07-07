//
//  SectionHeaderTableViewHeaderView.swift
//  Movables
//
//  Created by Eddie Chen on 7/3/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit

class SectionHeaderTableViewHeaderView: UITableViewHeaderFooterView {

    var label: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .white
        contentView.backgroundColor = .white
        
        label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.numberOfLines = 1
        contentView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])
    }
    
    
    
}
