//
//  TitleView.swift
//  Movables
//
//  Created by Eddie Chen on 6/10/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit
import MarqueeLabel

class TitleView: UIView {

    var titleLabel: MarqueeLabel!
    var subtitleLabel: MarqueeLabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, title: String, subtitle: String) {
        super.init(frame: frame)
        
        titleLabel = MarqueeLabel(frame: .zero, rate: 50, fadeLength: 80)
        titleLabel.trailingBuffer = 50
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        titleLabel.text = title
        addSubview(titleLabel)
        
        subtitleLabel = MarqueeLabel(frame: .zero, rate: 50, fadeLength: 80)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.textAlignment = .center
        subtitleLabel.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        subtitleLabel.text = subtitle
        addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 1),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor)
        ])
    }
}
