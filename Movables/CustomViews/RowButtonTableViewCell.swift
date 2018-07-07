//
//  RowButtonTableViewCell.swift
//  Movables
//
//  Created by Eddie Chen on 6/22/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit

class RowButtonTableViewCell: UITableViewCell {

    var button: UIButton!
    var separatorView: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        backgroundColor = .white
        
        button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.setTitleColor(Theme().keyTint, for: .normal)
        button.setTitleColor(Theme().keyTintHighlight, for: .highlighted)
        contentView.addSubview(button)
        
        separatorView = UIView(frame: .zero)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = Theme().borderColor
        contentView.addSubview(separatorView)
        
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 10),
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            button.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -18),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            separatorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
