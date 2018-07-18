//
//  MDExploreCardCollectionViewCell.swift
//  Movables
//
//  MIT License
//
//  Copyright (c) 2018 Eddie Chen
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit
import CoreLocation

class MCExploreCardCollectionViewCell: UICollectionViewCell {
    
    var package: Package!
    var cardView: MCCard!
    var topicPillView: MCPill!
    var headlineLabel: MCCardHeadline!
    var infoStackView: UIStackView!
    var toLabelView: MCCardKeyValueLabel!
    var fromLabelView: MCCardKeyValueLabel!
    var toGoLabel: UILabel!
    var progressBarView: MCProgressBarView!
    var cellWidth: CGFloat!
    
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
        
        
        topicPillView = MCPill(frame: .zero, character: "#", image: nil, body: "", color: .white)
        topicPillView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(topicPillView)
        contentView.addConstraints([
            NSLayoutConstraint(item: topicPillView, attribute: .top, relatedBy: .equal, toItem: cardView, attribute: .top, multiplier: 1, constant: -14),
            NSLayoutConstraint(item: topicPillView, attribute: .left, relatedBy: .equal, toItem: cardView, attribute: .left, multiplier: 1, constant: -16),
            NSLayoutConstraint(item: topicPillView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 28)
        ])
        
        headlineLabel = MCCardHeadline(frame: .zero, rate: 50, fadeLength: 80, body: "")
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.contentView.addSubview(headlineLabel)
        cardView.contentView.addConstraints([
            NSLayoutConstraint(item: headlineLabel, attribute: .top, relatedBy: .equal, toItem: cardView.contentView, attribute: .top, multiplier: 1, constant: 26),
            NSLayoutConstraint(item: headlineLabel, attribute: .left, relatedBy: .equal, toItem: cardView.contentView, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: headlineLabel, attribute: .right, relatedBy: .equal, toItem: cardView.contentView, attribute: .right, multiplier: 1, constant: 0)
            ])

        infoStackView = UIStackView(frame: .zero)
        infoStackView.translatesAutoresizingMaskIntoConstraints = false
        infoStackView.alignment = .leading
        infoStackView.axis = .vertical
        infoStackView.distribution = .fill
        infoStackView.spacing = 10
        cardView.contentView.addSubview(infoStackView)
        
        cardView.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-22-[infoStackView]-10-|", options: .directionLeadingToTrailing, metrics: nil, views: ["infoStackView": infoStackView]))
        
        cardView.contentView.addConstraint(NSLayoutConstraint(item: infoStackView, attribute: .top, relatedBy: .equal, toItem: headlineLabel, attribute: .bottom, multiplier: 1, constant: 8))
        
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
        cardView.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[infoStackView]-8-[progressBarView(8)]|", options: [], metrics: nil, views: ["progressBarView": progressBarView, "infoStackView": infoStackView]))
        
    }
    
    func layout() {
        let timeLeftformatter = DateComponentsFormatter()
        timeLeftformatter.unitsStyle = .full
        timeLeftformatter.includesApproximationPhrase = false
        timeLeftformatter.includesTimeRemainingPhrase = true
        timeLeftformatter.maximumUnitCount = 1
        timeLeftformatter.allowedUnits = [.day, .hour, .minute]
        
        let timeLeft = package.dueDate.timeIntervalSinceReferenceDate - Date.timeIntervalSinceReferenceDate

        // Use the configured formatter to generate the string.
        let timeLeftString = timeLeft > 0 ? timeLeftformatter.string(from: timeLeft) : String(NSLocalizedString("label.pastDue", comment: "status label for past due status"))

        
        let distanceLeftformatter = MeasurementFormatter()
        distanceLeftformatter.unitStyle = .short
        distanceLeftformatter.unitOptions = .naturalScale
        distanceLeftformatter.numberFormatter.maximumFractionDigits = 1

        let currentLocation = package.currentLocation
        
        let destination = CLLocation(latitude: package.destination.geoPoint.latitude, longitude: package.destination.geoPoint.longitude)
        
        let origin = CLLocation(latitude: package.origin.geoPoint.latitude, longitude: package.origin.geoPoint.longitude)
        let distanceTotal = destination.distance(from: origin)
        let distanceLeft = destination.distance(from: currentLocation)
        let distanceFrom =  distanceTotal - distanceLeft

        let distance = Measurement(value: distanceLeft, unit: UnitLength.meters)
        let distanceLeftString = distanceLeftformatter.string(from: distance)
        
        topicPillView.bodyLabel.text = package.topic.name
        topicPillView.pillContainerView.backgroundColor = getTintForCategory(category: package.category)
        topicPillView.characterLabel.text = getEmojiForCategory(category: package.category)
        headlineLabel.text = package.headline
        headlineLabel.restartLabel()
        toLabelView.keyLabel.text = String(NSLocalizedString("label.recipient", comment: "label title for recipient label"))
        fromLabelView.keyLabel.text = String(NSLocalizedString("label.destination", comment: "label title for destination label"))
        toLabelView.valueLabel.text = package.recipient.displayName
        fromLabelView.valueLabel.text = package.destination.name ?? string(from: package.destination.geoPoint)
        toGoLabel.text = package.status != .delivered ? "\(distanceLeftString) / \(timeLeftString!)" : String(NSLocalizedString("label.delivered", comment: "label title for package delivered status"))
        infoStackView.addArrangedSubview(toLabelView)
        infoStackView.addArrangedSubview(fromLabelView)
        infoStackView.addArrangedSubview(toGoLabel)
        infoStackView.setCustomSpacing(16, after: fromLabelView)
    infoStackView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[toGoLabel]|", options: .directionLeadingToTrailing, metrics: nil, views: ["toGoLabel": toGoLabel]))
        
        progressBarView.percentage = package.status == .delivered ? 1 : min(CGFloat((distanceFrom > 0 ? distanceFrom : 0) / distanceTotal),  1)
        progressBarView.layoutIfNeeded()
        progressBarView.isHidden = true
        
        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(equalToConstant: cellWidth)
        ])
    }
}
