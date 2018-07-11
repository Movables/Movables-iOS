//
//  PackageDetailViewController.swift
//  Movables
//
//  Created by Eddie Chen on 5/20/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import NVActivityIndicatorView

protocol PackageDetailViewControllerDelegate {
    func dismissPackageDetailVC()
    func showPostsVC()
    func presentDropoffSummary(with package: Package, response: [String: Any])
    func showMapRouteVC(for package: Package)
}

class PackageDetailViewController: UIViewController {
    
    let ACTIONABLE_DISTANCE = 100.0
    let TOO_FAR_DISTANCE = 50000.0
    
    var packagePreview:PackagePreview!
    var headline: String!
    var tagName: String!
    var packageDocumentId: String!
    
    var package: Package? {
        didSet {
            self.listenToTransitRecords()
        }
    }
    var posts: [Post]? {
        didSet {
            if package != nil {
                reloadCollectionView()
            }
        }
    }
    
    var packagesFollowing: [PackageFollowing] = []
    
    var delegate: PackageDetailViewControllerDelegate?
    var navBarIsTransparent: Bool = true
    var showAllDescription: Bool = false {
        didSet {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0, animations: {
                    self.collectionView.reloadData()
                })
            }
        }
    }
    var deliveryRouteDrawn: Bool = false
    var fetchedTransitRecords: Bool = false
    
    var transitRecords: [TransitRecord]? {
        didSet {
            if posts != nil {
                reloadCollectionView()
            }
            self.newUpdatePackageActionButton(with: LocationManager.shared.location)
        }
    }
    var userAlreadyMovedPackage: Bool?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var floatingButtonsContainerView: UIView!
    var followButtonBaseView: UIView!
    var followButton: UIButton!
    var followButtonActivityIndicatorView: NVActivityIndicatorView!
    var packageActionButtonBaseView: UIView!
    var packageActionButton: UIButton!
    var packageActionButtonActivityIndicatorView: NVActivityIndicatorView!
    var bottomConstraintFAB: NSLayoutConstraint!
    
    var followStatusListener: ListenerRegistration?
    var packageDataListener: ListenerRegistration?
    var packageTransitRecordsListener: ListenerRegistration?
    
    let buttonDistanceLeftformatter = MeasurementFormatter()
    
    var alreadyMoving: Bool = true
    
    var categoryTint: UIColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.titleView = TitleView(frame: .zero, title: self.headline, subtitle: "#\(self.tagName!)")
        navigationItem.titleView?.isHidden = true
        
        buttonDistanceLeftformatter.unitStyle = .short
        buttonDistanceLeftformatter.unitOptions = .naturalScale
        buttonDistanceLeftformatter.numberFormatter.maximumIntegerDigits = 3
        buttonDistanceLeftformatter.numberFormatter.maximumFractionDigits = 0
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 9 / 16 + UIApplication.shared.keyWindow!.safeAreaInsets.top)
        
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: 100)
        layout.itemSize = UICollectionViewFlowLayoutAutomaticSize
        
        floatingButtonsContainerView = UIView(frame: .zero)
        floatingButtonsContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(floatingButtonsContainerView)
        
        followButtonBaseView = UIView(frame: .zero)
        followButtonBaseView.translatesAutoresizingMaskIntoConstraints = false
        followButtonBaseView.layer.shadowColor = UIColor.black.cgColor
        followButtonBaseView.layer.shadowOpacity = 0.3
        followButtonBaseView.layer.shadowRadius = 14
        followButtonBaseView.layer.shadowOffset = CGSize(width: 0, height: 0)
        floatingButtonsContainerView.addSubview(followButtonBaseView)
        
        packageActionButtonBaseView = UIView(frame: .zero)
        packageActionButtonBaseView.translatesAutoresizingMaskIntoConstraints = false
        packageActionButtonBaseView.layer.shadowColor = UIColor.black.cgColor
        packageActionButtonBaseView.layer.shadowOpacity = 0.3
        packageActionButtonBaseView.layer.shadowRadius = 14
        packageActionButtonBaseView.layer.shadowOffset = CGSize(width: 0, height: 0)
        floatingButtonsContainerView.addSubview(packageActionButtonBaseView)
        
        followButton = UIButton(frame: .zero)
        followButton.translatesAutoresizingMaskIntoConstraints = false
        followButton.setTitle(String(NSLocalizedString("button.loading", comment: "button title for loading state")), for: .normal)
        followButton.setTitle("", for: .disabled)
        followButton.setTitleColor(.white, for: .normal)
        followButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        followButton.setBackgroundColor(color: Theme().grayTextColor, forUIControlState: .disabled)
        followButton.setBackgroundColor(color: Theme().grayTextColor, forUIControlState: .normal)
        followButton.setBackgroundColor(color: Theme().grayTextColorHighlight, forUIControlState: .highlighted)
        followButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        followButton.layer.cornerRadius = 25
        followButton.clipsToBounds = true
        followButton.addTarget(self, action: #selector(didTapFollowButton(sender:)), for: .touchUpInside)
        followButton.isEnabled = true
        followButtonBaseView.addSubview(followButton)
        
        followButtonActivityIndicatorView = NVActivityIndicatorView(frame: .zero, type: .ballPulseSync, color: .white, padding: 0)
        followButtonActivityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        followButtonBaseView.addSubview(followButtonActivityIndicatorView)
        
        packageActionButton = UIButton(frame: .zero)
        packageActionButton.translatesAutoresizingMaskIntoConstraints = false
        packageActionButton.setTitle(String(NSLocalizedString("button.loading", comment: "button title for loading state")), for: .normal)
        packageActionButton.setTitle("", for: .disabled)
        packageActionButton.setTitleColor(.white, for: .normal)
        packageActionButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        packageActionButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        packageActionButton.layer.cornerRadius = 25
        packageActionButton.clipsToBounds = true
        packageActionButton.addTarget(self, action: #selector(didTapPackageActionButton(sender:)), for: .touchUpInside)
        packageActionButton.isEnabled = false
        packageActionButtonBaseView.addSubview(packageActionButton)

        packageActionButtonActivityIndicatorView = NVActivityIndicatorView(frame: .zero, type: .ballPulseSync, color: .white, padding: 0)
        packageActionButtonActivityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        packageActionButtonBaseView.addSubview(packageActionButtonActivityIndicatorView)
        
        let followHeightConstraint = NSLayoutConstraint(item: self.followButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)
        followButtonBaseView.addConstraint(followHeightConstraint)
        let followHConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[followButton]|", options: .directionLeadingToTrailing, metrics: nil, views: ["followButton": followButton])
        followButtonBaseView.addConstraints(followHConstraints)
        let followVConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[followButton]|", options: .alignAllTrailing, metrics: nil, views: ["followButton": followButton])
        followButtonBaseView.addConstraints(followVConstraints)

        
        let pickupHeightConstraint = NSLayoutConstraint(item: self.packageActionButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)
        packageActionButtonBaseView.addConstraint(pickupHeightConstraint)
        
        let pickupHConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[packageActionButton]|", options: .directionLeadingToTrailing, metrics: nil, views: ["packageActionButton": packageActionButton])
        packageActionButtonBaseView.addConstraints(pickupHConstraints)
        let pickupVConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[packageActionButton]|", options: .alignAllLeading, metrics: nil, views: ["packageActionButton": packageActionButton])
        packageActionButtonBaseView.addConstraints(pickupVConstraints)
        
        NSLayoutConstraint.activate([
            self.followButtonActivityIndicatorView.centerXAnchor.constraint(equalTo: self.followButtonBaseView.centerXAnchor),
            self.followButtonActivityIndicatorView.centerYAnchor.constraint(equalTo: self.followButtonBaseView.centerYAnchor),
            self.followButtonActivityIndicatorView.heightAnchor.constraint(equalToConstant: 30),
            self.followButtonActivityIndicatorView.widthAnchor.constraint(equalToConstant: 30),
            self.packageActionButtonActivityIndicatorView.centerXAnchor.constraint(equalTo: self.packageActionButtonBaseView.centerXAnchor),
            self.packageActionButtonActivityIndicatorView.centerYAnchor.constraint(equalTo: self.packageActionButtonBaseView.centerYAnchor),
            self.packageActionButtonActivityIndicatorView.heightAnchor.constraint(equalToConstant: 30),
            self.packageActionButtonActivityIndicatorView.widthAnchor.constraint(equalToConstant: 30),
        ])
        
        
        
        let containerViewCenterXConstraint = NSLayoutConstraint(item: floatingButtonsContainerView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        view.addConstraint(containerViewCenterXConstraint)
        
        let hBaseViewsConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[followButtonBaseView]-12-[packageActionButtonBaseView]|", options: [.alignAllTop, .alignAllBottom], metrics: nil, views: ["followButtonBaseView": followButtonBaseView, "packageActionButtonBaseView": packageActionButtonBaseView])
        let vBaseViewsConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[followButtonBaseView(50)]|", options: [.alignAllTop, .alignAllBottom], metrics: nil, views: ["followButtonBaseView": followButtonBaseView])
        floatingButtonsContainerView.addConstraints(hBaseViewsConstraints + vBaseViewsConstraints)
        
        bottomConstraintFAB = NSLayoutConstraint(item: self.floatingButtonsContainerView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 100)
        view.addConstraint(bottomConstraintFAB)

        
        collectionView.register(PackageDetailHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "packageDetailHeader")
        collectionView.register(ExpandableTextCollectionViewCell.self, forCellWithReuseIdentifier: "expandableTextCell")
        collectionView.register(HeaderLabelCollectionViewCell.self, forCellWithReuseIdentifier: "headerLabelCell")
        collectionView.register(DeliveryLogisticsCollectionViewCell.self, forCellWithReuseIdentifier: "deliveryLogisticsCell")
        collectionView.register(PostsPreviewCollectionViewCell.self, forCellWithReuseIdentifier: "postsPreviewCell")
        collectionView.register(ActivityIndicatorCollectionViewCell.self, forCellWithReuseIdentifier: "activityViewCell")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1)
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.contentInset.bottom = UIApplication.shared.keyWindow!.safeAreaInsets.bottom + 50 + (UIDevice.isIphoneX ? 10 : 28)
        collectionView.scrollIndicatorInsets.bottom = UIApplication.shared.keyWindow!.safeAreaInsets.bottom + 50 + (UIDevice.isIphoneX ? 10 : 28)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let closeButton = UIBarButtonItem(image: UIImage(named: "round_keyboard_arrow_down_black_36pt"), style: .plain, target: self, action: #selector(didTapCloseButton(sender:)))
        navigationItem.leftBarButtonItem = closeButton
        
        let actionButton = UIBarButtonItem(image: UIImage(named: "round_share_black_24pt"), style: .plain, target: self, action: #selector(didTapShareButton(sender:)))
        navigationItem.rightBarButtonItem = actionButton
        
        updateNavigationBarAppearance(withTransparency: true)
        
        LocationManager.shared.delegate = self
        
        checkAlreadyMoving()
        fetchPackage(with: self.packageDocumentId)
        fetchPosts()
        listenForFollowStatus()
    }
    
    private func checkAlreadyMoving() {
        fetchUserDoc(uid: Auth.auth().currentUser!.uid) { (userDoc) in
            if userDoc != nil {
                self.alreadyMoving = userDoc!.privateProfile.currentPackage != nil
                self.newUpdatePackageActionButton(with: LocationManager.shared.location!)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        if collectionView.contentOffset.y > (50 + UIApplication.shared.keyWindow!.safeAreaInsets.top)  && navBarIsTransparent == true {
            self.updateNavigationBarAppearance(withTransparency: false)
        } else if collectionView.contentOffset.y <= (50 + UIApplication.shared.keyWindow!.safeAreaInsets.top) && navBarIsTransparent == false {
            self.updateNavigationBarAppearance(withTransparency: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        followStatusListener?.remove()
        packageDataListener?.remove()
        packageTransitRecordsListener?.remove()
        LocationManager.shared.stopUpdatingLocation()
    }
    
    func reloadCollectionView() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0, animations: {
                self.collectionView.reloadData()
            })
        }
    }
    
    private func checkUserIsFollowingPackage() -> Bool {
        if self.packagesFollowing.index(where: {$0.reference.documentID == package?.reference.documentID}) != nil {
            // user is following
            return true
        } else {
            return false
        }
    }
    
    private func updateFollowButton() {
        DispatchQueue.main.async {
            self.followButtonActivityIndicatorView.isHidden = true
            self.followButtonActivityIndicatorView.stopAnimating()
            if self.checkUserIsFollowingPackage() {
                print("is following")
                self.followButton.setTitle(String(NSLocalizedString("button.tracking", comment: "button title for Following")), for: .normal)
            } else {
                print("is not following")
                self.followButton.setTitle(String(NSLocalizedString("button.track", comment: "button title for Follow")), for: .normal)
            }
            self.followButton.isEnabled = true
        }
    }
    
    func listenForFollowStatus() {
        self.followStatusListener = Firestore.firestore().document("users/\(Auth.auth().currentUser!.uid)").collection("packages_following").addSnapshotListener({ (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            var newPackagesFollowing:[PackageFollowing] = []
            snapshot.documentChanges.forEach { diff in
                if (diff.type == .added) {
                    if self.packagesFollowing.index(where: { $0.reference.documentID == (diff.document.data()["package_reference"] as! DocumentReference).documentID }) != nil {
                    } else {
                        newPackagesFollowing.append(PackageFollowing(dict: diff.document.data()))
                    }
                    print("added")
                }
                if (diff.type == .modified) {
                    if let index = self.packagesFollowing.index(where: { $0.reference.documentID == (diff.document.data()["package_reference"] as! DocumentReference).documentID }) {
                        self.packagesFollowing[index] = PackageFollowing(dict: diff.document.data())
                        print("Modified")
                    }
                }
                if (diff.type == .removed) {
                    if let index = self.packagesFollowing.index(where: { $0.reference.documentID == (diff.document.data()["package_reference"] as! DocumentReference).documentID }) {
                        self.packagesFollowing.remove(at: index)
                        print("Removed")
                    }
                }
            }
            self.packagesFollowing.insert(contentsOf: newPackagesFollowing, at: 0)
            if self.package != nil {
                DispatchQueue.main.async {
                    self.updateFollowButton()
                }
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func didTapCloseButton(sender: UIBarButtonItem) {
        delegate?.dismissPackageDetailVC()
    }
    
    @objc private func didTapShareButton(sender: UIBarButtonItem) {
        // text to share
        let text = "I'm tracking a package for #\(self.package!.tag.name): \(self.package!.headline). Join me on Movables at movables.co."
        
        // set up activity view controller
        let textToShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
//        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @objc private func didTapPackageActionButton(sender: UIButton) {
        if self.package!.status == .pending {
            print("pickup")
            sender.isEnabled = false
            self.packageActionButton.setTitleColor(.white, for: .normal)
            self.packageActionButtonActivityIndicatorView.startAnimating()
            pickupPackageWithRef(packageReference: self.package!.reference, userReference: Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid), completion: { (success) in
                self.packageActionButtonActivityIndicatorView.stopAnimating()
                sender.isEnabled = true
                if success {
                    print("pickup success")
                } else {
                    print("pickup failure")
                }
            })
        } else if self.package!.status == .transit {
            print("dropoff")
            sender.isEnabled = false
            let packageTemp = self.package!
            self.packageActionButton.setTitleColor(.white, for: .normal)
            self.packageActionButtonActivityIndicatorView.startAnimating()
            dropoffPackageWithRef(packageReference: self.package!.reference, userReference: Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid), completion: { (success, response, alertVC) in
                self.packageActionButtonActivityIndicatorView.stopAnimating()
                sender.isEnabled = true
                if success {
                    print("dropoff success")
                    sender.isEnabled = true
                    self.delegate?.presentDropoffSummary(with: packageTemp, response: response!)
                } else {
                    if alertVC != nil {
                        self.present(alertVC!, animated: true, completion: {
                            print("presented alert")
                        })
                    }
                    print("dropoff failure")
                }
            })
        }
    }
    
    @objc private func didTapMapView(sender: UITapGestureRecognizer) {
        print("map tapped")
        delegate?.showMapRouteVC(for: self.package!)
    }
    
    private func setupFAB() {
        UIView.animate(withDuration: 0.35) {
            self.bottomConstraintFAB.constant = -(self.view.safeAreaInsets.bottom + 50 + (UIDevice.isIphoneX ? 0 : 18))
            self.view.layoutIfNeeded()
        }
    }
}

extension PackageDetailViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.package != nil && self.posts != nil {
            return 5
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = indexPath.item
        if self.package != nil {
            if item == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "headerLabelCell", for: indexPath) as! HeaderLabelCollectionViewCell
                if self.package!.templateBy != nil {
                    cell.label.text = String(format: NSLocalizedString("label.templateBy", comment: "label text for template by"), self.package!.templateBy!.displayName)
                } else {
                    cell.label.text = String(format: NSLocalizedString("label.by", comment: "label text for authored by") , self.package!.sender.displayName)
                }
                return cell
            }
             else if item == 1 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "expandableTextCell", for: indexPath) as! ExpandableTextCollectionViewCell
                cell.label.text = package?.description.replacingOccurrences(of: "\\n", with: "\n")
                cell.label.numberOfLines = showAllDescription ? 0 : 5
                cell.button.setTitleColor(self.categoryTint!, for: .normal)
                cell.button.setTitleColor(self.categoryTint!.withAlphaComponent(0.85), for: .highlighted)
                if !showAllDescription && cell.label.calculateMaxLines(width: UIScreen.main.bounds.width - 36) > 5 {
                    cell.button.addTarget(self, action: #selector(showAllDescription(sender:)), for: .touchUpInside)
                } else {
                    cell.parentView.removeConstraints([cell.buttonTopConstraint, cell.buttonBottomConstraint, cell.buttonTrailingConstraint])
                    cell.button.removeFromSuperview()
                    cell.parentView.addConstraint(NSLayoutConstraint(item: cell.label, attribute: .bottom, relatedBy: .equal, toItem: cell.parentView, attribute: .bottom, multiplier: 1, constant: -18))
                }
                cell.layoutIfNeeded()
                return cell
            } else if item == 2 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "deliveryLogisticsCell", for: indexPath) as! DeliveryLogisticsCollectionViewCell
                cell.cardView.layer.borderColor = self.categoryTint!.withAlphaComponent(0.3).cgColor
                cell.originCoordinate = packagePreview.originCoordinate
                cell.currentLocationCoordinate = packagePreview.coordinate
                cell.destinationCoordinate = packagePreview.destinationCoordinate
                cell.presentingVC = self
                if !deliveryRouteDrawn  {
                    cell.activateMapView()
                    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapMapView(sender:)))
                    cell.mapView.addGestureRecognizer(tapRecognizer)
                }
                
                if !fetchedTransitRecords {
                    cell.activateMapTransitRecords()
                }

                if package != nil {
                    let units = generateLogisticsRowsForPackage(package: self.package!)
                    if cell.contentStackView.arrangedSubviews.count != units.count {
                        cell.units = units
                        cell.activateStackView()
                        for (index, row) in cell.contentStackView.arrangedSubviews.enumerated() {
                            var buttonStackView: UIStackView!
                            for subview in row.subviews {
                                if subview.isKind(of: UIStackView.self) {
                                    buttonStackView = subview as! UIStackView
                                }
                            }

                            let unit = units[index]
                            if unit.actions != nil {
                                for (index, action) in unit.actions!.enumerated() {
                                    if let button = buttonStackView.arrangedSubviews[index] as? UIButton{
                                        if action.type == .Call {
                                            button.addTarget(self, action: #selector(didTapCallButton(sender:)), for: .touchUpInside)
                                            
                                        } else if action.type == .Tweet {
                                            button.addTarget(self, action: #selector(didTapTweetButton(sender:)), for: .touchUpInside)
                                            
                                        } else {
                                            //                                        action.type == .More
                                            button.addTarget(self, action: #selector(didTapMoreButton(sender:)), for: .touchUpInside)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                return cell
            } else if item == 3 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "headerLabelCell", for: indexPath) as! HeaderLabelCollectionViewCell
                cell.label.text = String(NSLocalizedString("headerCollectionCell.conversation", comment: "collection view cell title for Conversation"))
                return cell
            } else if item == 4{
                // posts stack with view more button
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postsPreviewCell", for: indexPath) as! PostsPreviewCollectionViewCell
                cell.button.addTarget(self, action: #selector(didTapViewPostsButton(sender:)), for: .touchUpInside)
                cell.button.isHidden = self.posts?.count == 0
                cell.button.setTitle("View all posts", for: .normal)
                cell.posts = self.posts
                cell.button.setTitleColor(self.categoryTint!, for: .normal)
                cell.button.setTitleColor(self.categoryTint!.withAlphaComponent(0.85), for: .highlighted)
                cell.cardView.layer.borderColor = self.categoryTint!.withAlphaComponent(0.3).cgColor
                cell.activateStackView()
                if cell.posts.count == 0 {
                    cell.emptyStateButton?.setBackgroundColor(color: self.categoryTint!, forUIControlState: .normal)
                    cell.emptyStateButton?.setBackgroundColor(color: self.categoryTint!.withAlphaComponent(0.85), forUIControlState: .highlighted)
                    cell.emptyStateButton?.addTarget(self, action: #selector(didTapViewPostsButton(sender:)), for: .touchUpInside)
                }
                return cell
            } else {
                // misc. actions
                return UICollectionViewCell()
            }
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "activityViewCell", for: indexPath) as! ActivityIndicatorCollectionViewCell
            cell.activityIndicatorView.startAnimating()
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "packageDetailHeader", for: indexPath) as! PackageDetailHeaderCollectionReusableView
        if package != nil && package!.coverImageUrl != nil {
            view.imageView.sd_setImage(with: URL(string: package!.coverImageUrl!)) { (image, error, cacheType, url) in
                if error != nil {
                    print(error!)
                }
            }
        }
            view.titleLabel.text = self.headline!
        if self.packagePreview != nil {
            view.tagPill.characterLabel.text = getEmojiForCategory(category: self.packagePreview.categories.first!)
            view.tagPill.pillContainerView.backgroundColor = getTintForCategory(category: self.packagePreview.categories.first!)
            view.tagPill.bodyLabel.text = self.package!.tag.name
            view.tagPill.isHidden = false
        } else {
            view.tagPill.isHidden = true
        }
            return view
    }
    
    @objc private func showAllDescription(sender: UIButton) {
        print("show all")
        self.showAllDescription = true
    }
    
    func fetchPackage(with documentId: String){
        let db = Firestore.firestore()
        self.packageDataListener = db.collection("packages").document(self.packageDocumentId).addSnapshotListener({ (documentSnapshot, error) in
            guard documentSnapshot != nil else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            let snapshotPackage = Package(snapshot: documentSnapshot!)
            if self.package == nil || (self.package != nil && self.package != snapshotPackage) {
                self.package = snapshotPackage
                self.packagePreview = PackagePreview(package: self.package!)
                self.categoryTint = getTintForCategory(category: self.package!.categories.first!)
                self.packageActionButton.setBackgroundColor(color: self.categoryTint!, forUIControlState: .normal)
                self.packageActionButton.setBackgroundColor(color: self.categoryTint!.withAlphaComponent(0.85), forUIControlState: .highlighted)

            }
            print("finished attacing package listener")
        })
    }
    
    private func listenToTransitRecords() {
        self.packageTransitRecordsListener =  self.package!.reference.collection("transit_records").addSnapshotListener({ (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            var newTransitRecords:[TransitRecord] = []
            snapshot.documentChanges.forEach { diff in
                if (diff.type == .added) {
                    if (self.transitRecords?.index(where: { $0.reference == diff.document.reference})) != nil {
                    } else {
                        newTransitRecords.append(TransitRecord(dict: diff.document.data(), reference: diff.document.reference))
                    }
                    print("added")
                }
                if (diff.type == .modified) {
                    if let index = self.transitRecords?.index(where: { $0.reference == diff.document.reference}) {
                        self.transitRecords?[index] = TransitRecord(dict: diff.document.data(), reference: diff.document.reference)
                        print("Modified")
                    }
                }
                if (diff.type == .removed) {
                    if let index = self.transitRecords?.index(where: { $0.reference == diff.document.reference}) {
                        self.transitRecords?.remove(at: index)
                        print("Removed")
                    }
                }
            }
            if self.transitRecords != nil {
                self.transitRecords?.insert(contentsOf: newTransitRecords, at: 0)
            } else {
                self.transitRecords = newTransitRecords
            }
            LocationManager.shared.requestLocation()
            self.setupFAB()
            LocationManager.shared.startUpdatingLocation()
        })
    }
    
    func generateLogisticsRowsForPackage(package: Package) -> [LogisticsRow] {
        var rows:[LogisticsRow] = []
        // recipient
        var recipientActions:[Action] = []
        if package.recipient.twitter_handle != nil {
            recipientActions.append(Action(type: .Tweet, dictionary: ["handle": package.recipient.twitter_handle!]))
        }
        if package.recipient.phone != nil {
            recipientActions.append(Action(type: .Call, dictionary: ["phone": package.recipient.phone!]))
        }
        let recipientRow = LogisticsRow(
            circleImageUrl: package.recipient.photoUrl,
            circleText: nil,
            circleSubscript: nil,
            titleText: package.recipient.displayName,
            subtitleText: String(NSLocalizedString("label.recipient", comment: "label title for recipient")),
            tint: getTintForCategory(category: package.categories.first!),
            actions: recipientActions,
            type: .Person
        )
        rows.append(recipientRow)

        // time
        
        let timeLeftformatter = DateComponentsFormatter()
        timeLeftformatter.unitsStyle = .full
        timeLeftformatter.includesApproximationPhrase = false
        timeLeftformatter.includesTimeRemainingPhrase = false
        timeLeftformatter.allowedUnits = [.day, .hour, .minute]
        
        // Use the configured formatter to generate the string.
        let timeLeftString = packagePreview.timeLeft > 0 ? timeLeftformatter.string(from: packagePreview.timeLeft)! : String(NSLocalizedString("label.pastDue", comment: "label title for package past due state"))

        let timeRow = LogisticsRow(
            circleImageUrl: nil,
            circleText: nil,
            circleSubscript: nil,
            titleText: "\(timeLeftString)",
            subtitleText: String(NSLocalizedString("label.time", comment: "label title for time")),
            tint: getTintForCategory(category: package.categories.first!),
            actions: nil,
            type: .Time
        )
        rows.append(timeRow)
        
        // distance
        let distanceLeftformatter = MeasurementFormatter()
        distanceLeftformatter.unitStyle = .long
        distanceLeftformatter.unitOptions = .naturalScale
        distanceLeftformatter.numberFormatter.maximumFractionDigits = 2
        
        let distanceLeft = Measurement(value: packagePreview.distanceLeft, unit: UnitLength.meters)
        let distanceLeftString = distanceLeftformatter.string(from: distanceLeft)
        
        let totalDistanceformatter = MeasurementFormatter()
        totalDistanceformatter.unitStyle = .long
        totalDistanceformatter.unitOptions = .naturalScale
        totalDistanceformatter.numberFormatter.maximumFractionDigits = 2
        
        let totalDistance = Measurement(value: packagePreview.distanceTotal, unit: UnitLength.meters)
        let totalDistanceLeftString = totalDistanceformatter.string(from: totalDistance)

        let distanceRow = LogisticsRow(
            circleImageUrl: nil,
            circleText: nil,
            circleSubscript: nil,
            titleText: packagePreview.packageStatus != .delivered ? "\(distanceLeftString) / \(totalDistanceLeftString)" : String(NSLocalizedString("label.delivered", comment: "label text for delivered")),
            subtitleText: String(NSLocalizedString("label.distance", comment: "label title for distance")),
            tint: getTintForCategory(category: package.categories.first!),
            actions: nil,
            type: .Directions
        )
        rows.append(distanceRow)
        
        // sender
        let senderRow = LogisticsRow(
            circleImageUrl: package.sender.photoUrl,
            circleText: nil,
            circleSubscript: nil,
            titleText: package.sender.displayName,
            subtitleText: String(NSLocalizedString("label.sender", comment: "label title for sender")),
            tint: getTintForCategory(category: package.categories.first!),
            actions: nil,
            type: .Person
        )
        rows.append(senderRow)
        
        return rows
    }
}

extension PackageDetailViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            if scrollView.contentOffset.y > (50 + UIApplication.shared.keyWindow!.safeAreaInsets.top)  && navBarIsTransparent == true {
                    self.updateNavigationBarAppearance(withTransparency: false)
            }
            if scrollView.contentOffset.y <= (50 + UIApplication.shared.keyWindow!.safeAreaInsets.top) && navBarIsTransparent == false {
                self.updateNavigationBarAppearance(withTransparency: true)
            }
        }
        
    }
    
    private func fetchPosts() {
        let db = Firestore.firestore()
        db.collection("packages/\(self.packageDocumentId!)/public_comments").order(by: "created_date", descending: true).limit(to: 3).getDocuments { (snapshot, error) in
            if error != nil {
                print(error!)
            } else {
                if snapshot != nil {
                    var posts:[Post] = []
                    for document in snapshot!.documents {
                        posts.append(Post(dictionary: document.data(), reference: document.reference))
                    }
                    self.posts = posts
                }
            }
        }
    }
    
    @objc private func didTapViewPostsButton(sender: UIButton) {
        print("view posts")
        delegate?.showPostsVC()
    }
    
    @objc private func didTapCallButton(sender: UIButton) {
        print("call")
        self.package!.recipient.phone!.makeAColl()
    }
    
    @objc private func didTapTweetButton(sender: UIButton) {
        print("tweet")
        let twitterHandle = self.package!.recipient.twitter_handle!
        let twUrl = URL(string: "twitter://user?screen_name=\(twitterHandle)")!
        let twUrlWeb = URL(string: "https://www.twitter.com/\(twitterHandle)")!
        if UIApplication.shared.canOpenURL(twUrl){
            UIApplication.shared.open(twUrl, options: [:],completionHandler: nil)
        }else{
            UIApplication.shared.open(twUrlWeb, options: [:], completionHandler: nil)
        }
    }

    @objc private func didTapMoreButton(sender: UIButton) {
        print("more")
    }
    
    @objc private func didTapFollowButton(sender: UIButton) {
        sender.isEnabled = false
        self.followButtonActivityIndicatorView.startAnimating()
        self.followButtonActivityIndicatorView.isHidden = false
        if checkUserIsFollowingPackage() {
            print("unfollow")
            unfollowPackageWithRef(packageReference: package!.reference, userReference: Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid)) { (success) in
                if success {
                    print("unfollow success")
                } else {
                    print("unfollow failure")
                }
            }
        } else {
            print("follow")
            followPackageWithRef(packageReference: package!.reference, userReference: Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid)) { (success) in
                self.followButton.isEnabled = true
                if success {
                    print("follow success")
                } else {
                    print("follow failure")
                }
            }
        }
    }


    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if scrollView.contentOffset.y < -100 {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func updateNavigationBarAppearance(withTransparency: Bool) {
        self.navBarIsTransparent = !self.navBarIsTransparent
        self.navigationController?.navigationBar.setBackgroundImage(withTransparency ? UIImage() : nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = withTransparency ? UIImage() : nil
        self.navigationItem.titleView?.isHidden = withTransparency ? true : false
        self.navigationController?.navigationBar.tintColor = withTransparency ? .white : Theme().textColor
    }
    
    func packageInTransitByCurrentUser() -> Bool {
        return self.package?.inTransitBy?.reference == Firestore.firestore().document("users/\(Auth.auth().currentUser!.uid)")
    }
}

extension PackageDetailViewController: CLLocationManagerDelegate {
    
    func packageAlreadyMovedByCurrentUser() -> Bool {
        if self.transitRecords?.index(where: {$0.reference.documentID == Auth.auth().currentUser!.uid}) != nil {
            return true
        }
        return false
    }
    
    func newUpdatePackageActionButton(with location: CLLocation?) {
        DispatchQueue.main.async {
            if self.package != nil {
                if self.packageInTransitByCurrentUser() {
                    // current user is moving the package
                    if location != nil {
                        // if current location is available
                        applyEnabledStyleToButton(button: self.packageActionButton, withTint: self.categoryTint!)
                        if location!.distance(from: CLLocation(latitude: self.package!.destination.geoPoint.latitude, longitude: self.package!.destination.geoPoint.longitude)) < self.ACTIONABLE_DISTANCE {
                            // if current location is within actionable distance from destination
                            self.packageActionButton.setTitle("Deliver", for: .normal)
                        } else {
                            // if current location is outside actionable distance from destination
                            self.packageActionButton.setTitle("Dropoff", for: .normal)
                        }
                    } else {
                        // if current location is not available
                        self.packageActionButton.setTitle(String(NSLocalizedString("button.loading", comment: "button title for loading status")), for: .disabled)
                        applyDisabledStyleToButton(button: self.packageActionButton)
                        self.packageActionButton.setBackgroundColor(color: .white, forUIControlState: .disabled)
                    }
                } else {
                    // current user is not moving the package
                    if location != nil && self.package!.status != .transit && self.package!.status != .delivered && self.packageAlreadyMovedByCurrentUser() {
                        // if package is in not in transit and the package had already been moved by current user
                        self.packageActionButton.setTitle(String(NSLocalizedString("button.moved", comment: "button title for moved status")), for: .disabled)
                        applyDisabledStyleToButton(button: self.packageActionButton)
                        self.packageActionButton.setBackgroundColor(color: .white, forUIControlState: .disabled)
                    } else if self.package!.status == .transit {
                        // if package is in transit by others
                        self.packageActionButton.setTitle("In transit", for: .disabled)
                        applyDisabledStyleToButton(button: self.packageActionButton)
                        self.packageActionButton.setBackgroundColor(color: .white, forUIControlState: .disabled)
                    } else if self.package!.status == .pending {
                        // if package status is pending
                        if location != nil {
                            if !self.alreadyMoving {
                                // if current location is available
                                let distanceFromPickup = location!.distance(from: CLLocation(latitude: self.package!.currentLocation.coordinate.latitude, longitude: self.package!.currentLocation.coordinate.longitude))
                                if distanceFromPickup < self.ACTIONABLE_DISTANCE  {
                                    // if current location is with actionable distance from package location
                                    self.packageActionButton.setTitle(String(NSLocalizedString("button.pickup", comment: "button title for pickup")), for: .normal)
                                    applyEnabledStyleToButton(button: self.packageActionButton, withTint: self.categoryTint!)
                                } else if distanceFromPickup >= self.ACTIONABLE_DISTANCE {
                                    if distanceFromPickup > self.TOO_FAR_DISTANCE {
                                        // if current location is beyond too far away distance from package location
                                        self.packageActionButton.setTitle("Too far away", for: .disabled)
                                        applyDisabledStyleToButton(button: self.packageActionButton)
                                        self.packageActionButton.setBackgroundColor(color: .white, forUIControlState: .disabled)

                                    } else {
                                        let distanceLeftString = self.buttonDistanceLeftformatter.string(from: Measurement(value: distanceFromPickup, unit: UnitLength.meters))
                                        self.packageActionButton.setTitle(String(format: NSLocalizedString("button.pickupAway", comment: "button title for pickup some distance away"), distanceLeftString), for: .disabled)
                                        applyDisabledStyleToButton(button: self.packageActionButton)
                                        self.packageActionButton.setBackgroundColor(color: .white, forUIControlState: .disabled)

                                    }
                                } else {
                                    // if current location is outside actionable distance from package location
                                    let distanceLeftString = self.buttonDistanceLeftformatter.string(from: Measurement(value: distanceFromPickup, unit: UnitLength.meters))
                                    self.packageActionButton.setTitle(String(format: NSLocalizedString("button.pickupAway", comment: "button title for pickup some distance away"), distanceLeftString), for: .disabled)
                                    applyDisabledStyleToButton(button: self.packageActionButton)
                                    self.packageActionButton.setBackgroundColor(color: .white, forUIControlState: .disabled)

                                }
                            } else {
                                // if current location is unavailable
                                self.packageActionButton.setTitle("Unavailable", for: .disabled)
                                applyDisabledStyleToButton(button: self.packageActionButton)
                                self.packageActionButton.setBackgroundColor(color: .white, forUIControlState: .disabled)
                            }
                        } else {
                            // if current location is unavailable
                            self.packageActionButton.setTitle(String(NSLocalizedString("button.loading", comment: "button title for loading status")), for: .disabled)
                            applyDisabledStyleToButton(button: self.packageActionButton)
                            self.packageActionButton.setBackgroundColor(color: .white, forUIControlState: .disabled)

                        }
                    } else if self.package!.status == .delivered {
                        // if package status is delivered
                        self.packageActionButton.setTitle(String(NSLocalizedString("button.delivered", comment: "button title for package delivered")), for: .disabled)
                        applyDisabledStyleToButton(button: self.packageActionButton)
                        self.packageActionButton.setBackgroundColor(color: .white, forUIControlState: .disabled)

                    } else {
                        // if package action can not be determined
                        self.packageActionButton.setTitle("Error", for: .disabled)
                        applyDisabledStyleToButton(button: self.packageActionButton)
                        self.packageActionButton.setBackgroundColor(color: .white, forUIControlState: .disabled)

                    }
                }
            } else {
                self.packageActionButton.setTitle(String(NSLocalizedString("button.loading", comment: "button title for loading status")), for: .disabled)
                applyDisabledStyleToButton(button: self.packageActionButton)
                self.packageActionButton.setBackgroundColor(color: .white, forUIControlState: .disabled)
                // if current location is unavailable
            }
            self.packageActionButton.layoutIfNeeded()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        newUpdatePackageActionButton(with: locations.first)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

func applyDisabledStyleToButton(button: UIButton) {
    button.isEnabled = false
    button.layer.borderColor = Theme().borderColor.withAlphaComponent(0.5).cgColor
    button.layer.borderWidth = 4
    button.setTitleColor(Theme().disabledTextColor.withAlphaComponent(0.5), for: .normal)
}

func applyEnabledStyleToButton(button: UIButton, withTint color: UIColor) {
    button.layer.borderColor = nil
    button.layer.borderWidth = 0
    button.setTitleColor(.white, for: .normal)
    button.isEnabled = true
    button.isHidden = false
}

