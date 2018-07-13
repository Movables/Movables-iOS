//
//  MCHeroStatusCollectionViewCell.swift
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

class MCHeroStatusCollectionViewCell: UICollectionViewCell {
 
    var parentView: UIView!
    var titleLabel: UILabel!
    var imageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupParentView()
        setupImageView()
        setupTitleLabel()
    }
    
    private func setupParentView() {
        parentView = UIView(frame: .zero)
        parentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(parentView)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[parentView(screenWidth)]|", options: .directionLeadingToTrailing, metrics: ["screenWidth": UIScreen.main.bounds.width], views: ["parentView": parentView]) + NSLayoutConstraint.constraints(withVisualFormat: "V:|[parentView]|", options: .alignAllLeading, metrics: nil, views: ["parentView": parentView]))
    }
    
    private func setupTitleLabel() {
        titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .regular)
        titleLabel.numberOfLines = 0
        titleLabel.textColor = Theme().textColor
        titleLabel.textAlignment = .center
        parentView.addSubview(titleLabel)
        
        let bottomConstraint = titleLabel.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: -80)
        bottomConstraint.priority = .defaultHigh

        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo:
                parentView.leadingAnchor, constant: 50),
            titleLabel.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -50),
            bottomConstraint
        ])
    }
    
    private func setupImageView() {
        imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = Theme().borderColor
        imageView.layer.cornerRadius = 85
        imageView.clipsToBounds = true
        parentView.addSubview(imageView)
        
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: parentView.topAnchor, constant: 50),
            imageView.widthAnchor.constraint(equalToConstant: 170),
            imageView.heightAnchor.constraint(equalToConstant: 170),
            imageView.centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
        ])
    }
}
