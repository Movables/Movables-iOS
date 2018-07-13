//
//  UserEventView.swift
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
import TTTAttributedLabel

class UserEventView: UIView {

    var profilePicImageView: UIImageView!
    var eventLabel: TTTAttributedLabel!
    var dateLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        profilePicImageView = UIImageView(frame: .zero)
        profilePicImageView.translatesAutoresizingMaskIntoConstraints = false
        profilePicImageView.layer.cornerRadius = 18
        profilePicImageView.contentMode = .scaleAspectFill
        profilePicImageView.clipsToBounds = true
        profilePicImageView.backgroundColor = Theme().backgroundShade
        addSubview(profilePicImageView)
        
        eventLabel = TTTAttributedLabel(frame: .zero)
        eventLabel.translatesAutoresizingMaskIntoConstraints = false
        eventLabel.font = UIFont.systemFont(ofSize: 15)
        eventLabel.textColor = Theme().textColor
        eventLabel.numberOfLines = 0
        eventLabel.text = "event label"
        let objectAttributes = [
            kCTFontAttributeName: UIFont.systemFont(ofSize: 15, weight: .semibold),
            kTTTBackgroundFillPaddingAttributeName: 10,
            ] as [AnyHashable : Any]
        
        let activeObjectAttributes = [
            kCTFontAttributeName: UIFont.systemFont(ofSize: 15, weight: .semibold),
            kCTForegroundColorAttributeName: Theme().textColor,
            kTTTBackgroundFillColorAttributeName: Theme().borderColor,
            kTTTBackgroundCornerRadiusAttributeName: 3,
            kTTTBackgroundFillPaddingAttributeName: 10,
            ] as [AnyHashable : Any]
        
        eventLabel.linkAttributes = objectAttributes
        eventLabel.inactiveLinkAttributes = objectAttributes
        eventLabel.activeLinkAttributes = activeObjectAttributes
        eventLabel.longPressGestureRecognizer.cancelsTouchesInView = false
        addSubview(eventLabel)
        
        dateLabel = UILabel(frame: .zero)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        dateLabel.textColor = Theme().grayTextColorHighlight
        dateLabel.numberOfLines = 1
        dateLabel.text = "time ago"
        addSubview(dateLabel)

        NSLayoutConstraint.activate([
            profilePicImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 18),
            profilePicImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 18),
            profilePicImageView.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor, constant: -20),
            profilePicImageView.widthAnchor.constraint(equalToConstant: 36),
            profilePicImageView.heightAnchor.constraint(equalToConstant: 36),
            eventLabel.topAnchor.constraint(equalTo: profilePicImageView.topAnchor, constant: 4),
            eventLabel.leadingAnchor.constraint(equalTo: profilePicImageView.trailingAnchor, constant: 12),
            eventLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -18),
            dateLabel.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor, constant: -20),
            dateLabel.leadingAnchor.constraint(equalTo: eventLabel.leadingAnchor),
            dateLabel.topAnchor.constraint(equalTo: eventLabel.bottomAnchor, constant: 6),
        ])

    }
}
