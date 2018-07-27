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
        
        NSLayoutConstraint.activate([
            activityIndicator.heightAnchor.constraint(equalToConstant: 50),
            activityIndicator.widthAnchor.constraint(equalToConstant: 50),
            activityIndicator.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            activityIndicator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
