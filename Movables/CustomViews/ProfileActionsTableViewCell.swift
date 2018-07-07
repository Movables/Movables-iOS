//
//  ProfileActionsTableViewCell.swift
//  Movables
//
//  Created by Eddie Chen on 6/22/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit

class ProfileActionsTableViewCell: UITableViewCell {

    var stackView: UIStackView!
    var userDoc: UserDocument?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = .white
        
        setupStackView()
    }
    
    private func setupStackView() {
        stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func activateStackView() {
        let balanceActionView = StackViewIconTextActionView(frame: .zero)
        balanceActionView.translatesAutoresizingMaskIntoConstraints = false
        balanceActionView.iconImageView.image = UIImage(named: "action_account_balance")
        balanceActionView.textLabel.text = "\(Int(userDoc!.privateProfile.timeBankBalance)) Credits"
        stackView.addArrangedSubview(balanceActionView)
        
        let movedActionView = StackViewIconTextActionView(frame: .zero)
        movedActionView.translatesAutoresizingMaskIntoConstraints = false
        movedActionView.iconImageView.image = UIImage(named: "action_packages_moved")
        movedActionView.textLabel.text = "\(userDoc!.publicProfile.count.packagesMoved) Moved"
        stackView.addArrangedSubview(movedActionView)
        
//        let createdActionView = StackViewIconTextActionView(frame: .zero)
//        createdActionView.translatesAutoresizingMaskIntoConstraints = false
//        createdActionView.iconImageView.image = UIImage(named: "action_packages_created")
//        createdActionView.textLabel.text = "\(userDoc!.publicProfile.count.packagesFollowing)"
//        stackView.addArrangedSubview(createdActionView)
    }

}
