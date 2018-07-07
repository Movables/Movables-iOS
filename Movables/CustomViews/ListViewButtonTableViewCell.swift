//
//  ListViewButtonTableViewCell.swift
//  Movables
//
//  Created by Eddie Chen on 6/20/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit

class ListViewButtonTableViewCell: UITableViewCell {

    var button: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = .clear
        
        button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = Theme().borderColor.cgColor
        button.setTitle("Button", for: .normal)
        button.setBackgroundColor(color: .white, forUIControlState: .normal)
        button.setBackgroundColor(color: Theme().borderColor, forUIControlState: .highlighted)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.setTitleColor(Theme().textColor, for: .normal)
        contentView.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 50),
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),
        ])

    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
