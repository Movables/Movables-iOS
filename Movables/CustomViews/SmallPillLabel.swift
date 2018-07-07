//
//  SmallPillLabel.swift
//  Movables
//
//  Created by Eddie Chen on 6/19/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit

class SmallPillLabel: UIView {

    var containerView: UIView!
    var label: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        containerView = UIView(frame: .zero)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.cornerRadius = 12
        containerView.clipsToBounds = true
        addSubview(containerView)
        
        label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.numberOfLines = 1
        addSubview(label)
     
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: self.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 24),
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
}
