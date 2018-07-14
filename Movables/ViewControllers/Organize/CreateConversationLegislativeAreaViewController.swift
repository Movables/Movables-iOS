//
//  CreateConversationLegislativeAreaViewController.swift
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
import Firebase

class CreateConversationLegislativeAreaViewController: UIViewController {

    var createConversationCoordinator: CreateConversationCoordinator!
    
    let CONTENT_INSET_TOP: CGFloat = UIApplication.shared.keyWindow!.safeAreaInsets.top != 0 ? UIApplication.shared.keyWindow!.safeAreaInsets.top: 45.5
    let CONTENT_INSET_BOTTOM: CGFloat = UIApplication.shared.keyWindow!.safeAreaInsets.bottom != 0 ? UIApplication.shared.keyWindow!.safeAreaInsets.bottom + 30 + 10 : 34 + 30 + 28

    var tableView: UITableView!
    var instructionLabel: MCPill!
    
    var floatingButtonsContainerView: UIView!
    var backButtonBaseView: UIView!
    var backButton: UIButton!
    var bottomConstraintFAB: NSLayoutConstraint!
    
    var legislativeAreas: [(String, String)]? {
        didSet {
            self.tableView.reloadData()
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: false)
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        setupTableView()
        setupFAB()
        
        fetchAddressInfo()
    }

    private func setupFAB() {
        floatingButtonsContainerView = UIView(frame: .zero)
        floatingButtonsContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(floatingButtonsContainerView)
        
        backButtonBaseView = UIView(frame: .zero)
        backButtonBaseView.translatesAutoresizingMaskIntoConstraints = false
        backButtonBaseView.layer.shadowColor = UIColor.black.cgColor
        backButtonBaseView.layer.shadowOpacity = 0.3
        backButtonBaseView.layer.shadowRadius = 14
        backButtonBaseView.layer.shadowOffset = CGSize(width: 0, height: 0)
        floatingButtonsContainerView.addSubview(backButtonBaseView)
        
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
        
        let containerViewCenterXConstraint = NSLayoutConstraint(item: floatingButtonsContainerView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        view.addConstraint(containerViewCenterXConstraint)
        
        let hBaseViewsConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[backButtonBaseView]|", options: [.alignAllTop, .alignAllBottom], metrics: nil, views: ["backButtonBaseView": backButtonBaseView])
        let vBaseViewsConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[backButtonBaseView]|", options: [.alignAllTop, .alignAllBottom], metrics: nil, views: ["backButtonBaseView": backButtonBaseView])
        floatingButtonsContainerView.addConstraints(hBaseViewsConstraints + vBaseViewsConstraints)
        
        bottomConstraintFAB = NSLayoutConstraint(item: self.floatingButtonsContainerView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: -(UIApplication.shared.keyWindow!.safeAreaInsets.bottom + 50 + (UIDevice.isIphoneX ? 0 : 18)))
        view.addConstraint(bottomConstraintFAB)
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 88
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = Theme().backgroundShade
        tableView.register(LargeTitleWithSubtitleTableViewCell.self, forCellReuseIdentifier: "legislativeAreaItem")
        tableView.contentInset.top = CONTENT_INSET_TOP
        tableView.contentInset.bottom = CONTENT_INSET_BOTTOM
        tableView.contentOffset.y = -CONTENT_INSET_TOP
        view.addSubview(tableView)
        
        instructionLabel = MCPill(frame: .zero, character: "\(self.navigationController!.childViewControllers.count)", image: nil, body: "Select a Legislative Area", color: .white)
        instructionLabel.bodyLabel.textColor = Theme().textColor
        instructionLabel.circleMask.backgroundColor = Theme().textColor
        instructionLabel.characterLabel.textColor = .white
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(instructionLabel)
        
        
        NSLayoutConstraint.activate([
            instructionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            instructionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6),
            tableView.heightAnchor.constraint(equalTo: view.heightAnchor),
            tableView.widthAnchor.constraint(equalTo: view.widthAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func didTapBackButton(sender: UIButton) {
        createConversationCoordinator.unwind()
        print("backed")
    }
    
    func fetchAddressInfo() {
        LocationManager.shared.desiredAccuracy = kCLLocationAccuracyHundredMeters
        LocationManager.shared.requestLocation()
        let location = LocationManager.shared.location
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location!) { (placemarks, error) in
            if let error = error {
                print(error)
                return
            } else {
                if placemarks != nil && placemarks!.count > 0 {
                    self.legislativeAreas = generateLegislativeAreasTuples(for: placemarks!.first!)
                } else {
                    print("cannot find placemark")
                }
                
            }
            
        }
    }
}

func generateLegislativeAreasTuples(for placemark: CLPlacemark) -> [(String, String)] {
    var legislativeAreasTemp: [(String, String)] = []
    if placemark.country != nil {
        legislativeAreasTemp.append(("country", placemark.country!))
    }
    if placemark.administrativeArea != nil {
        legislativeAreasTemp.append(("administrative_area", placemark.administrativeArea!))
    }
    if placemark.subAdministrativeArea != nil {
        legislativeAreasTemp.append(("sub_administrative_area", placemark.subAdministrativeArea!))
    }
    if placemark.locality != nil {
        legislativeAreasTemp.append(("locality", placemark.locality!))
    }
    if placemark.subLocality != nil {
        legislativeAreasTemp.append(("sub_locality", placemark.subLocality!))
    }
    return legislativeAreasTemp
}

func getReadableStringForLegislativeAreaString(string: String) -> String {
    switch string {
    case "country":
        return "Country"
    case "administrative_area":
        return "Aadministrative area"
    case "sub_administrative_area":
        return "Sub-administrative area"
    case "locality":
        return "Locality"
    case "sub_locality":
        return "Sub-locality"
    default:
        return "Unknown area"
    }
}

extension CreateConversationLegislativeAreaViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.legislativeAreas != nil ? self.legislativeAreas!.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "legislativeAreaItem") as! LargeTitleWithSubtitleTableViewCell
        let legislativeArea = legislativeAreas![indexPath.row]
        cell.largeTitleLabel.text = legislativeArea.1
        cell.subtitleLabel.text = getReadableStringForLegislativeAreaString(string: legislativeArea.0)
        return cell
    }
    
    func saveConversation() {
        
        let db = Firestore.firestore()
        // check if conversation exists for topic
        createConversationCoordinator.topic.reference.collection("conversations").whereField("legislative_area", isEqualTo: [createConversationCoordinator.legislativeArea!.1: createConversationCoordinator.legislativeArea!.0]).getDocuments { (querySnapshot, error) in
            if let error = error {
                print(error)
                return
            }
            if let snapshot = querySnapshot {
                if snapshot.documents.count > 0 {
                    print("conversation exists")
                } else {
                    db.runTransaction({ (transaction, errorPointer) -> Any? in
                        let conversationsReference = self.createConversationCoordinator.topic.reference.collection("conversations")
                        let newConversationRef = conversationsReference.document()
                        let newConversationData:[String: Any] = [
                            "legislative_area": [self.createConversationCoordinator.legislativeArea!.0: self.createConversationCoordinator.legislativeArea!.1],
                            "participants": [
                                Auth.auth().currentUser!.uid: Date().timeIntervalSince1970
                            ]
                        ]
                        transaction.setData(newConversationData, forDocument: newConversationRef)
                        return nil
                    }) { (object, error) in
                        if let error = error {
                            print("Error saving transaction package with error: \(error)")
                        }
                        // conversation created, dismiss this createConversationm, reload favorites community and then push to new conversation vc
                        self.createConversationCoordinator.cancelConversationCreation(created: true)
                    }
                }
            }
        }
    }
    
}

extension CreateConversationLegislativeAreaViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.isUserInteractionEnabled = false
        backButton.isEnabled = false
        createConversationCoordinator.legislativeArea = legislativeAreas![indexPath.row]
        self.saveConversation()
    }
}

extension CreateConversationLegislativeAreaViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
