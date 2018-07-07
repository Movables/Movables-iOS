//
//  MCEmptyStateCardView.swift
//  Movables
//
//  Created by Eddie Chen on 6/11/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit

class MCEmptyStateCardView: UIView {

    var cardView: MCCard!
    var titleLabel: UILabel!
    var descriptionLabel: UILabel!
    var actionButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        cardView = MCCard(frame: .zero)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        addSubview(cardView)
        
        addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[cardView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["cardView": cardView]) +
                NSLayoutConstraint.constraints(withVisualFormat: "V:|[cardView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["cardView": cardView])
        )
        
        titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 26, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.text = "Make it happen."
        cardView.addSubview(titleLabel)
        
        descriptionLabel = UILabel(frame: .zero)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        descriptionLabel.text = "Create a new package using templates others have created or create something new from scratch. Your call."
        cardView.addSubview(descriptionLabel)
        
        actionButton = UIButton(frame: .zero)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.setTitle("Create", for: .normal)
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        actionButton.setBackgroundColor(color: Theme().grayTextColor, forUIControlState: .normal)
        actionButton.setBackgroundColor(color: Theme().grayTextColorHighlight, forUIControlState: .highlighted)
        actionButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        actionButton.layer.cornerRadius = 22
        actionButton.clipsToBounds = true
        cardView.addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 36),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -36),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            actionButton.heightAnchor.constraint(equalToConstant: 44),
            actionButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            actionButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 18)
            ])
    }
}
