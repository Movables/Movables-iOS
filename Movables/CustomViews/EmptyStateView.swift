//
//  EmptyStateView.swift
//  Movables
//
//  Created by Eddie Chen on 5/30/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit

class EmptyStateView: UIView {

    var parentView: UIView!
    var titleLabel: UILabel!
    var subtitleLabel: UILabel!
    var actionButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 26, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.text = "👀"
        addSubview(titleLabel)
        
        subtitleLabel = UILabel(frame: .zero)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        subtitleLabel.textAlignment = .center
        subtitleLabel.text = String(NSLocalizedString("copy.nothingToSee", comment: "empty state generic title"))
        subtitleLabel.textColor = Theme().grayTextColor
        addSubview(subtitleLabel)
        
        actionButton = UIButton(frame: .zero)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.setTitleColor(UIColor.white.withAlphaComponent(0.85), for: .highlighted)
        actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        actionButton.layer.cornerRadius = 13
        actionButton.clipsToBounds = true
        actionButton.setBackgroundColor(color: Theme().keyTint, forUIControlState: .normal)
        actionButton.setBackgroundColor(color: Theme().keyTintHighlight, forUIControlState: .highlighted)
        actionButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        addSubview(actionButton)

        
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|->=0-[titleLabel]->=0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["titleLabel": titleLabel])
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-18-[titleLabel]-6-[subtitleLabel]-14-[actionButton(26)]-28-|", options: .alignAllCenterX, metrics: nil, views: ["titleLabel": titleLabel, "subtitleLabel": subtitleLabel, "actionButton": actionButton])
        addConstraints(hConstraints + vConstraints)
        
        let titleLabelCenterX = NSLayoutConstraint(item: titleLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        addConstraint(titleLabelCenterX)
    }

}
