//
//  ExpandableTextCollectionViewCell.swift
//  Movables
//
//  Created by Eddie Chen on 5/21/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit

class ExpandableTextCollectionViewCell: UICollectionViewCell {
    
    var parentView: UIView!
    var label: UILabel!
    var button: UIButton!
    var buttonTopConstraint: NSLayoutConstraint!
    var buttonBottomConstraint: NSLayoutConstraint!
    var buttonTrailingConstraint: NSLayoutConstraint!
    
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
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        parentView.addSubview(label)
        
        button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Read more".localized(key: "button.readMore"), for: .normal)
        button.setTitleColor(Theme().keyTint, for: .normal)
        button.setTitleColor(Theme().keyTint.withAlphaComponent(0.7), for: .highlighted)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        parentView.addSubview(button)
        
        let hLabelConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[label]-18-|", options: .directionLeadingToTrailing, metrics: nil, views: ["label": label])
        
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-6-[label]", options: .alignAllTrailing, metrics: nil, views: ["label": label, "button": button])
        
        buttonTrailingConstraint = NSLayoutConstraint(item: button, attribute: .trailing, relatedBy: .equal, toItem: label, attribute: .trailing, multiplier: 1, constant: 0)

        
        buttonBottomConstraint = NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal, toItem: parentView, attribute: .bottom, multiplier: 1, constant: -8)
        
        buttonTopConstraint = NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: label, attribute: .bottom, multiplier: 1, constant: 4)
        
        parentView.addConstraints(hLabelConstraints + vConstraints + [buttonBottomConstraint, buttonTopConstraint, buttonTrailingConstraint])
        
    }
}
