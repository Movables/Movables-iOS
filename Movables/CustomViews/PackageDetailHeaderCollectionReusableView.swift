//
//  PackageDetailHeaderCollectionReusableView.swift
//  Movables
//
//  Created by Eddie Chen on 5/20/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit
import MarqueeLabel

class PackageDetailHeaderCollectionReusableView: UICollectionReusableView {
    
    var imageView: UIImageView!
    var titleLabel: MarqueeLabel!
    var tagPill: MCPill!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .black
        if UIDevice.isIphoneX {
            layer.cornerRadius = 18
        } else {
            layer.cornerRadius = 0
        }
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        clipsToBounds = true
        
        imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
        imageView.contentMode = .scaleAspectFill
        imageView.alpha = 0.7
        addSubview(imageView)
        
        titleLabel = MarqueeLabel(frame: .zero, rate: 60, fadeLength: 80)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.trailingBuffer = 42
        titleLabel.leadingBuffer = 18
        titleLabel.animationDelay = 2
        titleLabel.numberOfLines = 1
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.text = "Headline"
        addSubview(titleLabel)
        
        tagPill = MCPill(frame: .zero, character: "#", image: nil, body: "tag", color: Theme().keyTint)
        tagPill.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tagPill)
        
        
        let viewsDictionary: [String: UIView] = ["imageView": imageView, "titleLabel": titleLabel, "tagPill": tagPill]
        
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]|", options: .directionLeadingToTrailing, metrics: nil, views: viewsDictionary)
        
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView]|", options: .alignAllCenterX, metrics: nil, views: viewsDictionary)
        
        addConstraints(hConstraints + vConstraints)
        
        let hLabelsConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-14-[tagPill]->=18-|", options: .directionLeadingToTrailing, metrics: nil, views: ["tagPill": tagPill])
        
        let hTitleLabelsConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[titleLabel]|", options: .directionLeadingToTrailing, metrics: nil, views: ["titleLabel": titleLabel])
        
        NSLayoutConstraint.activate([
            tagPill.heightAnchor.constraint(equalToConstant: 28),
            titleLabel.topAnchor.constraint(equalTo: tagPill.bottomAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -24),
        ])
        
        
        for constraint in hLabelsConstraints {
            constraint.priority = .defaultHigh
        }
        
        addConstraints(hLabelsConstraints + hTitleLabelsConstraints)
    }
}
