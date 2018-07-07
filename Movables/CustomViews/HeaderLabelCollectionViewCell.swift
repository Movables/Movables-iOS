//
//  HeaderLabelCollectionViewCell.swift
//  Movables
//
//  Created by Eddie Chen on 5/21/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit

class HeaderLabelCollectionViewCell: UICollectionViewCell {
    
    var parentView: UIView!
    var label: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        parentView = UIView(frame: .zero)
        parentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(parentView)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[parentView]|", options: .alignAllLeading, metrics: nil, views: ["parentView": parentView]) + NSLayoutConstraint.constraints(withVisualFormat: "H:|[parentView(screenWidth)]|", options: .directionLeadingToTrailing, metrics: ["screenWidth": UIScreen.main.bounds.width], views: ["parentView": parentView]))

        
        label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.numberOfLines = 1
        parentView.addSubview(label)
        
        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[label]-18-|", options: .directionLeadingToTrailing, metrics: nil, views: ["label": label]))
        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-18-[label]|", options: .alignAllLeading, metrics: nil, views: ["label": label]))

    }
}
