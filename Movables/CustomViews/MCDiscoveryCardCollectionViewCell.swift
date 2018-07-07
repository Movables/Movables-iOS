//
//  MDDiscoveryCardCollectionViewCell.swift
//  Movables
//
//  Created by Eddie Chen on 5/16/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit

class MCDiscoveryCardCollectionViewCell: UICollectionViewCell {
    
    var packagePreview: PackagePreview!
    var cardView: MCCard!
    var tagPillView: MCPill!
    var headlineLabel: MCCardHeadline!
    var infoStackView: UIStackView!
    var toLabelView: MCCardKeyValueLabel!
    var fromLabelView: MCCardKeyValueLabel!
    var toGoLabel: UILabel!
    var progressBarView: MCProgressBarView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        cardView = MCCard(frame: .zero)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[cardView]-10-|", options: .directionLeadingToTrailing, metrics: nil, views: ["cardView": cardView]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-14-[cardView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["cardView": cardView]))
        
        
        tagPillView = MCPill(frame: .zero, character: "#", image: nil, body: "", color: .white)
        tagPillView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tagPillView)
        contentView.addConstraints([
            NSLayoutConstraint(item: tagPillView, attribute: .top, relatedBy: .equal, toItem: cardView, attribute: .top, multiplier: 1, constant: -14),
            NSLayoutConstraint(item: tagPillView, attribute: .left, relatedBy: .equal, toItem: cardView, attribute: .left, multiplier: 1, constant: -16),
            NSLayoutConstraint(item: tagPillView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 28)
        ])
        
        headlineLabel = MCCardHeadline(frame: .zero, rate: 50, fadeLength: 80, body: "")
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(headlineLabel)
        cardView.addConstraints([
            NSLayoutConstraint(item: headlineLabel, attribute: .top, relatedBy: .equal, toItem: cardView, attribute: .top, multiplier: 1, constant: 26),
            NSLayoutConstraint(item: headlineLabel, attribute: .left, relatedBy: .equal, toItem: cardView, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: headlineLabel, attribute: .right, relatedBy: .equal, toItem: cardView, attribute: .right, multiplier: 1, constant: 0)
            ])

        infoStackView = UIStackView(frame: .zero)
        infoStackView.translatesAutoresizingMaskIntoConstraints = false
        infoStackView.alignment = .leading
        infoStackView.axis = .vertical
        infoStackView.distribution = .fill
        infoStackView.spacing = 10
        cardView.addSubview(infoStackView)
        
        cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-22-[infoStackView]-10-|", options: .directionLeadingToTrailing, metrics: nil, views: ["infoStackView": infoStackView]))
        
        cardView.addConstraint(NSLayoutConstraint(item: infoStackView, attribute: .top, relatedBy: .equal, toItem: headlineLabel, attribute: .bottom, multiplier: 1, constant: 8))
        
        toLabelView = MCCardKeyValueLabel(frame: .zero)
        toLabelView.translatesAutoresizingMaskIntoConstraints = false
        
        fromLabelView = MCCardKeyValueLabel(frame: .zero)
        fromLabelView.translatesAutoresizingMaskIntoConstraints = false
        
        toGoLabel = UILabel(frame: .zero)
        toGoLabel.translatesAutoresizingMaskIntoConstraints = false
        toGoLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        toGoLabel.textAlignment = .right
        
        progressBarView = MCProgressBarView(frame: .zero)
        progressBarView.translatesAutoresizingMaskIntoConstraints = false
        cardView.contentView.addSubview(progressBarView)
        
        cardView.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[progressBarView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["progressBarView": progressBarView]))
        cardView.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[progressBarView(8)]|", options: .alignAllCenterX, metrics: nil, views: ["progressBarView": progressBarView]))
        
    }
    
    func layout() {
        let timeLeftformatter = DateComponentsFormatter()
        timeLeftformatter.unitsStyle = .full
        timeLeftformatter.includesApproximationPhrase = false
        timeLeftformatter.includesTimeRemainingPhrase = true
        timeLeftformatter.maximumUnitCount = 1
        timeLeftformatter.allowedUnits = [.day, .hour, .minute]
        
        // Use the configured formatter to generate the string.
        let timeLeftString = packagePreview.timeLeft > 0 ? timeLeftformatter.string(from: packagePreview.timeLeft) : "Past due"

        
        let distanceLeftformatter = MeasurementFormatter()
        distanceLeftformatter.unitStyle = .short
        distanceLeftformatter.unitOptions = .naturalScale
        distanceLeftformatter.numberFormatter.maximumFractionDigits = 1
        
        let distance = Measurement(value: packagePreview.distanceLeft, unit: UnitLength.meters)
        let distanceLeftString = distanceLeftformatter.string(from: distance)
        
        tagPillView.bodyLabel.text = packagePreview.tagName
        tagPillView.pillContainerView.backgroundColor = getTintForCategory(category: packagePreview.categories.first!)
        tagPillView.characterLabel.text = getEmojiForCategory(category: packagePreview.categories.first!)
        headlineLabel.text = packagePreview.headline
        headlineLabel.restartLabel()
        toLabelView.keyLabel.text = "To"
        fromLabelView.keyLabel.text = packagePreview.destination != nil ? "Destination" : "From"
        toLabelView.valueLabel.text = packagePreview.recipientName
        fromLabelView.valueLabel.text = packagePreview.destination != nil ? packagePreview.destination!.name ?? string(from: packagePreview.destination!.geoPoint) : "\(packagePreview.moversCount) of us"
        toGoLabel.text = packagePreview.packageStatus != .delivered ? "\(distanceLeftString) left / \(timeLeftString!)" : "Delivered"
        infoStackView.addArrangedSubview(toLabelView)
        infoStackView.addArrangedSubview(fromLabelView)
        infoStackView.addArrangedSubview(toGoLabel)
        infoStackView.setCustomSpacing(16, after: fromLabelView)
    infoStackView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[toGoLabel]|", options: .directionLeadingToTrailing, metrics: nil, views: ["toGoLabel": toGoLabel]))
        
        progressBarView.percentage = packagePreview.packageStatus == .delivered ? 1 : min(CGFloat((packagePreview.distanceFrom > 0 ? packagePreview.distanceFrom : 0) / packagePreview.distanceTotal),  1)
        progressBarView.layoutIfNeeded()
        progressBarView.isHidden = true
    }
}