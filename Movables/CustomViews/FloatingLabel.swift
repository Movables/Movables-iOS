//
//  FloatingLabel.swift
//  Movables
//
//  Created by Eddie Chen on 6/14/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit

class FloatingLabel: UIView {

    var baseView: UIView!
    var label: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}
