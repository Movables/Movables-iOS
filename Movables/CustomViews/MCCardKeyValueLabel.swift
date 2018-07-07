//
//  MCCardKeyValueLabel.swift
//  Movables
//
//  Created by Eddie Chen on 5/16/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit

class MCCardKeyValueLabel: UIView {

    var keyLabel: UILabel!
    var valueLabel: UILabel!
    var spacingConstraint: NSLayoutConstraint!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        keyLabel = UILabel(frame: .zero)
        keyLabel.translatesAutoresizingMaskIntoConstraints = false
        keyLabel.numberOfLines = 1
        keyLabel.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        addSubview(keyLabel)
        
        valueLabel = UILabel(frame: .zero)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.numberOfLines = 1
        valueLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        addSubview(valueLabel)
        
    addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[keyLabel]|", options: .directionLeadingToTrailing, metrics: nil, views: ["keyLabel": keyLabel, "valueLabel": valueLabel]))
    addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[keyLabel]->=2-[valueLabel]|", options: .alignAllLeading, metrics: nil, views: ["keyLabel": keyLabel, "valueLabel": valueLabel]))
        
        addConstraint(NSLayoutConstraint(item: keyLabel, attribute: .width, relatedBy: .equal, toItem: valueLabel
            , attribute: .width, multiplier: 1, constant: 0))
        
        spacingConstraint = valueLabel.topAnchor.constraint(equalTo: keyLabel.bottomAnchor, constant: 2)
        addConstraint(spacingConstraint)
    }
}
