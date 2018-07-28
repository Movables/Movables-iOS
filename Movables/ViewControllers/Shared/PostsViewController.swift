//
//  PostsViewController.swift
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
import SlackTextViewController
import Firebase

class PostsViewController: SLKTextViewController {
    
    var reference: DocumentReference!
    var referenceType: CommunityType!
    var isOpen: Bool = false
    var posts: [Post]?
    var listener: ListenerRegistration?
    var emptyStateView: EmptyStateView!
    var commentsReference: CollectionReference?
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    override init?(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        title = isOpen ? String(NSLocalizedString("headerCollectionCell.public_conversation", comment: "navigation bar title for public conversation")) : String(NSLocalizedString("navBar.conversation", comment: "navigation bar title for conversation"))
        
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.alwaysBounceVertical = true
        collectionView?.contentInsetAdjustmentBehavior = .never
        collectionView?.contentInset.top = 35
        collectionView?.backgroundColor = .white
        let layout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: 120)
        layout.itemSize = UICollectionViewFlowLayoutAutomaticSize
        
        collectionView?.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: "postCell")
        collectionView?.register(ActivityIndicatorCollectionViewCell.self, forCellWithReuseIdentifier: "loadingViewCell")
        
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        
        textInputbar.rightButton.setTitle(String(NSLocalizedString("button.send", comment: "button title for send")), for: .normal)
        textInputbar.autoHideRightButton = false
        textInputbar.isTranslucent = false
        textInputbar.textView.placeholder = String(NSLocalizedString("label.saySomething", comment: "label text for say something"))
        
        let moreButton = UIBarButtonItem(image: UIImage(named: "round_more_black_24pt"), style: .plain, target: self, action: #selector(didTapMoreButton(sender:)))
        navigationItem.rightBarButtonItem = moreButton
        
        emptyStateView = EmptyStateView(frame: .zero)
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.isHidden = true
        emptyStateView.transform = self.collectionView!.transform
        emptyStateView.actionButton.isHidden = true
        collectionView?.addSubview(emptyStateView)
        
        collectionView?.addConstraint(NSLayoutConstraint(item: emptyStateView, attribute: .width, relatedBy: .equal, toItem: collectionView, attribute: .width, multiplier: 1, constant: 0))
        collectionView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[emptyStateView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["emptyStateView": emptyStateView]) + NSLayoutConstraint.constraints(withVisualFormat: "V:[emptyStateView]", options: .alignAllCenterX, metrics: nil, views: ["emptyStateView": emptyStateView]))
            collectionView?.addConstraints([
                NSLayoutConstraint(item: emptyStateView, attribute: .centerX, relatedBy: .equal, toItem: collectionView, attribute: .centerX, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: emptyStateView, attribute: .centerY, relatedBy: .equal, toItem: collectionView, attribute: .centerY, multiplier: 1, constant: 0)
                ])
        
        // attach listener on public comments
        self.commentsReference = isOpen ? self.reference.collection("open_comments") : reference.collection("comments")

        listenToPosts()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // detach listener on public comments
        self.listener?.remove()
    }
    
    @objc private func didTapMoreButton(sender: UIBarButtonItem) {
        print("tapped more")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func listenToPosts() {
        self.commentsReference!.order(by: "created_date", descending: true).getDocuments { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error?.localizedDescription)")
                return
            }
            var postsTemp:[Post] = []
            for document in snapshot.documents {
                postsTemp.append(Post(dictionary: document.data(), reference: document.reference))
            }
            self.posts = postsTemp
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0, animations: {
                    self.collectionView?.reloadData()
                    if self.posts != nil && self.posts!.count > 0 {
                        self.emptyStateView.isHidden = true
                    } else {
                        self.emptyStateView.isHidden = false
                    }
                })
            }
            self.listener = self.commentsReference!.order(by: "created_date", descending: true).addSnapshotListener { (querySnapshot, error) in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error?.localizedDescription)")
                    return
                }
                var newPosts:[Post] = []
                snapshot.documentChanges.forEach { diff in
                    if (diff.type == .added) {
                        if self.posts?.index(where: { $0.reference == diff.document.reference}) != nil {
                        } else {
                            newPosts.append(Post(dictionary: diff.document.data(), reference: diff.document.reference))
                        }
                        print("added")
                    }
                    if (diff.type == .modified) {
                        if let index = self.posts?.index(where: { $0.reference == diff.document.reference}) {
                            self.posts?[index] = Post(dictionary: diff.document.data(), reference: diff.document.reference)
                            print("Modified")
                        }
                    }
                    if (diff.type == .removed) {
                        if let index = self.posts?.index(where: { $0.reference == diff.document.reference}) {
                            self.posts?.remove(at: index)
                            print("Removed")
                        }
                    }
                }
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0, animations: {
                        self.posts?.insert(contentsOf: newPosts, at: 0)
                        self.collectionView?.reloadData()
                        if self.posts != nil && self.posts!.count > 0 {
                            self.emptyStateView.isHidden = true
                        } else {
                            self.emptyStateView.isHidden = false
                        }
                    })
                }
            }
        }
    }
    
    override func didPressRightButton(_ sender: Any?) {
        let postData: [String: Any] = [
            "author": [
                "name": Auth.auth().currentUser?.displayName ?? "",
                "pic_url": Auth.auth().currentUser?.photoURL?.absoluteString ?? "",
                "reference": Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid)
            ],
            "content": [
                "attachments": nil,
                "text": self.textView.text
            ],
            "created_date": Date()
        ]
        self.textView.text = ""
        self.commentsReference!.addDocument(data: postData) { (error) in
            if let error = error {
                print(error)
            } else {
                print("saved new public comment")
            }
        }
        reference.updateData([
                "participants.\(Auth.auth().currentUser!.uid)": Date()
            ]) { (error) in
            if let error = error {
                print(error)
            } else {
                print("added current user as conversation participant")
            }
        }
        
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if posts != nil {
            if posts!.count > 0 {
                return posts!.count
            } else {
                return 0
            }
        } else {
            return 1
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if posts != nil {
            if posts!.count > 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postCell", for: indexPath) as! PostCollectionViewCell
                let post = posts![indexPath.item]
                let subtitleString = "\(post.author.displayName) . \(post.createdAt.timeAgoSinceNow)"
                cell.commentLabel.text = post.content.text
                cell.metaLabel.text = subtitleString
                cell.parentView.transform = self.collectionView!.transform
                if let photoUrl = post.author.photoUrl {
                    cell.profileImageView.sd_setImage(with: URL(string: photoUrl)) { (image, error, cacheType, url) in
                        print("loaded author")
                    }
                }
                cell.separatorView.isHidden = indexPath.item == 0
                return cell
            } else {
                return UICollectionViewCell()
            }
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "loadingViewCell", for: indexPath) as! ActivityIndicatorCollectionViewCell
            cell.activityIndicatorView.startAnimating()
            return cell
        }
    }
}
