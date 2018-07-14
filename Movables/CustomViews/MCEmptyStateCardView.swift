//
//  MCEmptyStateCardView.swift
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

class MCEmptyStateCardView: UIView {

    var containerView: UIView!
    var cardView: MCCard!
    var titleLabel: UILabel!
    var descriptionLabel: UILabel!
    var actionButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        cardView = MCCard(frame: .zero)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        addSubview(cardView)
        
        addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[cardView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["cardView": cardView]) +
                NSLayoutConstraint.constraints(withVisualFormat: "V:|[cardView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["cardView": cardView])
        )
        
        containerView = UIView(frame: .zero)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(containerView)
        
        titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 26, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.text = String(NSLocalizedString("copy.makeItHappen", comment: "Move tab empty state title"))
        containerView.addSubview(titleLabel)
        
        descriptionLabel = UILabel(frame: .zero)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        descriptionLabel.text = String(NSLocalizedString("copy.makeItHappenBody", comment: "Move tab empty state body"))
        containerView.addSubview(descriptionLabel)
        
        actionButton = UIButton(frame: .zero)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.setTitle(String(NSLocalizedString("button.create", comment: "Create button title")), for: .normal)
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        actionButton.setBackgroundColor(color: Theme().grayTextColor, forUIControlState: .normal)
        actionButton.setBackgroundColor(color: Theme().grayTextColorHighlight, forUIControlState: .highlighted)
        actionButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        actionButton.layer.cornerRadius = 22
        actionButton.clipsToBounds = true
        containerView.addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 44),
            containerView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            containerView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 36),
            containerView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -36),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            actionButton.heightAnchor.constraint(equalToConstant: 44),
            actionButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            actionButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            actionButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 18)
        ])
    }
}
