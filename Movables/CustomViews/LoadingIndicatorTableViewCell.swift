//
//  LoadingIndicatorTableViewCell.swift
//  Movables
//
//  Created by Eddie Chen on 7/27/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class LoadingIndicatorTableViewCell: UITableViewCell {

    var activityIndicator: NVActivityIndicatorView!
    var label: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = .clear
        
        activityIndicator = NVActivityIndicatorView(frame: .zero, type: .ballScale, color: Theme().textColor, padding: 0)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(activityIndicator)
        
        label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = Theme().grayTextColor
        label.isHidden = true
        contentView.addSubview(label)
        
        NSLayoutConstraint.activate([
            activityIndicator.heightAnchor.constraint(equalToConstant: 30),
            activityIndicator.widthAnchor.constraint(equalToConstant: 30),
            activityIndicator.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            activityIndicator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -6),
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
