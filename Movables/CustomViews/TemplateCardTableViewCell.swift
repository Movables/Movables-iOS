//
//  TemplateCardTableViewCell.swift
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

class TemplateCardTableViewCell: UITableViewCell {

    var cardView: MCCard!
    var recipientImageView: UIImageView!
    var recipientLabel: UILabel!
    var destinationLabel: UILabel!
    var headlineLabel: UILabel!
    var descriptionLabel: UILabel!
    var authorLabel: UILabel!
    var usageLabel: UILabel!
    var separatorView: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = .clear
        
        cardView = MCCard(frame: .zero)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)
        
        headlineLabel = UILabel(frame: .zero)
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        headlineLabel.numberOfLines = 0
        headlineLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        headlineLabel.textColor = Theme().grayTextColor
        headlineLabel.text = "Headline"
        contentView.addSubview(headlineLabel)
        
        authorLabel = UILabel(frame: .zero)
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        authorLabel.textColor = Theme().grayTextColor
        authorLabel.numberOfLines = 1
        authorLabel.text = "By Author"
        contentView.addSubview(authorLabel)
        
        usageLabel = UILabel(frame: .zero)
        usageLabel.translatesAutoresizingMaskIntoConstraints = false
        usageLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        usageLabel.numberOfLines = 1
        usageLabel.textColor = Theme().grayTextColor
        usageLabel.text = "Used in 30 packages"
        usageLabel.textAlignment = .right
        contentView.addSubview(usageLabel)
        
        descriptionLabel = UILabel(frame: .zero)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.numberOfLines = 5
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        contentView.addSubview(descriptionLabel)
        
        recipientImageView = UIImageView(frame: .zero)
        recipientImageView.translatesAutoresizingMaskIntoConstraints = false
        recipientImageView.contentMode = .scaleAspectFill
        recipientImageView.layer.cornerRadius = 24
        recipientImageView.clipsToBounds = true
        contentView.addSubview(recipientImageView)
        
        recipientLabel = UILabel(frame: .zero)
        recipientLabel.translatesAutoresizingMaskIntoConstraints = false
        recipientLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        recipientLabel.textColor = Theme().grayTextColor
        recipientLabel.numberOfLines = 1
        recipientLabel.text = "Ke Wen-Jie"
        contentView.addSubview(recipientLabel)
        
        destinationLabel = UILabel(frame: .zero)
        destinationLabel.translatesAutoresizingMaskIntoConstraints = false
        destinationLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        destinationLabel.numberOfLines = 0
        destinationLabel.textColor = Theme().grayTextColor
        destinationLabel.text = "Taipei City Hall"
        contentView.addSubview(destinationLabel)
        
        separatorView = UIView(frame: .zero)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = Theme().borderColor
        contentView.addSubview(separatorView)
        
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),
            recipientImageView.heightAnchor.constraint(equalToConstant: 48),
            recipientImageView.widthAnchor.constraint(equalToConstant: 48),
            recipientImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            recipientImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 24),
            recipientLabel.topAnchor.constraint(equalTo: recipientImageView.topAnchor, constant: 8),
            recipientLabel.leadingAnchor.constraint(equalTo: recipientImageView.trailingAnchor, constant: 8),
            recipientLabel.trailingAnchor.constraint(lessThanOrEqualTo: cardView.trailingAnchor, constant: -18),
            destinationLabel.leadingAnchor.constraint(equalTo: recipientLabel.leadingAnchor),
            destinationLabel.trailingAnchor.constraint(lessThanOrEqualTo: cardView.trailingAnchor, constant: -18),
            destinationLabel.topAnchor.constraint(equalTo: recipientLabel.bottomAnchor, constant: 2),
            headlineLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            headlineLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),
            headlineLabel.topAnchor.constraint(equalTo: recipientImageView.bottomAnchor, constant: 18),
            descriptionLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 6),
            descriptionLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            descriptionLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            separatorView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            separatorView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 18),
            authorLabel.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 12),
            authorLabel.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor),
            authorLabel.trailingAnchor.constraint(lessThanOrEqualTo: cardView.trailingAnchor, constant: -18),
            authorLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -18),
            usageLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),
            usageLabel.centerYAnchor.constraint(equalTo: authorLabel.centerYAnchor),
        ])
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
