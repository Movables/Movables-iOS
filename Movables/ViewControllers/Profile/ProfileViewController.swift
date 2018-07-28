//
//  ProfileViewController.swift
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
import GoogleSignIn
import FBSDKLoginKit
import Firebase
import NVActivityIndicatorView
import TTTAttributedLabel
import SafariServices

protocol ProfileViewControllerDelegate {
    func showPackageDetail(with packageId:String, and headline:String)
}

class ProfileViewController: UIViewController {

    var mainCoordinator: MainCoordinator!
    var mainCoordinatorDelegate: MainCoordinatorDelegate!
    
    var navBarIsTransparent: Bool = true
    
    var userDocument: UserDocument? {
        didSet {
            if userDocument != nil {
                self.query = userDocument!.reference.collection("account_activities").order(by: "date", descending: true)
                self.fetchAccountActivities()
            }
        }
    }
    var accountActivities: [AccountActivity] = []
    var documents: [QueryDocumentSnapshot] = []
    
    var query: Query!
    
    var noMoreAccountActivities = false
    var queryInProgress = false
    
    var tableView: UITableView!
    var refreshControl: UIRefreshControl!
    
    var delegate: ProfileViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        setupTableView()
        
        userDocument = UserManager.shared.userDocument
        NotificationCenter.default.addObserver(self, selector: #selector(userDocumentUpdated(notification:)), name: Notification.Name.currentUserDocumentUpdated, object: nil)
    }
    
    @objc private func userDocumentUpdated(notification: Notification) {
        self.userDocument = (notification.userInfo as! [String: Any])["userDocument"] as? UserDocument
        print("received notification and set userDocument")
    }
    
    private func fetchAccountActivities() {
        if !queryInProgress {
            queryInProgress = true
            self.noMoreAccountActivities = false
            query.limit(to: 10).getDocuments { (snapshot, error) in
                guard let snapshot = snapshot else {
                    print("error retrieving account activities: \(error.debugDescription)")
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                    self.queryInProgress = false
                    return
                }
                guard snapshot.documents.last != nil else {
                    self.noMoreAccountActivities = true
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                    self.queryInProgress = false
                    return
                }
                
                self.accountActivities.removeAll()
                self.documents.removeAll()
                self.documents.append(contentsOf: snapshot.documents)
                
                var accountActivities:[AccountActivity] = []
                snapshot.documents.forEach({ (docSnapshot) in
                    accountActivities.append(AccountActivity(with: docSnapshot.data()))
                })
                self.accountActivities.append(contentsOf: accountActivities)
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
                self.queryInProgress = false
            }
        }
    }
    
    private func fetchMoreAccountActivities() {
        if let lastDocument = self.documents.last {
            if !self.queryInProgress {
                self.queryInProgress = true
                query.start(afterDocument: lastDocument).limit(to: 10).getDocuments { (snapshot, error) in
                    guard let snapshot = snapshot else {
                        print("error retrieiving more account activities:\(error.debugDescription)")
                        self.queryInProgress = false
                        return
                    }
                    guard snapshot.documents.last != nil else {
                        // no more account activities
                        self.noMoreAccountActivities = true
                        print("no more account activities")
                        if let cell = self.tableView.cellForRow(at: IndexPath(row: self.accountActivities.count + 1, section: 0)) as? LoadingIndicatorTableViewCell {
                            cell.activityIndicator.stopAnimating()
                            cell.label.isHidden = false
                        }
                        self.queryInProgress = false
                        return
                    }
                    var accountActivities:[AccountActivity] = []
                    let startingRow = self.accountActivities.count + 1
                    var indexPathsToInsert:[IndexPath] = []
                    self.documents.append(contentsOf: snapshot.documents)
                    for (index, docSnapshot) in snapshot.documents.enumerated() {
                        accountActivities.append(AccountActivity(with: docSnapshot.data()))
                        indexPathsToInsert.append(IndexPath(row: startingRow + index, section: 0))
                    }
                    self.accountActivities.append(contentsOf: accountActivities)
                    indexPathsToInsert.append(IndexPath(row: self.accountActivities.count + 1, section: 0))

                    DispatchQueue.main.async {
                        self.tableView.beginUpdates()
                        self.tableView.deleteRows(at: [IndexPath(row: startingRow, section: 0)], with: .none)
                        self.tableView.insertRows(at: indexPathsToInsert, with: .none)
                        self.tableView.endUpdates()
                    }
                    self.queryInProgress = false
                    
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 250
        tableView.separatorStyle = .none
        tableView.register(ProfileFaceTableViewCell.self, forCellReuseIdentifier: "profileFace")
        tableView.register(EventActivityTableViewCell.self, forCellReuseIdentifier: "eventActivity")
        tableView.register(LoadingIndicatorTableViewCell.self, forCellReuseIdentifier: "loadingCell")
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didRefresh(sender:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    @objc private func didRefresh(sender: UIRefreshControl) {
        sender.beginRefreshing()
        fetchAccountActivities()
    }
}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.userDocument != nil {
            return 1 + self.accountActivities.count + 1
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.userDocument == nil && indexPath.row == 0) || self.userDocument != nil && indexPath.row == self.accountActivities.count + 1 {
            // loading indicator cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell") as! LoadingIndicatorTableViewCell
            cell.label.text = String(NSLocalizedString("copy.noMoreAccountActivities", comment: "label for no more account activities"))
            if noMoreAccountActivities {
                cell.activityIndicator.stopAnimating()
                cell.label.isHidden = false
            } else {
                cell.activityIndicator.startAnimating()
                cell.label.isHidden = true
            }
            return cell
        } else if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "profileFace") as! ProfileFaceTableViewCell
            cell.nameLabel.text = userDocument!.publicProfile.displayName
            cell.profilePicImageView.sd_setImage(with: URL(string: self.userDocument!.publicProfile.picUrl!)) { (image, error, cacheType, url) in
                print("loaded image")
            }
            cell.accessoryButton.setImage(UIImage(named: "profile_settings"), for: .normal)
            cell.secondaryButton.setImage(UIImage(named: "profile_edit"), for: .normal)
            cell.accessoryButton.addTarget(self, action: #selector(didTapOnSettings(sender:)), for: .touchUpInside)
            cell.secondaryButton.addTarget(self, action: #selector(didTapOnEdit(sender:)), for: .touchUpInside)
            cell.balanceLabel.text = "\(Int(userDocument!.privateProfile.pointsBalance))"
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            cell.journeyLabel.text = String(format: NSLocalizedString("label.sinceDate", comment: "label text for since date"), dateFormatter.string(from: userDocument!.publicProfile.createdDate))
            var interestsString: String = ""
            for interest in userDocument!.privateProfile.interests {
               interestsString += getEmojiForCategory(category: interest)
            }
            cell.interestsLabel.text = interestsString
            return cell
        } else {
            // activity row
            let cell = tableView.dequeueReusableCell(withIdentifier: "eventActivity") as! EventActivityTableViewCell
            let activity = self.accountActivities[indexPath.row - 1]
            let eventText = generateLabelTextForAccountActivity(accountActivity: activity)
            cell.eventLabel.text = eventText
            let eventTextNSString = eventText as NSString
            let range: NSRange?
            let url: URL?
            if activity.type == .templateCreation {
                url = URL(string: "templates/\(activity.objectReference.documentID)/\(activity.objectName)".addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)
                range = eventTextNSString.range(of: "#\(activity.objectName)")
            }
            else if activity.type == .templateUsage {
                url = URL(string: "templates/\(activity.objectReference.documentID)/\(activity.objectName)".addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)
                range = eventTextNSString.range(of: "\(activity.objectName)")
            } else {
                url = URL(string: "packages/\(activity.objectReference.documentID)/\(activity.objectName)".addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)
                range = eventTextNSString.range(of: activity.objectName)
            }
            
            cell.configureWithActivityType(type: activity.type)
            cell.eventLabel.addLink(to: url, with: range!)
            cell.eventLabel.delegate = self

            cell.supplementLabel.text = "\(activity.amount >= 0 ? "+" : "")\(activity.amount)"
            cell.supplementLabelContainerView.backgroundColor = activity.amount >= 0 ? Theme().keyTint : Theme().mapStampTint
            cell.dateLabel.text = activity.date.timeAgoSinceNow
            return cell
        }
    }
    
    @objc private func didTapNotifications(sender: UIButton) {
        print("did tap notifications")
    }
    
    @objc private func didTapPrivacyPolicy(sender: UIButton) {
        print("did tap privacy policy")
    }
    
    @objc private func didTapSupport(sender: UIButton) {
        print("did tap support")
    }
    
    @objc private func didTapAbout(sender: UIButton) {
        print("did tap abuot")
    }
    
    @objc private func didTapOnSettings(sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: String(NSLocalizedString("button.notifications", comment: "button title for notifications")), style: .default, handler: { (action) in
            print("go to notifications")
        }))
        alertController.addAction(UIAlertAction(title: String(NSLocalizedString("button.privacyPolicy", comment: "button title for privacy policy")), style: .default, handler: { (action) in
            print("go to privacy policy")
            self.navigationController?.present(SFSafariViewController(url: URL(string: "https://movables.app/privacy.html")!), animated: true)
        }))
        alertController.addAction(UIAlertAction(title: String(NSLocalizedString("button.signout", comment: "button title for signout")), style: .default, handler: { (action) in
            print("signout")
            let alertVC = UIAlertController(title: String(NSLocalizedString("copy.alert.signout", comment: "alert body for signout")), message: nil, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: String(NSLocalizedString("button.signout", comment: "button title for signout")), style: .default, handler: { (action) in
                do {
                    try Auth.auth().signOut()
                    UserManager.shared.stopListening()
                    GIDSignIn.sharedInstance().signOut()
                    FBSDKLoginManager().logOut()
                    
                    print("did sign out")
                    self.mainCoordinatorDelegate?.coordinatorDidSignout(coordinator: self.mainCoordinator!)
                } catch let error { print(error) }
            }))
            alertVC.addAction(UIAlertAction(title: String(NSLocalizedString("button.cancel", comment: "button title for cancel")), style: .cancel, handler: { (action) in
                print("canceled signout")
            }))
            self.present(alertVC, animated: true) {
                print("presented signout prompt")
            }
        }))
        alertController.addAction(UIAlertAction(title: String(NSLocalizedString("button.cancel", comment: "button title for cancel")), style: .cancel, handler: { (action) in
            print("cancel")
        }))

        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func didTapOnEdit(sender: UIButton) {
        print("did tap on edit")
    }

}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.tableView.numberOfRows(inSection: 0) - 1 && !queryInProgress && !noMoreAccountActivities {
            fetchMoreAccountActivities()
        }
    }
}

extension ProfileViewController: TTTAttributedLabelDelegate {
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        let decodedString = url.absoluteString.removingPercentEncoding!
        let parameters = decodedString.split(separator: "/")
        let key = String(parameters[0])
        let value = String(parameters[1])
        if key == "packages" {
            let headline = String(parameters[2])
            delegate?.showPackageDetail(with: value, and: headline)
        }
    }
}
