//
//  MCCard.swift
//  Movables
//
//  Created by Eddie Chen on 5/15/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit

class MCCard: UIView {

    var baseView: UIView!
    var contentView: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    func commonInit() {
        clipsToBounds = false
        
        baseView = UIView(frame: .zero)
        baseView.translatesAutoresizingMaskIntoConstraints = false
        baseView.layer.shadowColor = UIColor.black.cgColor
        baseView.layer.shadowOpacity = 0.15
        baseView.layer.shadowRadius = 8
        baseView.layer.shadowOffset = CGSize(width: 0, height: 0)
        addSubview(baseView)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[baseView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["baseView":baseView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[baseView]|", options: .alignAllCenterY, metrics: nil, views: ["baseView":baseView]))
        
        contentView = UIView(frame: .zero)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 8
        contentView.layer.borderColor = UIColor.gray.cgColor.copy(alpha: 0.3)
        contentView.layer.borderWidth = 0.5
        contentView.clipsToBounds = true
        baseView.addSubview(contentView)
    baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[contentView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["contentView":contentView]))
    baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[contentView]|", options: .alignAllCenterY, metrics: nil, views: ["contentView":contentView]))
    }

}
