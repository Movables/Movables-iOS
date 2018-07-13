//
//  DropoffSummaryViewController.swift
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
import Firebase
import CoreLocation
import SafariServices

protocol DropoffSummaryViewControllerDelegate: class {
    func showPostComposerVC()
}

class DropoffSummaryViewController: UIViewController {
    
    var package: Package!
    var transitRecord: TransitRecord?
    var response: [String: Any]!
    var layout: UICollectionViewFlowLayout!
    var collectionView: UICollectionView!
    var movementRouteDrawn: Bool = false
    var userDocument: UserDocument!
    var actions: [ExternalAction] = []
    
    var floatingButtonsContainerView: UIView!
    var doneButtonBaseView: UIView!
    var doneButton: UIButton!
    var bottomConstraintFAB: NSLayoutConstraint!
    
    var transitRecordListener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.width, height: 100)
        layout.minimumLineSpacing = 10
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset.top = UIApplication.shared.keyWindow!.safeAreaInsets.top + 20
        collectionView.alwaysBounceVertical = true
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.contentInset.bottom = UIApplication.shared.keyWindow!.safeAreaInsets.bottom + 50 + (UIDevice.isIphoneX ? 10 : 28)
        collectionView.scrollIndicatorInsets.bottom = UIApplication.shared.keyWindow!.safeAreaInsets.bottom + 50 + (UIDevice.isIphoneX ? 10 : 28)
        collectionView.register(HeaderLabelCollectionViewCell.self, forCellWithReuseIdentifier: "headerLabelCell")
        collectionView.register(MCRouteSummaryCollectionViewCell.self, forCellWithReuseIdentifier: "routeSummaryCell")
        collectionView.register(MCHeroStatusCollectionViewCell.self, forCellWithReuseIdentifier: "heroStatusCell")
        collectionView.register(MCParagraphActionsCollectionViewCell.self, forCellWithReuseIdentifier: "paragraphActionsCell")
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        floatingButtonsContainerView = UIView(frame: .zero)
        floatingButtonsContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(floatingButtonsContainerView)
        
        doneButtonBaseView = UIView(frame: .zero)
        doneButtonBaseView.translatesAutoresizingMaskIntoConstraints = false
        doneButtonBaseView.layer.shadowColor = UIColor.black.cgColor
        doneButtonBaseView.layer.shadowOpacity = 0.3
        doneButtonBaseView.layer.shadowRadius = 14
        doneButtonBaseView.layer.shadowOffset = CGSize(width: 0, height: 0)
        floatingButtonsContainerView.addSubview(doneButtonBaseView)
        
        doneButton = UIButton(frame: .zero)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        doneButton.setBackgroundColor(color: getTintForCategory(category: self.package.categories.first!), forUIControlState: .normal)
        doneButton.setBackgroundColor(color: getTintForCategory(category: self.package.categories.first!).withAlphaComponent(0.85), forUIControlState: .highlighted)
        doneButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        doneButton.layer.cornerRadius = 25
        doneButton.clipsToBounds = true
        doneButton.addTarget(self, action: #selector(didTapDoneButton(sender:)), for: .touchUpInside)
        doneButton.isEnabled = true
        doneButtonBaseView.addSubview(doneButton)
        
        let doneHeightConstraint = NSLayoutConstraint(item: self.doneButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)
        doneButtonBaseView.addConstraint(doneHeightConstraint)
        let doneHConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[doneButton]|", options: .directionLeadingToTrailing, metrics: nil, views: ["doneButton": doneButton])
        doneButtonBaseView.addConstraints(doneHConstraints)
        let doneVConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[doneButton]|", options: .alignAllTrailing, metrics: nil, views: ["doneButton": doneButton])
        doneButtonBaseView.addConstraints(doneVConstraints)
        
        let containerViewCenterXConstraint = NSLayoutConstraint(item: floatingButtonsContainerView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        view.addConstraint(containerViewCenterXConstraint)
        
        let hBaseViewsConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[doneButtonBaseView]|", options: [.alignAllTop, .alignAllBottom], metrics: nil, views: ["doneButtonBaseView": doneButtonBaseView])
        let vBaseViewsConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[doneButtonBaseView(50)]|", options: [.alignAllTop, .alignAllBottom], metrics: nil, views: ["doneButtonBaseView": doneButtonBaseView])
        floatingButtonsContainerView.addConstraints(hBaseViewsConstraints + vBaseViewsConstraints)
        
        bottomConstraintFAB = NSLayoutConstraint(item: self.floatingButtonsContainerView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 100)
        view.addConstraint(bottomConstraintFAB)

        listenToTransitRecord()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        transitRecordListener?.remove()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func didTapDoneButton(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension DropoffSummaryViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "headerLabelCell", for: indexPath) as! HeaderLabelCollectionViewCell
            cell.label.text = "Dropoff Summary"
            cell.label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
            return cell
        } else if indexPath.item == 1 {
            // optional dropoff action
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "paragraphActionsCell", for: indexPath) as! MCParagraphActionsCollectionViewCell
            cell.paragraphLabel.text = package.dropoffMessage ?? ""
            cell.actions = self.actions
            cell.activateStackView()
            for row in cell.actionsStackView.arrangedSubviews {
                var button: UIButton!
                for subview in row.subviews {
                    if subview.isKind(of: UIButton.self) {
                        button = subview as! UIButton
                    }
                }
                button.setBackgroundColor(color: getTintForCategory(category: self.package.categories.first!), forUIControlState: .normal)
                button.setBackgroundColor(color: getTintForCategory(category: self.package.categories.first!).withAlphaComponent(0.85), forUIControlState: .highlighted)
                button.addTarget(self, action: #selector(didTapOnExternalLinkButton(sender:)), for: .touchUpInside)
            }
            return cell
        } else if indexPath.item == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "routeSummaryCell", for: indexPath) as! MCRouteSummaryCollectionViewCell
            cell.presentingVC = self
            cell.transitRecord = self.transitRecord
            if !movementRouteDrawn {
                cell.activateMapView()
            }
            let units = generateLogisticsRowsForDropoffSummary()
            if cell.contentStackView.arrangedSubviews.count != units.count {
                cell.units = units
                cell.activateStackView()
            }
            // route map without user location, showing pickup & dropoff/deliver, and routes with all movements
            return cell
        } else if indexPath.item == 3 {
            // post prompt
            return UICollectionViewCell()
        } else if indexPath.item == 4 {
            // thunderclap commitment card
            return UICollectionViewCell()
        } else {
            // dismiss
            return UICollectionViewCell()
        }
    }
    
    @objc private func didTapOnExternalLinkButton(sender: UIButton){
        print("tapped on go button")
        print("action tapped is \(self.actions[sender.tag])")
        let action = self.actions[sender.tag]
        let safariVC = SFSafariViewController(url: URL(string: action.webLink!)!)
        navigationController?.present(safariVC, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // route summary
        // time bank changes
        // post prompt
        // custom action prompt
        // amplify impact with thunderclap
        if self.transitRecord != nil {
            return 3
        } else {
            return 1
        }
    }
    
    func generateLogisticsRowsForDropoffSummary() -> [LogisticsRow] {
        var rows:[LogisticsRow] = []
        // distance moved
        let pickupCL = CLLocation(latitude: transitRecord!.pickupGeoPoint!.latitude, longitude: transitRecord!.pickupGeoPoint!.longitude)
        let dropoffCL = CLLocation(latitude: transitRecord!.dropoffGeoPoint!.latitude, longitude: transitRecord!.dropoffGeoPoint!.longitude)
        let destinationCL = CLLocation(latitude: self.package.destination.geoPoint.latitude, longitude: self.package.destination.geoPoint.longitude)
        let distanceMoved = destinationCL.distance(from: pickupCL) - destinationCL.distance(from: dropoffCL)
        
        let distanceMovedformatter = MeasurementFormatter()
        distanceMovedformatter.unitStyle = .long
        distanceMovedformatter.unitOptions = .naturalScale
        distanceMovedformatter.numberFormatter.maximumFractionDigits = 2
        
        let distanceMovedMeters = Measurement(value: distanceMoved, unit: UnitLength.meters)
        let distanceMovedString = distanceMovedformatter.string(from: distanceMovedMeters)

        let distanceMovedRow = LogisticsRow(circleImageUrl: nil, circleText: nil, circleSubscript: nil, titleText: distanceMovedString, subtitleText: "Distance Moved".uppercased(), tint: getTintForCategory(category: self.package.categories.first!), actions: nil, type: .Directions)
        
        rows.append(distanceMovedRow)
        
        // time elapsed, credits earned, current balance
        let timeLeftformatter = DateComponentsFormatter()
        timeLeftformatter.unitsStyle = .full
        timeLeftformatter.includesApproximationPhrase = false
        timeLeftformatter.includesTimeRemainingPhrase = false
        timeLeftformatter.allowedUnits = [.day, .hour, .minute]
        
        // Use the configured formatter to generate the string.
        let timeElapsed = transitRecord!.dropoffDate!.timeIntervalSince1970 - transitRecord!.pickupDate!.timeIntervalSince1970
        let timeLeftString = timeLeftformatter.string(from: timeElapsed)!
        
        let timeRow = LogisticsRow(
            circleImageUrl: nil,
            circleText: nil,
            circleSubscript: nil,
            titleText: "\(timeLeftString)",
            subtitleText: String(NSLocalizedString("label.timeElapsed", comment: "label text for time elapsed")),
            tint: getTintForCategory(category: self.package.categories.first!),
            actions: nil,
            type: .Time
        )
        rows.append(timeRow)
        let awardRow = LogisticsRow(
            circleImageUrl: nil,
            circleText: nil,
            circleSubscript: nil,
            titleText: "\(response["credits_earned"] as! Double)",
            subtitleText: String(NSLocalizedString("label.creditsEarned", comment: "label text for credits earned")),
            tint: getTintForCategory(category: self.package.categories.first!),
            actions: nil,
            type: .Award
        )
        rows.append(awardRow)
        
        // delivery bonus row
        if response["delivered"] as! Bool {
            let bonusRow = LogisticsRow(
                circleImageUrl: nil,
                circleText: nil,
                circleSubscript: nil,
                titleText: "\(response["delivery_bonus"] as! Double)",
                subtitleText: String(NSLocalizedString("label.deliveryBonus", comment: "label text for delivery bonus")),
                tint: getTintForCategory(category: self.package.categories.first!),
                actions: nil,
                type: .Award
            )
            rows.append(bonusRow)
        }
        // end delivery bonus row
        
        let balanceRow = LogisticsRow(
            circleImageUrl: nil,
            circleText: nil,
            circleSubscript: nil,
            titleText: "\(response["new_balance"] as! Double)",
            subtitleText: String(NSLocalizedString("creditsTotal", comment: "label text for credits total")),
            tint: getTintForCategory(category: self.package.categories.first!),
            actions: nil,
            type: .Balance
        )
        rows.append(balanceRow)

        return rows
    }
    
    func listenToTransitRecord() {
//        transitRecordListener = self.package.reference.collection("transit_records").document(Auth.auth().currentUser!.uid).addSnapshotListener({ (documentSnapshot, error) in
        self.package.reference.collection("transit_records").document(Auth.auth().currentUser!.uid).getDocument(source: .server) { (documentSnapshot, error) in
            guard documentSnapshot != nil else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            self.transitRecord = TransitRecord(dict: documentSnapshot!.data()!, reference: documentSnapshot!.reference)
            self.fetchMovements()
        }
    }
    
    func fetchMovements() {
        self.transitRecord?.reference.collection("movements").getDocuments(source: .default, completion: { (querySnapshot, error) in
            if let error = error {
                print(error)
            } else {
                if querySnapshot != nil {
                    var movements: [TransitMovement] = []
                    querySnapshot!.documents.forEach({ (snapshot) in
                        let dict = snapshot.data()
                        movements.append(TransitMovement(date: (dict["date"] as! Timestamp).dateValue(), geoPoint: dict["geo_point"] as! GeoPoint))
                    })
                    self.transitRecord?.movements = movements
                }
                // update views
                if self.transitRecord?.dropoffDate != nil {
                    self.package.reference.collection("external_actions").getDocuments(completion: { (querySnapshot, error) in
                        if let error = error {
                            print(error)
                        } else {
                            guard let snapshot = querySnapshot else {
                                return
                            }
                            var actions: [ExternalAction] = []
                            snapshot.documents.forEach({ (docSnapshot) in
                                actions.append(ExternalAction(dict: docSnapshot.data()))
                            })
                            self.actions = actions
                            self.collectionView.reloadData()
//                            UIView.animate(withDuration: 0.35) {
                                self.bottomConstraintFAB.constant = -(self.view.safeAreaInsets.bottom + 50 + (UIDevice.isIphoneX ? 0 : 18))
                                self.view.layoutIfNeeded()
//                            }
                        }
                    })
                }
            }
        })
    }    
}

extension DropoffSummaryViewController: UICollectionViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if scrollView.contentOffset.y < -100 {
//            dismiss(animated: true, completion: nil)
        }
    }
}
