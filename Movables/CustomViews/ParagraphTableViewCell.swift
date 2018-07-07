//
//  ParagraphTableViewCell.swift
//  Movables
//
//  Created by Chun-Wei Chen on 7/2/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit

class ParagraphTableViewCell: UITableViewCell {

    var label: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        label.numberOfLines = 0
        contentView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 18),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -18),
        ])

    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
