//
//  PostsPreviewCollectionViewCell.swift
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
import SDWebImage
import Firebase
import DateToolsSwift
import NVActivityIndicatorView

struct Post {
    var author: Person
    var content: PostContent
    var createdAt: Date
    var reference: DocumentReference
    
    init(author: Person, content: PostContent, createdAt: Date, reference: DocumentReference) {
        self.author = author
        self.content = content
        self.createdAt = createdAt
        self.reference = reference
    }
    
    init(dictionary: [String: Any], reference: DocumentReference) {
        let authorDict = dictionary["author"] as! [String: Any]
        self.author = Person(
            displayName: authorDict["name"] as! String,
            photoUrl: authorDict["pic_url"] as? String,
            reference: authorDict["reference"] as? DocumentReference,
            twitter: nil,
            facebook: nil,
            phone: nil,
            isEligibleToReceive: authorDict["type"] != nil,
            recipientType: getEnumForRecipientTypeString(recipientTypeString: authorDict["type"] as? String)
        )
        self.content = PostContent(
            dictionary: dictionary["content"] as! [String: Any]
        )
        self.createdAt = (dictionary["created_date"] as! Timestamp).dateValue()
        self.reference = reference
    }
}

struct PostContent {
    var attachments: [Attachment]?
    var text: String
    
    init(dictionary: [String: Any]) {
        self.attachments = nil
        self.text = dictionary["text"] as! String
    }
}

struct Attachment {
    var url: URL
    var type: AttachmentType
    var name: String
}

enum AttachmentType {
    case Image
    case File
    case Link
}

class PostsPreviewCollectionViewCell: UICollectionViewCell {
    var parentView: UIView!
    var cardView: UIView!
    var postsStackView: UIStackView!
    var posts: [Post]!
    var button: UIButton!
    var emptyStateButton: UIButton?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupParentView()
        setupCardView()
        setupPostsStackView()
    }
    
    private func setupParentView() {
        
        parentView = UIView(frame: .zero)
        parentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(parentView)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[parentView(screenWidth)]|", options: .directionLeadingToTrailing, metrics: ["screenWidth": UIScreen.main.bounds.width], views: ["parentView": parentView]) + NSLayoutConstraint.constraints(withVisualFormat: "V:|[parentView]|", options: .alignAllLeading, metrics: nil, views: ["parentView": parentView]))
        
        let cellHeightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100)
        cellHeightConstraint.priority = .defaultLow
        addConstraint(cellHeightConstraint)
        
    }
    
    private func setupCardView() {
        cardView = UIView(frame: .zero)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.layer.borderColor = Theme().keyTint.withAlphaComponent(0.3).cgColor
        cardView.layer.borderWidth = 1
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 8
        cardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        parentView.addSubview(cardView)
        
        button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(Theme().keyTint, for: .normal)
        button.setTitleColor(Theme().keyTint.withAlphaComponent(0.7), for: .highlighted)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        parentView.addSubview(button)

        
        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[cardView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["cardView": cardView]) + NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[cardView]", options: .alignAllTrailing, metrics: nil, views: ["cardView": cardView]) + NSLayoutConstraint.constraints(withVisualFormat: "H:|->=0-[button]-12-|", options: .directionLeadingToTrailing, metrics: nil, views: ["button": button]))
        
        parentView.addConstraint(NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: cardView, attribute: .bottom, multiplier: 1, constant: 8))
        
        let bottomConstraint = NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal, toItem: parentView, attribute: .bottom, multiplier: 1, constant: -18)
        bottomConstraint.priority = .defaultHigh
        parentView.addConstraint(bottomConstraint)

    }
    
    private func setupPostsStackView() {
        postsStackView = UIStackView(frame: .zero)
        postsStackView.translatesAutoresizingMaskIntoConstraints = false
        postsStackView.axis = .vertical
        postsStackView.alignment = .leading
        postsStackView.spacing = 12
        postsStackView.distribution = .equalSpacing
        cardView.addSubview(postsStackView)
        
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[postsStackView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["postsStackView": postsStackView])
        
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[postsStackView]|", options: .alignAllTrailing, metrics: nil, views: ["postsStackView": postsStackView])
        
        cardView.addConstraints(hConstraints + vConstraints)
    }
    
    func activateStackView() {
            if posts.count > 0 {
                if postsStackView.arrangedSubviews.count != posts.count {
                    for post in posts {
                        let postContainerView = UIView(frame: .zero)
                        postContainerView.translatesAutoresizingMaskIntoConstraints = false
                        postsStackView.addArrangedSubview(postContainerView)
                        
                        postsStackView.addConstraint(NSLayoutConstraint(item: postContainerView, attribute: .width, relatedBy: .equal, toItem: postsStackView, attribute: .width, multiplier: 1, constant: 0)
                        )
                        
                        let subtitleString = "\(post.author.displayName) . \(post.createdAt.timeAgoSinceNow)"
                        
                        let metaLabel = UILabel(frame: .zero)
                        metaLabel.translatesAutoresizingMaskIntoConstraints = false
                        metaLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
                        metaLabel.text = subtitleString
                        metaLabel.textColor = Theme().grayTextColor
                        metaLabel.numberOfLines = 1
                        postContainerView.addSubview(metaLabel)
                        
                        let commentLabel = UILabel(frame: .zero)
                        commentLabel.translatesAutoresizingMaskIntoConstraints = false
                        commentLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
                        commentLabel.text = post.content.text
                        commentLabel.textColor = Theme().textColor
                        commentLabel.numberOfLines = 0
                        postContainerView.addSubview(commentLabel)
                        
                        let separatorView = UIView(frame: .zero)
                        separatorView.translatesAutoresizingMaskIntoConstraints = false
                        separatorView.backgroundColor = Theme().borderColor
                        if let index = posts.index(where: {$0.reference == post.reference}) {
                            separatorView.isHidden = index == posts.count - 1
                        }
                        postContainerView.addSubview(separatorView)

                        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[metaLabel]-18-|", options: .directionLeadingToTrailing, metrics: nil, views: ["metaLabel": metaLabel])
                        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[commentLabel]-[metaLabel]", options: [.alignAllLeading, .alignAllTrailing], metrics: nil, views: ["metaLabel": metaLabel, "commentLabel": commentLabel])
                        
                        let separatorH = NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[separatorView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["separatorView": separatorView])
                        let separatorV = NSLayoutConstraint.constraints(withVisualFormat: "V:[separatorView(1)]|", options: .alignAllTrailing, metrics: nil, views: ["separatorView": separatorView])
                        let separatorConstraint = NSLayoutConstraint(item: separatorView, attribute: .top, relatedBy: .equal, toItem: metaLabel, attribute: .bottom, multiplier: 1, constant: 26)
                        
                        postContainerView.addConstraints(hConstraints + vConstraints + separatorH + separatorV)
                        postContainerView.addConstraint(separatorConstraint)
                    }
                }
            } else {
                if postsStackView.arrangedSubviews.count != 1 {
                    print("no posts")
                    // show empty state
                    let emptyStateView = EmptyStateView(frame: .zero)
                    emptyStateView.translatesAutoresizingMaskIntoConstraints = false
                    emptyStateView.actionButton.setTitle(String(NSLocalizedString("button.participate", comment: "button title for participate action")), for: .normal)
                    self.emptyStateButton = emptyStateView.actionButton
                    postsStackView.addArrangedSubview(emptyStateView)
                    
                    postsStackView.addConstraint(NSLayoutConstraint(item: emptyStateView, attribute: .width, relatedBy: .equal, toItem: postsStackView, attribute: .width, multiplier: 1, constant: 0))
                    postsStackView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[emptyStateView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["emptyStateView": emptyStateView]) + NSLayoutConstraint.constraints(withVisualFormat: "V:|[emptyStateView]|", options: .alignAllCenterX, metrics: nil, views: ["emptyStateView": emptyStateView]))
                }
            }
    }


}
