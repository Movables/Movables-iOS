//
//  CreatePackageReviewViewController.swift
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
import CoreLocation
import NVActivityIndicatorView
import Firebase

class CreatePackageReviewViewController: UIViewController {
    
    var createPackageCoordinator: CreatePackageCoordinator!
    var instructionLabel: MCPill!
    
    var backButtonBaseView: UIView!
    var backButton: UIButton!
    var createButtonBaseView: UIView!
    var createButton: UIButton!
    
    var collectionView: UICollectionView!
    var deliveryRouteDrawn: Bool = false
    
    var coverImage: UIImage?
    var coverImageUrl: URL?
    var sender: Person!
    var recipient: Person!
    var packageHeadline: String!
    var packageTopicName: String!
    var packageDescription: String!
    var originCoordinate: CLLocationCoordinate2D!
    var destinationCoordinate: CLLocationCoordinate2D!
    var packageDueDate: Date!
    var category: PackageCategory!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        setupOtherViews()
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true

        collectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 9 / 16 + UIApplication.shared.keyWindow!.safeAreaInsets.top)
        
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: 100)
        layout.itemSize = UICollectionViewFlowLayout.automaticSize

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        
        NSLayoutConstraint.activate([
            collectionView.heightAnchor.constraint(equalTo: view.heightAnchor),
            collectionView.widthAnchor.constraint(equalTo: view.widthAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        collectionView.register(PackageDetailHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "packageDetailHeader")
        collectionView.register(ExpandableTextCollectionViewCell.self, forCellWithReuseIdentifier: "expandableTextCell")
        collectionView.register(HeaderLabelCollectionViewCell.self, forCellWithReuseIdentifier: "headerLabelCell")
        
        collectionView.register(DeliveryLogisticsCollectionViewCell.self, forCellWithReuseIdentifier: "deliveryLogisticsCell")
        collectionView.register(MCParagraphActionsCollectionViewCell.self, forCellWithReuseIdentifier: "paragraphActionsCell")
        
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1)
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.contentInset.bottom = UIApplication.shared.keyWindow!.safeAreaInsets.bottom + 50 + 10 + (UIDevice.isIphoneX ? 10 : 28)
        collectionView.scrollIndicatorInsets.bottom = UIApplication.shared.keyWindow!.safeAreaInsets.bottom + 50 + (UIDevice.isIphoneX ? 10 : 28)

    }
    
    private func setupOtherViews() {
        instructionLabel = MCPill(frame: .zero, character: "\(self.navigationController!.children.count)", image: nil, body: String(NSLocalizedString("label.reviewPackage", comment: "label text for review package")), color: .white)
        instructionLabel.bodyLabel.textColor = Theme().textColor
        instructionLabel.circleMask.backgroundColor = Theme().textColor
        instructionLabel.characterLabel.textColor = .white
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(instructionLabel)

        NSLayoutConstraint.activate([
            instructionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            instructionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6),
        ])
        
        backButtonBaseView = UIView(frame: .zero)
        backButtonBaseView.translatesAutoresizingMaskIntoConstraints = false
        backButtonBaseView.layer.shadowColor = UIColor.black.cgColor
        backButtonBaseView.layer.shadowOpacity = 0.3
        backButtonBaseView.layer.shadowRadius = 14
        backButtonBaseView.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.addSubview(backButtonBaseView)
        
        backButton = UIButton(frame: .zero)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(named: "round_back_black_50pt"), for: .normal)
        backButton.tintColor = .white
        backButton.setBackgroundColor(color: Theme().grayTextColor, forUIControlState: .normal)
        backButton.setBackgroundColor(color: Theme().grayTextColorHighlight, forUIControlState: .highlighted)
        backButton.contentEdgeInsets = .zero
        backButton.layer.cornerRadius = 25
        backButton.clipsToBounds = true
        backButton.addTarget(self, action: #selector(didTapBackButton(sender:)), for: .touchUpInside)
        backButton.isEnabled = true
        backButtonBaseView.addSubview(backButton)
        
        let backHConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[backButton(50)]|", options: .directionLeadingToTrailing, metrics: nil, views: ["backButton": backButton])
        backButtonBaseView.addConstraints(backHConstraints)
        let backVConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[backButton(50)]|", options: .alignAllTrailing, metrics: nil, views: ["backButton": backButton])
        backButtonBaseView.addConstraints(backVConstraints)
        
        createButtonBaseView = UIView(frame: .zero)
        createButtonBaseView.translatesAutoresizingMaskIntoConstraints = false
        createButtonBaseView.layer.shadowColor = UIColor.black.cgColor
        createButtonBaseView.layer.shadowOpacity = 0.3
        createButtonBaseView.layer.shadowRadius = 14
        createButtonBaseView.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.addSubview(createButtonBaseView)
        
        createButton = UIButton(frame: .zero)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        createButton.setTitle(String(NSLocalizedString("button.createPackage", comment: "button title for Create")), for: .normal)
        createButton.setTitleColor(.white, for: .normal)
        createButton.tintColor = .white
        createButton.setBackgroundColor(color: getTintForCategory(category: createPackageCoordinator.category!), forUIControlState: .normal)
        createButton.setBackgroundColor(color: getTintForCategory(category: createPackageCoordinator.category!).withAlphaComponent(0.85), forUIControlState: .highlighted)
        createButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        createButton.layer.cornerRadius = 25
        createButton.clipsToBounds = true
        createButton.addTarget(self, action: #selector(didTapNavigateButton(sender:)), for: .touchUpInside)
        createButtonBaseView.addSubview(createButton)
        
        let nextHConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[createButton]|", options: .directionLeadingToTrailing, metrics: nil, views: ["createButton": createButton])
        createButtonBaseView.addConstraints(nextHConstraints)
        let nextVConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[createButton(50)]|", options: .alignAllTrailing, metrics: nil, views: ["createButton": createButton])
        createButtonBaseView.addConstraints(nextVConstraints)
        
        
        NSLayoutConstraint.activate([
            backButtonBaseView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 18),
            backButtonBaseView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -(UIDevice.isIphoneX ? 0 : 18)),
            createButtonBaseView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -18),
            createButtonBaseView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -(UIDevice.isIphoneX ? 0 : 18)),
            ])

    }
    
    @objc private func didTapBackButton(sender: UIButton) {
        createPackageCoordinator.unwind()
        print("backed")
    }

    @objc private func didTapNavigateButton(sender: UIButton) {
        self.backButton.isEnabled = false
        sender.isEnabled = false
        createPackageCoordinator.beginSavingPackage { (success) in
            if success {
                self.dismiss(animated: true, completion: {
                    print("get ready to start movn'")
                })
            } else {
                sender.isEnabled = true
                self.backButton.isEnabled = true
            }

        }
    }
    
}

extension CreatePackageReviewViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let count = createPackageCoordinator.externalActions?.count else { return 3 }
        if count > 0 {
            return 4
        } else {
            return 3
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = indexPath.item
        if item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "headerLabelCell", for: indexPath) as! HeaderLabelCollectionViewCell
            if createPackageCoordinator.usingTemplate {
                cell.label.text = String(format: NSLocalizedString("label.templateBy", comment: "label text for template by"), createPackageCoordinator.template!.author!.displayName)
            } else {
                cell.label.text = String(format: NSLocalizedString("label.by", comment: "label text for authored by") , sender.displayName)
            }
            return cell
        }
        else if item == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "expandableTextCell", for: indexPath) as! ExpandableTextCollectionViewCell
            cell.label.text = packageDescription.replacingOccurrences(of: "\\n", with: "\n")
            cell.label.numberOfLines = 0
            cell.parentView.removeConstraints([cell.buttonTopConstraint, cell.buttonBottomConstraint, cell.buttonTrailingConstraint])
            cell.button.removeFromSuperview()
            cell.parentView.addConstraint(NSLayoutConstraint(item: cell.label, attribute: .bottom, relatedBy: .equal, toItem: cell.parentView, attribute: .bottom, multiplier: 1, constant: -18))
            cell.layoutIfNeeded()
            return cell
        } else if item == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "deliveryLogisticsCell", for: indexPath) as! DeliveryLogisticsCollectionViewCell
            cell.originCoordinate = originCoordinate
            cell.currentLocationCoordinate = originCoordinate
            cell.destinationCoordinate = destinationCoordinate
            cell.cardView.layer.borderColor = getTintForCategory(category: category).withAlphaComponent(0.3).cgColor
            cell.presentingVC = self
            if !deliveryRouteDrawn {
                cell.activateMapView()
            }
            
            let units = generateLogisticsRowsForPackage()
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
                                } else if action.type == .Facebook {
                                    button.addTarget(self, action: #selector(didTapFacebookButton(sender:)), for: .touchUpInside)
                                } else {
                                    //                                        action.type == .More
                                    button.addTarget(self, action: #selector(didTapMoreButton(sender:)), for: .touchUpInside)
                                }
                            }
                        }
                    }
                }
            }
            return cell
        } else if item == 3 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "paragraphActionsCell", for: indexPath) as! MCParagraphActionsCollectionViewCell
            cell.actions = createPackageCoordinator.externalActions
            cell.paragraphLabel.text = createPackageCoordinator.dropoffMessage
            cell.cardView.layer.borderColor = getTintForCategory(category: category).withAlphaComponent(0.3).cgColor
            cell.activateStackView()
            for row in cell.actionsStackView.arrangedSubviews {
                var button: UIButton!
                for subview in row.subviews {
                    if subview.isKind(of: UIButton.self) {
                        button = subview as! UIButton
                    }
                }
                button.setBackgroundColor(color: getTintForCategory(category: createPackageCoordinator.category!), forUIControlState: .normal)
                button.setBackgroundColor(color: getTintForCategory(category: createPackageCoordinator.category!).withAlphaComponent(0.85), forUIControlState: .highlighted)
                button.addTarget(self, action: #selector(didTapOnExternalLinkButton(sender:)), for: .touchUpInside)
            }
            return cell
        } else {
            // misc. actions
            return UICollectionViewCell()
        }
    }
    
    @objc private func didTapOnExternalLinkButton(sender: UIButton){
        let externalAction = createPackageCoordinator.externalActions![sender.tag]
        print("action tapped is \(externalAction)")
        createPackageCoordinator.showSFVC(with: URL(string: externalAction.webLink!)!)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "packageDetailHeader", for: indexPath) as! PackageDetailHeaderCollectionReusableView
        if coverImage != nil {
            view.imageView.image = coverImage!
        } else {
            view.imageView.sd_setImage(with: coverImageUrl!) { (image, error, cacheType, url) in
                print("image loaded")
            }
        }
        view.titleLabel.text = packageHeadline
        view.topicPill.bodyLabel.text = packageTopicName
        view.topicPill.characterLabel.text = getEmojiForCategory(category: category)
        view.topicPill.pillContainerView.backgroundColor = getTintForCategory(category: category)
        return view
    }
    
    func generateLogisticsRowsForPackage() -> [LogisticsRow] {
        var rows:[LogisticsRow] = []
        // recipient
        var recipientActions:[Action] = []
        if recipient.twitter != nil {
            recipientActions.append(Action(type: .Tweet))
        }
        if recipient.facebook != nil {
            recipientActions.append(Action(type: .Facebook))
        }
        if recipient.phone != nil {
            recipientActions.append(Action(type: .Call))
        }
        let recipientRow = LogisticsRow(
            circleImageUrl: recipient.photoUrl,
            circleText: nil,
            circleSubscript: nil,
            titleText: recipient.displayName,
            subtitleText: String(NSLocalizedString("label.recipient", comment: "recipient label title")),
            tint: getTintForCategory(category: createPackageCoordinator.category!),
            actions: recipientActions,
            type: .Person
        )
        rows.append(recipientRow)
        
        // time
        
        let dueDateFormatter = DateFormatter()
        dueDateFormatter.dateStyle = .short
        dueDateFormatter.timeStyle = .short

        // Use the configured formatter to generate the string.
        let dueDateString = dueDateFormatter.string(from: packageDueDate)
        
        let timeRow = LogisticsRow(
            circleImageUrl: nil,
            circleText: nil,
            circleSubscript: nil,
            titleText: dueDateString,
            subtitleText: String(NSLocalizedString("label.dueDate", comment: "label text for due date")),
            tint: getTintForCategory(category: createPackageCoordinator.category!),
            actions: nil,
            type: .Time
        )
        rows.append(timeRow)
        
        // distance
        let distanceLeftformatter = MeasurementFormatter()
        distanceLeftformatter.unitStyle = .long
        distanceLeftformatter.unitOptions = .naturalScale
        distanceLeftformatter.numberFormatter.maximumFractionDigits = 2
        
        let distanceTotal = CLLocation(latitude: originCoordinate.latitude, longitude: originCoordinate.longitude).distance(from: CLLocation(latitude: destinationCoordinate.latitude, longitude: destinationCoordinate.longitude))
        
        let distanceLeft = Measurement(value: distanceTotal, unit: UnitLength.meters)
        
        let totalDistanceformatter = MeasurementFormatter()
        totalDistanceformatter.unitStyle = .long
        totalDistanceformatter.unitOptions = .naturalScale
        totalDistanceformatter.numberFormatter.maximumFractionDigits = 2
        
        let totalDistanceString = totalDistanceformatter.string(from: distanceLeft)
        
        let distanceRow = LogisticsRow(
            circleImageUrl: nil,
            circleText: nil,
            circleSubscript: nil,
            titleText: totalDistanceString,
            subtitleText: String(NSLocalizedString("label.distance", comment: "label title for distance")),
            tint: getTintForCategory(category: createPackageCoordinator.category!),
            actions: nil,
            type: .Directions
        )
        rows.append(distanceRow)
        
        // sender
        let senderRow = LogisticsRow(
            circleImageUrl: sender.photoUrl,
            circleText: nil,
            circleSubscript: nil,
            titleText: sender.displayName,
            subtitleText: String(NSLocalizedString("label.sender", comment: "label title for sender")),
            tint: getTintForCategory(category: createPackageCoordinator.category!),
            actions: nil,
            type: .Person
        )
        rows.append(senderRow)
        
        return rows
    }
    
    @objc private func didTapCallButton(sender: UIButton) {
        print("call")
        self.recipient.phone!.makeAColl()
    }
    
    @objc private func didTapTweetButton(sender: UIButton) {
        print("tweet")
        let twitterHandle = self.recipient.twitter!.components(separatedBy: "/").last!
        let twUrl = URL(string: "twitter://user?screen_name=\(twitterHandle)")!
        let twUrlWeb = URL(string: "https://www.twitter.com/\(twitterHandle)")!
        if UIApplication.shared.canOpenURL(twUrl){
            UIApplication.shared.open(twUrl, options: [:],completionHandler: nil)
        }else{
            UIApplication.shared.open(twUrlWeb, options: [:], completionHandler: nil)
        }
    }
    
    @objc private func didTapFacebookButton(sender: UIButton) {
        print("facebook")
        let facebookLink = URL(string: self.recipient.facebook!)!
        UIApplication.shared.open(facebookLink, options: [:], completionHandler: nil)
    }
    
    @objc private func didTapMoreButton(sender: UIButton) {
        print("more")
    }

}

extension CreatePackageReviewViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

