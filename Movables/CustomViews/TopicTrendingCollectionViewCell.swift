
//
//  TopicTrendingCollectionViewCell.swift
//  Movables
//
//  Created by Chun-Wei Chen on 6/24/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit

class TopicTrendingCollectionViewCell: UICollectionViewCell {
    
    var baseView: UIView!
    var containerView: UIView!
    var label: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        baseView = UIView(frame: .zero)
        baseView.translatesAutoresizingMaskIntoConstraints = false
        baseView.layer.shadowColor = UIColor.black.cgColor
        baseView.layer.shadowOffset = CGSize(width: 0, height: 0)
        baseView.layer.shadowOpacity = 0.15
        baseView.layer.shadowRadius = 8
        addSubview(baseView)
        
        containerView = UIView(frame: .zero)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 8
        containerView.clipsToBounds = true
        baseView.addSubview(containerView)
        
        label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 17)
        label.numberOfLines = 1
        label.textColor = Theme().grayTextColor
        containerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            baseView.topAnchor.constraint(equalTo: self.topAnchor),
            baseView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            baseView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            baseView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 40),
            containerView.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            containerView.topAnchor.constraint(equalTo: baseView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: baseView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: baseView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: baseView.bottomAnchor),
            label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
        ])
    }
}
