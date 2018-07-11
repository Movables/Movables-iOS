//
//  MCGoCardView.swift
//  Movables
//
//  Created by Eddie Chen on 6/5/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit
import CountdownLabel

class MCGoCardView: UIView {

    var cardView: MCCard!
    var pillView: MCPill!
    var headlineLabel: MCCardHeadline!
    var countdownLabelView: MCCountdownKeyLabelView!
    var distanceLabelView: MCCardKeyValueLabel!
    var dropoffButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        cardView = MCCard(frame: .zero)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cardView)
        
        addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[cardView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["cardView": cardView]) +
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[cardView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["cardView": cardView])
        )
        
        pillView = MCPill(frame: .zero, character: "#", image: nil, body: "tagName", color: Theme().keyTint)
        pillView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(pillView)
        
        NSLayoutConstraint.activate([
            pillView.heightAnchor.constraint(equalToConstant: 28),
            pillView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 8),
            pillView.centerYAnchor.constraint(equalTo: cardView.topAnchor)
        ])
        
        headlineLabel = MCCardHeadline(frame: .zero, rate: 50, fadeLength: 80, body: "Headline label")
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(headlineLabel)

        NSLayoutConstraint.activate([
            headlineLabel.topAnchor.constraint(equalTo: pillView.bottomAnchor, constant: 12),
            headlineLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            headlineLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
        ])
        
        countdownLabelView = MCCountdownKeyLabelView(frame: .zero)
        countdownLabelView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(countdownLabelView)
        
        NSLayoutConstraint.activate([
            countdownLabelView.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 18),
            countdownLabelView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 22),
            ])
        
        distanceLabelView = MCCardKeyValueLabel(frame: .zero)
        distanceLabelView.translatesAutoresizingMaskIntoConstraints = false
        distanceLabelView.valueLabel.text = "Calculating..."
        distanceLabelView.valueLabel.numberOfLines = 1
        distanceLabelView.keyLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        distanceLabelView.valueLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        distanceLabelView.spacingConstraint.constant = 6
        cardView.addSubview(distanceLabelView)
        
        NSLayoutConstraint.activate([
            distanceLabelView.topAnchor.constraint(equalTo: countdownLabelView.topAnchor),
            distanceLabelView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),
            ])

        dropoffButton = UIButton(frame: .zero)
        dropoffButton.translatesAutoresizingMaskIntoConstraints = false
        dropoffButton.setTitle("Dropoff".localized(key: "button.dropoff"), for: .normal)
        dropoffButton.setTitleColor(.white, for: .normal)
        dropoffButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        dropoffButton.setBackgroundColor(color: Theme().grayTextColor, forUIControlState: .normal)
        dropoffButton.setBackgroundColor(color: Theme().grayTextColorHighlight, forUIControlState: .highlighted)
        dropoffButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        dropoffButton.layer.cornerRadius = 22
        dropoffButton.clipsToBounds = true
        cardView.addSubview(dropoffButton)
        
        NSLayoutConstraint.activate([
            dropoffButton.heightAnchor.constraint(equalToConstant: 44),
            dropoffButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
        ])

    }

}
