//
//  PostCollectionViewCell.swift
//  Movables
//
//  Created by Eddie Chen on 5/25/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit

class PostCollectionViewCell: UICollectionViewCell {
    
    var parentView: UIView!
    var profileImageView: UIImageView!
    var commentLabel: UILabel!
    var metaLabel: UILabel!
    var separatorView: UIView!
    var post: Post!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        parentView = UIView(frame: .zero)
        parentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(parentView)
        
        addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[parentView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["parentView": parentView]) + NSLayoutConstraint.constraints(withVisualFormat: "V:|[parentView]|", options: .alignAllLeading, metrics: nil, views: ["parentView": parentView])
        )
        
        addConstraint(NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: UIScreen.main.bounds.width)
        )
        
        profileImageView = UIImageView(frame: .zero)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 14
        profileImageView.clipsToBounds = true
        profileImageView.image = UIImage(named: "profile_25pt")
        profileImageView.tintColor = Theme().textColor
        profileImageView.backgroundColor = Theme().backgroundShade
        parentView.addSubview(profileImageView)
        
        metaLabel = UILabel(frame: .zero)
        metaLabel.translatesAutoresizingMaskIntoConstraints = false
        metaLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        metaLabel.textColor = Theme().grayTextColor
        metaLabel.numberOfLines = 1
        parentView.addSubview(metaLabel)
        
        commentLabel = UILabel(frame: .zero)
        commentLabel.translatesAutoresizingMaskIntoConstraints = false
        commentLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        commentLabel.textColor = Theme().textColor
        commentLabel.numberOfLines = 0
        parentView.addSubview(commentLabel)
        
        separatorView = UIView(frame: .zero)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = Theme().borderColor
        parentView.addSubview(separatorView)
        
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[profileImageView(28)]-[metaLabel]-18-|", options: .alignAllCenterY, metrics: nil, views: ["metaLabel": metaLabel, "profileImageView": profileImageView])
        let commentLabelHConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[commentLabel]-18-|", options: .directionLeadingToTrailing, metrics: nil, views: ["commentLabel": commentLabel])
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-26-[commentLabel]-10-[profileImageView]", options: [.alignAllLeading], metrics: nil, views: ["profileImageView": profileImageView, "commentLabel": commentLabel])
        let profileImageVConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[profileImageView(28)]-18-[separatorView]", options: .alignAllLeading, metrics: nil, views: ["profileImageView": profileImageView, "separatorView": separatorView])
        let separatorH = NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[separatorView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["separatorView": separatorView])
        let separatorV = NSLayoutConstraint.constraints(withVisualFormat: "V:[separatorView(1)]|", options: .alignAllTrailing, metrics: nil, views: ["separatorView": separatorView])
        let separatorConstraint = NSLayoutConstraint(item: separatorView, attribute: .top, relatedBy: .equal, toItem: metaLabel, attribute: .bottom, multiplier: 1, constant: 20)
        
        parentView.addConstraints(hConstraints + vConstraints + separatorH + separatorV + profileImageVConstraints + commentLabelHConstraints)
        parentView.addConstraint(separatorConstraint)
    }
}
