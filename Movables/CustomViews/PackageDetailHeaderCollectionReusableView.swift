//
//  PackageDetailHeaderCollectionReusableView.swift
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
import MarqueeLabel

class PackageDetailHeaderCollectionReusableView: UICollectionReusableView {
    
    var imageView: UIImageView!
    var titleLabel: MarqueeLabel!
    var tagPill: MCPill!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .black
        if UIDevice.isIphoneX {
            layer.cornerRadius = 18
        } else {
            layer.cornerRadius = 0
        }
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        clipsToBounds = true
        
        imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
        imageView.contentMode = .scaleAspectFill
        imageView.alpha = 0.7
        addSubview(imageView)
        
        titleLabel = MarqueeLabel(frame: .zero, rate: 60, fadeLength: 80)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.trailingBuffer = 42
        titleLabel.leadingBuffer = 18
        titleLabel.animationDelay = 2
        titleLabel.numberOfLines = 1
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.text = "Headline"
        addSubview(titleLabel)
        
        tagPill = MCPill(frame: .zero, character: "#", image: nil, body: "tag", color: Theme().keyTint)
        tagPill.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tagPill)
        
        
        let viewsDictionary: [String: UIView] = ["imageView": imageView, "titleLabel": titleLabel, "tagPill": tagPill]
        
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]|", options: .directionLeadingToTrailing, metrics: nil, views: viewsDictionary)
        
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView]|", options: .alignAllCenterX, metrics: nil, views: viewsDictionary)
        
        addConstraints(hConstraints + vConstraints)
        
        let hLabelsConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-14-[tagPill]->=18-|", options: .directionLeadingToTrailing, metrics: nil, views: ["tagPill": tagPill])
        
        let hTitleLabelsConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[titleLabel]|", options: .directionLeadingToTrailing, metrics: nil, views: ["titleLabel": titleLabel])
        
        NSLayoutConstraint.activate([
            tagPill.heightAnchor.constraint(equalToConstant: 28),
            titleLabel.topAnchor.constraint(equalTo: tagPill.bottomAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -24),
        ])
        
        
        for constraint in hLabelsConstraints {
            constraint.priority = .defaultHigh
        }
        
        addConstraints(hLabelsConstraints + hTitleLabelsConstraints)
    }
}
