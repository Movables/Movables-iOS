//
//  CircularToggleCollectionViewCell.swift
//  Movables
//
//  Created by Eddie Chen on 6/24/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit

class CircularToggleCollectionViewCell: UICollectionViewCell {
    
    var parentView: UIView!
    var containerView: UIView!
    var label: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        parentView = UIView(frame: .zero)
        parentView.translatesAutoresizingMaskIntoConstraints = false
        parentView.layer.shadowColor = UIColor.black.cgColor
        parentView.layer.shadowOffset = CGSize(width: 0, height: 0)
        parentView.layer.shadowOpacity = 0.15
        parentView.layer.shadowRadius = 8
        addSubview(parentView)
        
        containerView = UIView(frame: .zero)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 30
        containerView.clipsToBounds = true
        parentView.addSubview(containerView)
        
        label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 30)
        label.numberOfLines = 1
        label.textColor = Theme().grayTextColor
        containerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            parentView.topAnchor.constraint(equalTo: self.topAnchor),
            parentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            parentView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            parentView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 60),
            containerView.widthAnchor.constraint(equalToConstant: 60),
            containerView.topAnchor.constraint(equalTo: parentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
            label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
        ])
    }
}
