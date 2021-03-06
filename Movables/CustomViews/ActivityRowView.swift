//
//  ActivityRowView.swift
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

struct ActivityRowViewData {
    var profilePicUrl: String?
    var logisticRowType: LogisticsRowType
    var titleText: String
    var subtitleText: String
    
    init(profilePicUrl: String?, logisticRowType: LogisticsRowType, titleText: String, subtitleText: String) {
        self.profilePicUrl = profilePicUrl
        self.logisticRowType = logisticRowType
        self.titleText = titleText
        self.subtitleText = subtitleText
    }
}

class ActivityRowView: UIView {

    var imageView: UIImageView!
    var labelsContainerView: UIView!
    var titleLabel: UILabel!
    var subtitleLabel: UILabel!
    var buttonsStackView: UIStackView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = Theme().textColor
        imageView.backgroundColor = Theme().textColor.withAlphaComponent(0.1)
        self.addSubview(imageView)

        labelsContainerView = UIView(frame: .zero)
        labelsContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(labelsContainerView)

        titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = Theme().textColor
        titleLabel.numberOfLines = 0
        labelsContainerView.addSubview(titleLabel)

        subtitleLabel = UILabel(frame: .zero)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        subtitleLabel.textColor = Theme().grayTextColor
        subtitleLabel.numberOfLines = 1
        labelsContainerView.addSubview(subtitleLabel)

        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[titleLabel]|", options: .directionLeadingToTrailing, metrics: nil, views: ["titleLabel": titleLabel, "subtitleLabel": subtitleLabel])
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-1-[subtitleLabel]-2-[titleLabel]|", options: [.alignAllLeading, .alignAllTrailing], metrics: nil, views: ["titleLabel": titleLabel, "subtitleLabel": subtitleLabel])
        labelsContainerView.addConstraints(hConstraints + vConstraints)

        buttonsStackView = UIStackView(frame: .zero)
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.axis = .horizontal
        buttonsStackView.spacing = 18
        buttonsStackView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        self.addSubview(buttonsStackView)
        
        buttonsStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -18).isActive = true
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView(48)]-4-|", options: .alignAllLeading, metrics: nil, views: ["imageView": imageView]))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[imageView(48)]-8-[labelsContainerView]->=0-[buttonsStackView]", options: .directionLeadingToTrailing, metrics: nil, views: ["imageView": imageView, "labelsContainerView": labelsContainerView, "buttonsStackView": buttonsStackView]))
        
        self.addConstraint(NSLayoutConstraint(item: labelsContainerView, attribute: .centerY, relatedBy: .equal, toItem: imageView, attribute: .centerY, multiplier: 1, constant: 0))
        
        self.addConstraint(NSLayoutConstraint(item: buttonsStackView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))

    }
    
    convenience init(frame: CGRect, row: LogisticsRow) {
        
        self.init(frame: frame)
        
        imageView = UIImageView(frame: .zero)
        if row.type == .Person && row.circleImageUrl != nil && !row.circleImageUrl!.isEmpty{
            imageView.sd_setImage(with: URL(string: row.circleImageUrl!)) { (image, error, cacheType, url) in
                if error != nil {
                    print(error?.localizedDescription)
                }
            }
        } else {
            imageView.image = getImage(for: row.type)
        }
        imageView.tintColor = row.tint
        imageView.backgroundColor = row.tint.withAlphaComponent(0.1)

        
        titleLabel.text = row.titleText
        
        subtitleLabel.text = row.subtitleText.uppercased()
        
        if row.actions != nil {
            for action in row.actions! {
                let button = UIButton(frame: .zero)
                button.translatesAutoresizingMaskIntoConstraints = false
                button.setImage(getImageForActionType(actionType: action.type), for: .normal)
                buttonsStackView.addArrangedSubview(button)
                self.addConstraints([
                    NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 44),
                    NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 44)
                    ])
            }
        }
        
    }
}

func getImage(for logisticsRowType: LogisticsRowType) -> UIImage? {
    switch logisticsRowType {
    case .Person:
        return UIImage(named: "profile_25pt")
    case .Time:
        return UIImage(named: "timer_25pt")
    case .Destination:
        return UIImage(named: "destination_25pt")
    case .Directions:
        return UIImage(named: "directions_25pt")
    case .Award:
        return UIImage(named: "award_25pt")
    case .Balance:
        return UIImage(named: "balance_25pt")
    case .PersonCount:
        return UIImage(named: "people_25pt")
    case .Distance:
        return UIImage(named: "navigation_25pt")
    }
}
