//
//  ActivityIndicatorCollectionViewCell.swift
//  Movables
//
//  Created by Eddie Chen on 5/30/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class ActivityIndicatorCollectionViewCell: UICollectionViewCell {
    
    var activityIndicatorView: NVActivityIndicatorView!
    var parentView: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        parentView = UIView(frame: .zero)
        parentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(parentView)
        
        let parentViewH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[parentView(screenWidth)]|", options: .directionLeadingToTrailing, metrics: ["screenWidth": UIScreen.main.bounds.width], views: ["parentView": parentView])
        
        let parentViewV = NSLayoutConstraint.constraints(withVisualFormat: "V:|[parentView(120)]|", options: .alignAllLeading, metrics: nil, views: ["parentView": parentView])
        
        addConstraints(parentViewH + parentViewV)
        
        activityIndicatorView = NVActivityIndicatorView(frame: .zero, type: .ballScale, color: Theme().textColor, padding: 0)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(activityIndicatorView)
        
        let activityViewH = NSLayoutConstraint.constraints(withVisualFormat: "H:[activityIndicatorView(50)]", options: .directionLeadingToTrailing, metrics: nil, views: ["activityIndicatorView": activityIndicatorView])
        
        let activityViewV = NSLayoutConstraint.constraints(withVisualFormat: "V:[activityIndicatorView(50)]", options: .alignAllCenterX, metrics: nil, views: ["activityIndicatorView": activityIndicatorView])
        
        let activityViewCenterX = NSLayoutConstraint(item: activityIndicatorView, attribute: .centerX, relatedBy: .equal, toItem: parentView, attribute: .centerX, multiplier: 1, constant: 0)
        
        let activityViewCenterY = NSLayoutConstraint(item: activityIndicatorView, attribute: .centerY, relatedBy: .equal, toItem: parentView, attribute: .centerY, multiplier: 1, constant: 0)

        parentView.addConstraints(activityViewH + activityViewV + [activityViewCenterX, activityViewCenterY])
    }
}
