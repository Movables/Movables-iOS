//
//  MCCountdownKeyLabelView.swift
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
import CountdownLabel

class MCCountdownKeyLabelView: UIView {

    var keyLabel: UILabel!
    var valueLabel: CountdownLabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        keyLabel = UILabel(frame: .zero)
        keyLabel.translatesAutoresizingMaskIntoConstraints = false
        keyLabel.numberOfLines = 1
        keyLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        addSubview(keyLabel)
        
        valueLabel = CountdownLabel(frame: .zero)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.numberOfLines = 1
        valueLabel.animationType = .Evaporate
        valueLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        addSubview(valueLabel)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[keyLabel]|", options: .directionLeadingToTrailing, metrics: nil, views: ["keyLabel": keyLabel, "valueLabel": valueLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[keyLabel]-6-[valueLabel]|", options: .alignAllCenterX, metrics: nil, views: ["keyLabel": keyLabel, "valueLabel": valueLabel]))
        
        addConstraint(NSLayoutConstraint(item: keyLabel, attribute: .width, relatedBy: .equal, toItem: valueLabel
            , attribute: .width, multiplier: 1, constant: 0))
    }

}
