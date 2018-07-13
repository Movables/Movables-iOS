//
//  CircleLabelStackViewCollectionViewCell.swift
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

struct CircleLabelWithTitleSubtitle {
    var circleImage: UIImage?
    var circleText: String?
    var circleSubscript: String?
    var circleLabelText: String!
    var titleText: String!
    var subtitleText: String!
    var circleColor: UIColor!
    
    init(circleImage: UIImage?, circleText: String?, circleSubscript: String?, circleLabelText: String, titleText: String, subtitleText: String, circleColor: UIColor?) {
        self.circleImage = circleImage
        self.circleText = circleText
        self.circleSubscript = circleSubscript
        self.circleLabelText = circleLabelText
        self.titleText = titleText
        self.subtitleText = subtitleText
        self.circleColor = circleColor ?? Theme().keyTint
    }
}

class CircleLabelStackViewCollectionViewCell: UICollectionViewCell {
    
    var parentView: UIView!
    var stackView: UIStackView!
    var units: [CircleLabelWithTitleSubtitle]!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        parentView = UIView(frame: .zero)
        parentView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(parentView)
        
        
        stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 18
        stackView.distribution = .equalSpacing
        parentView.addSubview(stackView)
        
        let viewsDictionary: [String: UIView] = ["parentView": parentView, "stackView": stackView]

        addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[parentView(screenWidth)]|", options: .directionLeadingToTrailing, metrics: ["screenWidth": UIScreen.main.bounds.width], views: viewsDictionary) +
                NSLayoutConstraint.constraints(withVisualFormat: "V:|[parentView]|", options: .alignAllLeading, metrics: nil, views: viewsDictionary)
        )

        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[stackView]-18-|", options: .directionLeadingToTrailing, metrics: nil, views: viewsDictionary) + NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[stackView]-20-|", options: .alignAllLeading, metrics: nil, views: viewsDictionary))
        

    }
    
    func layout() {
        if stackView.arrangedSubviews.count != units.count {
            
            for unit in units {
                
                let personContainerView = UIView(frame: .zero)
                personContainerView.translatesAutoresizingMaskIntoConstraints = false
                stackView.addArrangedSubview(personContainerView)
                
                let imageView = UIImageView(image: unit.circleImage)
                imageView.translatesAutoresizingMaskIntoConstraints = false
                imageView.layer.borderColor = unit.circleColor.cgColor
                imageView.layer.borderWidth = 2
                imageView.layer.cornerRadius = 28
                imageView.clipsToBounds = true
                personContainerView.addSubview(imageView)
                personContainerView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 56))
                personContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView(56)]|", options: .alignAllLeading, metrics: nil, views: ["imageView": imageView]))
                
                let labelsView = UIView(frame: .zero)
                labelsView.translatesAutoresizingMaskIntoConstraints = false
                personContainerView.addSubview(labelsView)
                
                let titleLabel = UILabel(frame: .zero)
                titleLabel.translatesAutoresizingMaskIntoConstraints = false
                titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
                titleLabel.text = unit.titleText
                titleLabel.textColor = Theme().textColor
                titleLabel.numberOfLines = 1
                labelsView.addSubview(titleLabel)
                
                let subtitleLabel = UILabel(frame: .zero)
                subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
                subtitleLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
                subtitleLabel.text = unit.subtitleText
                subtitleLabel.textColor = Theme().grayTextColor
                subtitleLabel.numberOfLines = 1
                labelsView.addSubview(subtitleLabel)
                
                let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[titleLabel]|", options: .directionLeadingToTrailing, metrics: nil, views: ["titleLabel": titleLabel, "subtitleLabel": subtitleLabel])
                let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[subtitleLabel][titleLabel]|", options: [.alignAllLeading, .alignAllTrailing], metrics: nil, views: ["titleLabel": titleLabel, "subtitleLabel": subtitleLabel])
                labelsView.addConstraints(hConstraints + vConstraints)
                
                personContainerView.addConstraint(NSLayoutConstraint(item: labelsView, attribute: .centerY, relatedBy: .equal, toItem: imageView, attribute: .centerY, multiplier: 1, constant: 0))
                
                personContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]-8-[labelsView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["imageView": imageView, "labelsView": labelsView]))

            }
        }
    }
    
    
}
