//
//  UnderlineTableViewHeaderView.swift
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

class UnderlineTableViewHeaderView: UITableViewHeaderFooterView {

    var titleLabel: UILabel!
    var underlineView: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .white
        
        titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        titleLabel.numberOfLines = 1
        titleLabel.textColor = Theme().grayTextColor
        contentView.addSubview(titleLabel)
        
        underlineView = UIView(frame: .zero)
        underlineView.translatesAutoresizingMaskIntoConstraints = false
        underlineView.backgroundColor = Theme().grayTextColorHighlight
        contentView.addSubview(underlineView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            underlineView.heightAnchor.constraint(equalToConstant: 1),
            underlineView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            underlineView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            underlineView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            underlineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
}
