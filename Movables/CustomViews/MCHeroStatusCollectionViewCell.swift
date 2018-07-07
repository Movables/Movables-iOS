//
//  MCHeroStatusCollectionViewCell.swift
//  Movables
//
//  Created by Eddie Chen on 6/9/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit

class MCHeroStatusCollectionViewCell: UICollectionViewCell {
 
    var parentView: UIView!
    var titleLabel: UILabel!
    var imageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupParentView()
        setupImageView()
        setupTitleLabel()
    }
    
    private func setupParentView() {
        parentView = UIView(frame: .zero)
        parentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(parentView)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[parentView(screenWidth)]|", options: .directionLeadingToTrailing, metrics: ["screenWidth": UIScreen.main.bounds.width], views: ["parentView": parentView]) + NSLayoutConstraint.constraints(withVisualFormat: "V:|[parentView]|", options: .alignAllLeading, metrics: nil, views: ["parentView": parentView]))
    }
    
    private func setupTitleLabel() {
        titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .regular)
        titleLabel.numberOfLines = 0
        titleLabel.textColor = Theme().textColor
        titleLabel.textAlignment = .center
        parentView.addSubview(titleLabel)
        
        let bottomConstraint = titleLabel.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: -80)
        bottomConstraint.priority = .defaultHigh

        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo:
                parentView.leadingAnchor, constant: 50),
            titleLabel.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -50),
            bottomConstraint
        ])
    }
    
    private func setupImageView() {
        imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = Theme().borderColor
        imageView.layer.cornerRadius = 85
        imageView.clipsToBounds = true
        parentView.addSubview(imageView)
        
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: parentView.topAnchor, constant: 50),
            imageView.widthAnchor.constraint(equalToConstant: 170),
            imageView.heightAnchor.constraint(equalToConstant: 170),
            imageView.centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
        ])
    }
}
