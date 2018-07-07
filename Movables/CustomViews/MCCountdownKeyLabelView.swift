//
//  MCCountdownKeyLabelView.swift
//  Movables
//
//  Created by Eddie Chen on 6/6/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit
import CountdownLabel

class MCCountdownKeyLabelView: UIView {

    var keyLabel: UILabel!
    var valueLabel: CountdownLabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        keyLabel = UILabel(frame: .zero)
        keyLabel.translatesAutoresizingMaskIntoConstraints = false
        keyLabel.numberOfLines = 1
        keyLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        addSubview(keyLabel)
        
        valueLabel = CountdownLabel(frame: .zero)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.numberOfLines = 1
        valueLabel.animationType = .Evaporate
        valueLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        addSubview(valueLabel)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[keyLabel]|", options: .directionLeadingToTrailing, metrics: nil, views: ["keyLabel": keyLabel, "valueLabel": valueLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[keyLabel]-6-[valueLabel]|", options: .alignAllCenterX, metrics: nil, views: ["keyLabel": keyLabel, "valueLabel": valueLabel]))
        
        addConstraint(NSLayoutConstraint(item: keyLabel, attribute: .width, relatedBy: .equal, toItem: valueLabel
            , attribute: .width, multiplier: 1, constant: 0))
    }

}
