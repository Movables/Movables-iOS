//
//  ExploreEmptyStateCardCollectionViewCell.swift
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
import CoreLocation

class ExploreEmptyStateCardCollectionViewCell: UICollectionViewCell {
    
    var cardView: MCCard!
    var emptyStateView: EmptyStateView!
    var cellWidth: CGFloat!
    var cellHeight: CGFloat!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        cardView = MCCard(frame: .zero)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[cardView]-10-|", options: .directionLeadingToTrailing, metrics: nil, views: ["cardView": cardView]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-28-[cardView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["cardView": cardView]))
        
        emptyStateView = EmptyStateView(frame: .zero)
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.subtitleLabel.text = "No packages found."
        cardView.addSubview(emptyStateView)
        
    }
    
    func layout() {
        
        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(equalToConstant: cellWidth),
            contentView.heightAnchor.constraint(equalToConstant: cellHeight),
            emptyStateView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),

        ])
    }
}
