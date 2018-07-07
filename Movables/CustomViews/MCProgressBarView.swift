//
//  MCProgressBarView.swift
//  Movables
//
//  Created by Eddie Chen on 5/16/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit

class MCProgressBarView: UIView {

    var progressWidthConstraint: NSLayoutConstraint!
    
    var percentage: CGFloat = 0
    var baseView: UIView!
    var progressView: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        baseView = UIView(frame: .zero)
        baseView.translatesAutoresizingMaskIntoConstraints = false
        baseView.backgroundColor = Theme().borderColor
        addSubview(baseView)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[baseView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["baseView": baseView]))
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[baseView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["baseView": baseView]))

        progressView = UIView(frame: .zero)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.backgroundColor = Theme().keyTint
        baseView.addSubview(progressView)
    baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[progressView]|", options: .alignAllCenterX, metrics: nil, views: ["progressView": progressView]))
        baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[progressView]", options: .directionLeadingToTrailing, metrics: nil, views: ["progressView": progressView]))
        progressWidthConstraint = NSLayoutConstraint(item: progressView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: self.frame.width * percentage)
        baseView.addConstraint(progressWidthConstraint)
        layoutIfNeeded()
    }
    
    func animateProgress() {
        if self.progressWidthConstraint.constant != self.frame.width * self.percentage {
            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 4, options: .overrideInheritedOptions, animations: {
                self.progressWidthConstraint.constant = self.frame.width * self.percentage
                self.layoutIfNeeded()
            }) { (success) in
                // animation succeeded
            }
        }
    }
}
