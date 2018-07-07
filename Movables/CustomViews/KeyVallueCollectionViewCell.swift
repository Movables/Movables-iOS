//
//  KeyVallueCollectionViewCell.swift
//  Movables
//
//  Created by Eddie Chen on 5/20/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit

class KeyVallueCollectionViewCell: UICollectionViewCell {
    
    var separatorView: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addConstraints([
            NSLayoutConstraint(item: contentView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: UIScreen.main.bounds.width),
            NSLayoutConstraint(item: contentView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 88)])
    }
    
}
