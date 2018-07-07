//
//  MCCardHeadline.swift
//  Movables
//
//  Created by Eddie Chen on 5/15/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit
import MarqueeLabel

class MCCardHeadline: MarqueeLabel {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, rate: CGFloat, fadeLength fade: CGFloat, body: String) {
        super.init(frame: frame, rate: rate, fadeLength: fade)
        
        font = UIFont.systemFont(ofSize: 24).bold
        textColor = .black
        textAlignment = .natural
        text = body
        trailingBuffer = 38
        animationDelay = 2
        leadingBuffer = 22
    }

}
