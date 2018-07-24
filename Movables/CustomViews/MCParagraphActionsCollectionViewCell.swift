//
//  MCParagraphActionsCollectionViewCell.swift
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

struct ExternalAction {
    var type: ExternalActionType?
    var description: String?
    var webLink: String?
    
    init(type: ExternalActionType, description: String?, webLink: String) {
        self.type = type
        self.description = description
        self.webLink = webLink
    }
    
    init() {
        self.type = nil
        self.description = nil
        self.webLink = nil
    }
    
    init(dict: [String: Any]) {
        self.type = getEnumForExternalAction(string: dict["type"] as! String)
        self.description = dict["description"]! as? String
        self.webLink = dict["web_link"]! as? String
    }
}

enum ExternalActionType {
    case donate
    case act
    case learn
    case unknown
}

let externalActionsEnumArray: [ExternalActionType] = [.donate, .act, .learn]

func getStringForExternalAction(type: ExternalActionType) -> String {
    switch type {
    case .donate:
        return String(NSLocalizedString("label.donate", comment: "label text for donate"))
    case .act:
        return String(NSLocalizedString("label.act", comment: "label text for take action"))
    case .learn:
        return String(NSLocalizedString("label.learn", comment: "label text for learn"))
    default:
        return ""
    }
}

func getEnumForExternalAction(string: String) -> ExternalActionType {
    switch string {
    case "Donate":
        return .donate
    case "Take Action":
        return .act
    case "Learn":
        return .learn
    default:
        return .unknown
    }
}


class MCParagraphActionsCollectionViewCell: UICollectionViewCell {
    
    var parentView: UIView!
    var cardView: UIView!
    var paragraphLabel: UILabel!
    var actionsStackView: UIStackView!
    var actions: [ExternalAction]!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupParentView()
        setupCardView()
        setupActionsStackView()
    }
    
    private func setupParentView() {
        parentView = UIView(frame: .zero)
        parentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(parentView)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[parentView(screenWidth)]|", options: .directionLeadingToTrailing, metrics: ["screenWidth": UIScreen.main.bounds.width], views: ["parentView": parentView]) + NSLayoutConstraint.constraints(withVisualFormat: "V:|[parentView]|", options: .alignAllLeading, metrics: nil, views: ["parentView": parentView]))
    }
    
    private func setupCardView() {
        cardView = UIView(frame: .zero)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.clipsToBounds = true
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 8
        cardView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        cardView.layer.borderColor = Theme().keyTint.withAlphaComponent(0.3).cgColor
        cardView.layer.borderWidth = 1
        parentView.addSubview(cardView)
        
        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[cardView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["cardView": cardView]) + NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[cardView]", options: .alignAllLeading, metrics: nil, views: ["cardView": cardView]))
        let bottomConstraint = NSLayoutConstraint(item: cardView, attribute: .bottom, relatedBy: .equal, toItem: parentView, attribute: .bottom, multiplier: 1, constant: -4)
        bottomConstraint.priority = .defaultHigh
        parentView.addConstraint(bottomConstraint)
    }
    
    private func setupActionsStackView() {
        paragraphLabel = UILabel(frame: .zero)
        paragraphLabel.translatesAutoresizingMaskIntoConstraints = false
        paragraphLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        paragraphLabel.numberOfLines = 0
        paragraphLabel.textColor = Theme().textColor
        paragraphLabel.text = "Bacon ipsum dolor amet cupim pork loin brisket chuck. Tail kielbasa jerky, beef tenderloin doner pastrami kevin short ribs. Beef pork chop boudin shoulder, fatback pancetta ham hock turkey spare ribs venison. Drumstick rump chicken shank."
        cardView.addSubview(paragraphLabel)
        
        actionsStackView = UIStackView(frame: .zero)
        actionsStackView.translatesAutoresizingMaskIntoConstraints = false
        actionsStackView.axis = .vertical
        actionsStackView.alignment = .leading
        actionsStackView.spacing = 18
        actionsStackView.distribution = .equalSpacing
        cardView.addSubview(actionsStackView)
        
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[paragraphLabel]-18-|", options: .directionLeadingToTrailing, metrics: nil, views: ["paragraphLabel": paragraphLabel])
        
        let hActionsStackViewConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[actionsStackView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["actionsStackView": actionsStackView])

        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-30-[paragraphLabel]-18-[actionsStackView]-24-|", options: .alignAllCenterX, metrics: nil, views: ["paragraphLabel": paragraphLabel, "actionsStackView": actionsStackView])
        
        cardView.addConstraints(hConstraints + hActionsStackViewConstraints + vConstraints)
    }

    func activateStackView() {
        print("activate")
        if actionsStackView.arrangedSubviews.count != actions.count {
            print("layout activate")
            for (index, action) in actions.enumerated() {
                let actionContainerView = UIView(frame: .zero)
                actionContainerView.translatesAutoresizingMaskIntoConstraints = false
                actionsStackView.addArrangedSubview(actionContainerView)
                
                let labelsView = UIView(frame: .zero)
                labelsView.translatesAutoresizingMaskIntoConstraints = false
                actionContainerView.addSubview(labelsView)
                
                let titleLabel = UILabel(frame: .zero)
                titleLabel.translatesAutoresizingMaskIntoConstraints = false
                titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
                titleLabel.text = action.description
                titleLabel.textColor = Theme().textColor
                titleLabel.numberOfLines = 0
                labelsView.addSubview(titleLabel)
                
                let subtitleLabel = UILabel(frame: .zero)
                subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
                subtitleLabel.font = UIFont.systemFont(ofSize: 11, weight: .medium)
                subtitleLabel.text = getStringForExternalAction(type: action.type!).uppercased()
                subtitleLabel.textColor = Theme().grayTextColor
                subtitleLabel.numberOfLines = 1
                labelsView.addSubview(subtitleLabel)
                
                let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[titleLabel]|", options: .directionLeadingToTrailing, metrics: nil, views: ["titleLabel": titleLabel, "subtitleLabel": subtitleLabel])
                let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[subtitleLabel]-2-[titleLabel]|", options: [.alignAllLeading, .alignAllTrailing], metrics: nil, views: ["titleLabel": titleLabel, "subtitleLabel": subtitleLabel])
                labelsView.addConstraints(hConstraints + vConstraints)
                
                let button = UIButton(frame: .zero)
                button.translatesAutoresizingMaskIntoConstraints = false
                button.tintColor = Theme().grayTextColor
                button.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
                button.setTitle(String(NSLocalizedString("button.view", comment: "button title for view")), for: .normal)
                button.setTitleColor(.white, for: .normal)
                button.setTitleColor(UIColor.white.withAlphaComponent(0.85), for: .highlighted)
                button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
                button.setBackgroundColor(color: Theme().keyTint, forUIControlState: .normal)
                button.setBackgroundColor(color: Theme().keyTintHighlight, forUIControlState: .highlighted)

                button.clipsToBounds = true
                button.layer.cornerRadius = 13
                button.tag = index
                actionContainerView.addSubview(button)
                actionContainerView.addConstraints([
                    NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 26)
                    ])
                
                actionContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-4-[labelsView]-4-|", options: .alignAllLeading, metrics: nil, views: ["labelsView": labelsView]))
                
                actionContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[labelsView]->=18-[button]-18-|", options: .directionLeadingToTrailing, metrics: nil, views: ["labelsView": labelsView, "button": button]))
                
                actionContainerView.addConstraint(NSLayoutConstraint(item: labelsView, attribute: .centerY, relatedBy: .equal, toItem: actionContainerView, attribute: .centerY, multiplier: 1, constant: 0))
                
                actionContainerView.addConstraint(NSLayoutConstraint(item: button, attribute: .centerY, relatedBy: .equal, toItem: titleLabel, attribute: .centerY, multiplier: 1, constant: 0))
                
                NSLayoutConstraint.activate([
                    actionContainerView.widthAnchor.constraint(equalTo: actionsStackView.widthAnchor)
                ])
            }
        }
    }
}
