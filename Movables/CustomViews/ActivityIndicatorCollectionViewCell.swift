//
//  ActivityIndicatorCollectionViewCell.swift
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
import NVActivityIndicatorView

class ActivityIndicatorCollectionViewCell: UICollectionViewCell {
    
    var activityIndicatorView: NVActivityIndicatorView!
    var parentView: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        parentView = UIView(frame: .zero)
        parentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(parentView)
        
        let parentViewH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[parentView(screenWidth)]|", options: .directionLeadingToTrailing, metrics: ["screenWidth": UIScreen.main.bounds.width], views: ["parentView": parentView])
        
        let parentViewV = NSLayoutConstraint.constraints(withVisualFormat: "V:|[parentView(120)]|", options: .alignAllLeading, metrics: nil, views: ["parentView": parentView])
        
        addConstraints(parentViewH + parentViewV)
        
        activityIndicatorView = NVActivityIndicatorView(frame: .zero, type: .ballScale, color: Theme().textColor, padding: 0)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(activityIndicatorView)
        
        let activityViewH = NSLayoutConstraint.constraints(withVisualFormat: "H:[activityIndicatorView(50)]", options: .directionLeadingToTrailing, metrics: nil, views: ["activityIndicatorView": activityIndicatorView])
        
        let activityViewV = NSLayoutConstraint.constraints(withVisualFormat: "V:[activityIndicatorView(50)]", options: .alignAllCenterX, metrics: nil, views: ["activityIndicatorView": activityIndicatorView])
        
        let activityViewCenterX = NSLayoutConstraint(item: activityIndicatorView, attribute: .centerX, relatedBy: .equal, toItem: parentView, attribute: .centerX, multiplier: 1, constant: 0)
        
        let activityViewCenterY = NSLayoutConstraint(item: activityIndicatorView, attribute: .centerY, relatedBy: .equal, toItem: parentView, attribute: .centerY, multiplier: 1, constant: 0)

        parentView.addConstraints(activityViewH + activityViewV + [activityViewCenterX, activityViewCenterY])
    }
}
