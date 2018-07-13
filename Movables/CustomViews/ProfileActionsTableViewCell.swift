//
//  ProfileActionsTableViewCell.swift
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
