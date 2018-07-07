//
//  SelfActivityTableViewCell.swift
//  Movables
//
//  Created by Eddie Chen on 6/26/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class EventActivityTableViewCell: UITableViewCell {
    
    var graphicContainerView: UIView!
    var supplementLabelContainerView: UIView!
    var supplementLabel: UILabel!
    var graphicImageView: UIImageView!
    var dateLabel: UILabel!
    var eventLabel: TTTAttributedLabel!
    var separatorView: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        graphicContainerView = UIView(frame: .zero)
        graphicContainerView.translatesAutoresizingMaskIntoConstraints = false
        graphicContainerView.backgroundColor = .white
        graphicContainerView.layer.borderColor = Theme().grayTextColor.cgColor
        graphicContainerView.layer.borderWidth = 1
        graphicContainerView.layer.cornerRadius = 25
        graphicContainerView.clipsToBounds = true
        contentView.addSubview(graphicContainerView)
        
        supplementLabelContainerView = UIView(frame: .zero)
        supplementLabelContainerView.translatesAutoresizingMaskIntoConstraints = false
        supplementLabelContainerView.layer.cornerRadius = 4
        supplementLabelContainerView.clipsToBounds = true
        contentView.addSubview(supplementLabelContainerView)
        
        supplementLabel = UILabel(frame: .zero)
        supplementLabel.translatesAutoresizingMaskIntoConstraints = false
        supplementLabel.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        supplementLabel.textColor = .white
        supplementLabel.textAlignment = .center
        supplementLabel.numberOfLines = 1
        supplementLabelContainerView.addSubview(supplementLabel)
        
        graphicImageView = UIImageView(frame: .zero)
        graphicImageView.translatesAutoresizingMaskIntoConstraints = false
        graphicImageView.contentMode = .scaleAspectFit
        graphicImageView.tintColor = Theme().grayTextColor
        contentView.addSubview(graphicImageView)
        
        dateLabel = UILabel(frame: .zero)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        dateLabel.textColor = Theme().grayTextColorHighlight
        dateLabel.numberOfLines = 1
        dateLabel.text = "time ago"
        contentView.addSubview(dateLabel)

        
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
        contentView.addSubview(eventLabel)
        
        separatorView = UIView(frame: .zero)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = Theme().borderColor
        contentView.addSubview(separatorView)
        
        NSLayoutConstraint.activate([
            graphicContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            graphicContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            graphicContainerView.bottomAnchor.constraint(lessThanOrEqualTo: separatorView.topAnchor, constant: -20),
            graphicContainerView.widthAnchor.constraint(equalToConstant: 50),
            graphicContainerView.heightAnchor.constraint(equalToConstant: 50),
            supplementLabelContainerView.trailingAnchor.constraint(equalTo: graphicContainerView.trailingAnchor, constant: 6),
            supplementLabelContainerView.centerYAnchor.constraint(equalTo: graphicContainerView.bottomAnchor),
            supplementLabel.leadingAnchor.constraint(equalTo: supplementLabelContainerView.leadingAnchor, constant: 6),
            supplementLabel.trailingAnchor.constraint(equalTo: supplementLabelContainerView.trailingAnchor, constant: -6),
            supplementLabel.topAnchor.constraint(equalTo: supplementLabelContainerView.topAnchor, constant: 4),
            supplementLabel.bottomAnchor.constraint(equalTo: supplementLabelContainerView.bottomAnchor, constant: -4),
            graphicImageView.leadingAnchor.constraint(equalTo: graphicContainerView.leadingAnchor),
            graphicImageView.trailingAnchor.constraint(equalTo: graphicContainerView.trailingAnchor),
            graphicImageView.topAnchor.constraint(equalTo: graphicContainerView.topAnchor),
            graphicImageView.bottomAnchor.constraint(equalTo: graphicContainerView.bottomAnchor),
            eventLabel.topAnchor.constraint(equalTo: graphicContainerView.topAnchor, constant: 4),
            eventLabel.leadingAnchor.constraint(equalTo: graphicImageView.trailingAnchor, constant: 18),
            eventLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            dateLabel.bottomAnchor.constraint(lessThanOrEqualTo: separatorView.bottomAnchor, constant: -20),
            dateLabel.leadingAnchor.constraint(equalTo: eventLabel.leadingAnchor),
            dateLabel.topAnchor.constraint(equalTo: eventLabel.bottomAnchor, constant: 6),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureWithActivityType(type: ActivityType) {
        let image:UIImage?
        switch type {
        case .packageDelivery:
            image = UIImage(named: "ActivityType--packageDelivery")
        case .packageDropoff:
            image = UIImage(named: "ActivityType--packageDropoff")
        case .packagePickup:
            image = UIImage(named: "ActivityType--packagePickup")
        case .packageCreation:
            image = UIImage(named: "ActivityType--packageCreation")
        case .templateCreation:
            image = UIImage(named: "ActivityType--templateCreation")
        case .templateUsage:
            image = UIImage(named: "ActivityType--templateUsage")
        default:
            image = UIImage(named: "ActivityType--unknown")
        }
        graphicImageView.image = image
    }

}
