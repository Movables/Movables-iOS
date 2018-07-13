//
//  MCProgressBarView.swift
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
