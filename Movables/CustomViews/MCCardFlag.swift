//
//  MCCardFlag.swift
//  Movables
//
//  Created by Eddie Chen on 5/15/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit

class MCCardFlag: UIView {
    
    var text:String!
    
    private var baseView: UIView!
    private var contentView: UIView!
    
    private var textLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, text: String, attention: Attention?) {
        super.init(frame: frame)
        self.text = text
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
        contentView.layer.borderWidth = 3
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
        baseView.addSubview(contentView)
        baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[contentView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["contentView":contentView]))
        baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[contentView]|", options: .alignAllCenterY, metrics: nil, views: ["contentView":contentView]))
        
        
        textLabel = UILabel(frame: .zero)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.numberOfLines = 1
        textLabel.font = UIFont.systemFont(ofSize: 17).with(traits: [.traitBold, .traitItalic])
        
        textLabel.text = self.text
        textLabel.textColor = .black
        contentView.addSubview(textLabel)
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[textLabel]-12-|", options: .directionLeadingToTrailing, metrics: nil, views: ["textLabel": textLabel]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|->=0-[textLabel]->=0-|", options: .alignAllCenterX, metrics: nil, views: ["textLabel": textLabel]))
        
        contentView.addConstraint(NSLayoutConstraint(item: textLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0))
    }    
}
