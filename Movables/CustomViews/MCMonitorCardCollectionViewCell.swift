//
//  MCMonitorCardCollectionViewCell.swift
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

class MCMonitorCardCollectionViewCell: UICollectionViewCell {
    
    var packageFollowing: PackageFollowing!
    var cardView: MCCard!
    var tagPillView: MCPill!
    var headlineLabel: MCCardHeadline!
    var infoStackView: UIStackView!
    var unreadProgressLabelView: MCCardKeyValueLabel!
    var unreadPostsLabelView: MCCardKeyValueLabel!
    var followDateLabel: UILabel!
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
        
        
        tagPillView = MCPill(frame: .zero, character: "#", image: nil, body: "", color: Theme().keyTint)
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
        
        unreadProgressLabelView = MCCardKeyValueLabel(frame: .zero)
        unreadProgressLabelView.translatesAutoresizingMaskIntoConstraints = false
        
        unreadPostsLabelView = MCCardKeyValueLabel(frame: .zero)
        unreadPostsLabelView.translatesAutoresizingMaskIntoConstraints = false
        
        followDateLabel = UILabel(frame: .zero)
        followDateLabel.translatesAutoresizingMaskIntoConstraints = false
        followDateLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        followDateLabel.textAlignment = .right
        
        progressBarView = MCProgressBarView(frame: .zero)
        progressBarView.translatesAutoresizingMaskIntoConstraints = false
        cardView.contentView.addSubview(progressBarView)
        
        cardView.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[progressBarView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["progressBarView": progressBarView]))
        cardView.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[progressBarView(8)]|", options: .alignAllCenterX, metrics: nil, views: ["progressBarView": progressBarView]))
        
    }
    
    func layout() {
        tagPillView.bodyLabel.text = packageFollowing.tag.name
        headlineLabel.text = packageFollowing.headline
        headlineLabel.restartLabel()
        unreadProgressLabelView.keyLabel.text = "Progress"
        unreadPostsLabelView.keyLabel.text = "Posts"
        unreadProgressLabelView.valueLabel.text = "\(packageFollowing.packageUpdatesCount.unreadProgressEvents ?? 0) new updates"
        unreadPostsLabelView.valueLabel.text = "\(packageFollowing.packageUpdatesCount.unreadPostsEvents ?? 0) new posts"
        followDateLabel.text = "Followed \(packageFollowing.followedDate.timeAgoSinceNow.lowercased())"
        infoStackView.addArrangedSubview(unreadProgressLabelView)
        infoStackView.addArrangedSubview(unreadPostsLabelView)
        infoStackView.addArrangedSubview(followDateLabel)
        infoStackView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[followDateLabel]|", options: .directionLeadingToTrailing, metrics: nil, views: ["followDateLabel": followDateLabel]))
        
        progressBarView.percentage = 0
        
        progressBarView.layoutIfNeeded()
    }
}
