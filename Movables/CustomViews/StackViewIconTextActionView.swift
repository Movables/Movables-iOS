//
//  StackViewIconTextActionView.swift
//  Movables
//
//  Created by Eddie Chen on 6/22/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit

class StackViewIconTextActionView: UIView {

    var iconImageView: UIImageView!
    var textLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        iconImageView = UIImageView(frame: .zero)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = Theme().grayTextColor
        addSubview(iconImageView)
        
        textLabel = UILabel(frame: .zero)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.numberOfLines = 1
        textLabel.textColor = Theme().grayTextColor
        textLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textLabel.textAlignment = .center
        addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            iconImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            textLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor),
            textLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            textLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -25),
        ])
    }
    
}
