//
//  ProfileViewController.swift
//  Movables
//
//  Created by Eddie Chen on 6/1/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

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
    
    var userDoc: UserDocument?
    var accountActivities: [AccountActivity] = []
    
    var tableView: UITableView!
    
    var activityIndicatorView: NVActivityIndicatorView!
    
    var delegate: ProfileViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        setupTableView()
        
        fetchUserDoc(uid: Auth.auth().currentUser!.uid) { (userDoc) in
            if userDoc != nil {
                self.userDoc = userDoc
                self.fetchAccountActivities(userDoc: self.userDoc!, completion: { (success, accountActivities) in
                    if success {
                        self.accountActivities = accountActivities!
                        self.activityIndicatorView?.stopAnimating()
                        self.tableView.reloadData()
                    } else {
                        print("error loading account activities")
                    }
                })
            }
        }

    }
    
    private func fetchAccountActivities(userDoc: UserDocument, completion: @escaping (Bool, [AccountActivity]?) -> ()) {
        userDoc.reference.collection("account_activities").order(by: "date", descending: true).limit(to: 10).getDocuments { (querySnapshot, error) in
            if let error = error {
                print(error)
                completion(false, nil)
            } else if let snapshot = querySnapshot {
                var accountActivities:[AccountActivity] = []
                snapshot.documents.forEach({ (docSnapshot) in
                    accountActivities.append(AccountActivity(with: docSnapshot.data()))
                })
                completion(true, accountActivities)
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
        tableView.register(ProfileActionsTableViewCell.self, forCellReuseIdentifier: "profileActions")
        tableView.register(RowButtonTableViewCell.self, forCellReuseIdentifier: "buttonRow")
        tableView.register(EventActivityTableViewCell.self, forCellReuseIdentifier: "eventActivity")
        tableView.dataSource = self
        view.addSubview(tableView)
        
        activityIndicatorView = NVActivityIndicatorView(frame: .zero, type: .ballScale, color: Theme().textColor, padding: 0)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.startAnimating()
        tableView.backgroundView = activityIndicatorView
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            activityIndicatorView.heightAnchor.constraint(equalToConstant: 50),
            activityIndicatorView.widthAnchor.constraint(equalToConstant: 50),
        ])
    }
}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.userDoc != nil {
            return 1 + self.accountActivities.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "profileFace") as! ProfileFaceTableViewCell
            cell.nameLabel.text = userDoc?.publicProfile.displayName
            cell.profilePicImageView.sd_setImage(with: URL(string: self.userDoc!.publicProfile.picUrl!)) { (image, error, cacheType, url) in
                print("loaded image")
            }
            cell.accessoryButton.setImage(UIImage(named: "profile_settings"), for: .normal)
            cell.secondaryButton.setImage(UIImage(named: "profile_edit"), for: .normal)
            cell.accessoryButton.addTarget(self, action: #selector(didTapOnSettings(sender:)), for: .touchUpInside)
            cell.secondaryButton.addTarget(self, action: #selector(didTapOnEdit(sender:)), for: .touchUpInside)
            cell.balanceLabel.text = "\(Int(userDoc!.privateProfile.timeBankBalance))"
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            cell.journeyLabel.text = "Since \(dateFormatter.string(from: userDoc!.publicProfile.createdDate))"
            var interestsString: String = ""
            for interest in userDoc!.privateProfile.interests {
               interestsString += getEmojiForCategory(category: interest)
            }
            cell.interestsLabel.text = interestsString
            return cell
        default:
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
        alertController.addAction(UIAlertAction(title: "Notifications", style: .default, handler: { (action) in
            print("go to notifications")
        }))
        alertController.addAction(UIAlertAction(title: "Privacy Policy", style: .default, handler: { (action) in
            print("go to privacy policy")
            self.navigationController?.present(SFSafariViewController(url: URL(string: "https://www.google.com")!), animated: true)
        }))
        alertController.addAction(UIAlertAction(title: "Signout", style: .default, handler: { (action) in
            print("signout")
            let alertVC = UIAlertController(title: "Signout", message: "Are you sure you want to signout?", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Signout", style: .default, handler: { (action) in
                do {
                    try Auth.auth().signOut()
                    GIDSignIn.sharedInstance().signOut()
                    FBSDKLoginManager().logOut()
                    
                    print("did sign out")
                    self.mainCoordinatorDelegate?.coordinatorDidSignout(coordinator: self.mainCoordinator!)
                } catch let error { print(error) }
            }))
            alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                print("canceled signout")
            }))
            self.present(alertVC, animated: true) {
                print("presented signout prompt")
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            print("cancel")
        }))

        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func didTapOnEdit(sender: UIButton) {
        print("did tap on edit")
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
