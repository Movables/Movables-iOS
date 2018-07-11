//
//  CreatePackageTemplatesViewController.swift
//  Movables
//
//  Created by Chun-Wei Chen on 6/12/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import MapKit
import NVActivityIndicatorView

class CreatePackageTemplatesViewController: UIViewController {

    let CONTENT_INSET_TOP: CGFloat = UIApplication.shared.keyWindow!.safeAreaInsets.top
    let CONTENT_INSET_BOTTOM: CGFloat = UIApplication.shared.keyWindow!.safeAreaInsets.bottom + 30 + (UIDevice.isIphoneX ? 10 : 28)
    
    var createPackageCoordinator: CreatePackageCoordinator!
    var templates: [PackageTemplate] = []
    var tableView: UITableView!
    
    var instructionLabel: MCPill!
    var floatingButtonsContainerView: UIView!
    var backButtonBaseView: UIView!
    var backButton: UIButton!
    var bottomConstraintFAB: NSLayoutConstraint!
    var activityIndicatorView: NVActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupFAB()
    navigationController?.interactivePopGestureRecognizer?.delegate = self
    navigationController?.interactivePopGestureRecognizer?.isEnabled = true

        
        fetchTemplates()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.contentInset.top = CONTENT_INSET_TOP
        tableView.contentInset.bottom = CONTENT_INSET_BOTTOM
        tableView.contentOffset.y = -CONTENT_INSET_TOP
        tableView.backgroundColor = Theme().backgroundShade
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TemplateCardTableViewCell.self, forCellReuseIdentifier: "templateCard")
        tableView.register(ListViewButtonTableViewCell.self, forCellReuseIdentifier: "buttonCell")
        view.addSubview(tableView)

        instructionLabel = MCPill(frame: .zero, character: "\(self.navigationController!.childViewControllers.count)", image: nil, body: "#\(createPackageCoordinator.tagResultItem!.tag)", color: .white)
        instructionLabel.bodyLabel.textColor = Theme().textColor
        instructionLabel.circleMask.backgroundColor = Theme().textColor
        instructionLabel.characterLabel.textColor = .white
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(instructionLabel)
        
        activityIndicatorView = NVActivityIndicatorView(frame: .zero, type: .ballScale, color: Theme().textColor, padding: 0)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.startAnimating()
        tableView.backgroundView = activityIndicatorView

        
        NSLayoutConstraint.activate([
            instructionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            instructionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6),
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
    
    private func fetchTemplates() {
        let tag = createPackageCoordinator.tagResultItem!.tag
        
        Firestore.firestore().collection("topics").whereField("tag", isEqualTo: tag).limit(to: 1).getDocuments { (querySnapshot, error) in
            if let error = error {
                print(error)
            } else {
                if querySnapshot != nil {
                    for document in querySnapshot!.documents {
                        let topicReference = document.reference
                        topicReference.collection("templates").whereField("due_date.end", isGreaterThan: Timestamp(date: Date())).order(by: "due_date.end", descending: false).order(by: "count.packages", descending: true).getDocuments(completion: { (querySnapshot, error) in
                            if let error = error {
                                print(error)
                            }
                            if querySnapshot != nil {
                                for document in querySnapshot!.documents {
                                    self.templates.append(PackageTemplate(snapshot: document))
                                }
                                self.activityIndicatorView.stopAnimating()
                                self.tableView.reloadData()
                            }
                        })
                    }
                }
            }
        }
    }
    
    @objc private func didTapBackButton(sender: UIButton) {
        createPackageCoordinator.unwind()
        print("backed")
    }
}

extension CreatePackageTemplatesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : self.templates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "templateCard") as! TemplateCardTableViewCell
            let template = self.templates[indexPath.row]
            cell.headlineLabel.text = template.headline
            cell.authorLabel.text = String(format: NSLocalizedString("label.templateBy", comment: "label text for template by"), template.templateBy!.displayName)
            cell.descriptionLabel.text = template.description
            cell.recipientImageView.sd_setImage(with: URL(string: template.recipient.photoUrl!)) { (image, error, cacheType, url) in
                print("loaded image")
            }
            cell.recipientLabel.text = template.recipient.displayName
            cell.destinationLabel.text = "\(template.destination.name!)"
            cell.usageLabel.text = template.count?.packages == nil || template.count!.packages! > 1 ? String(format: NSLocalizedString("label.usedInPackagesPlural", comment: "label text for template usage count"), template.count?.packages ?? 0) : String(format: NSLocalizedString("label.usedInPackage", comment: "label text for singular template usage count"), template.count!.packages!)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "buttonCell") as! ListViewButtonTableViewCell
            cell.button.setTitle(String(NSLocalizedString("button.createNewPackage", comment: "button title for create new package")), for: .normal)
            cell.button.addTarget(self, action: #selector(useCustom), for: .touchUpInside)
            return cell
        }
    }
    
    @objc private func useCustom() {
        createPackageCoordinator.pushToCategory()
    }
    
    @objc private func didTapPreviewButton(sender: UIButton) {
        guard let cell = sender.superview?.superview as? TemplateCardTableViewCell else {
            return // or fatalError() or whatever
        }
        
        let indexPath = tableView.indexPath(for: cell)
        let template = self.templates[indexPath!.row]
        useTemplate(with: template)
    }
}

extension CreatePackageTemplatesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let template = templates[indexPath.row]
            useTemplate(with: template)
        } else {
            useCustom()
        }
    }
    
    private func useTemplate(with template: PackageTemplate) {
        
        // fetch external actions
        
        template.reference.collection("external_actions").getDocuments { (querySnapshot, error) in
            if let error = error {
                print(error)
                return
            } else {
                guard let snapshot = querySnapshot else { return }
                var externalActionsTemp:[ExternalAction] = []
                snapshot.documents.forEach({ (docSnapshot) in
                    externalActionsTemp.append(ExternalAction(dict: docSnapshot.data()))
                })
                self.createPackageCoordinator.externalActions = externalActionsTemp
                self.createPackageCoordinator.recipientResultItem = RecipientResultItem(name: template.recipient.displayName, picUrl: template.recipient.photoUrl, position: template.destination.name)
                self.createPackageCoordinator.destinationResultItem = DestinationResultItem(name: template.destination.name, placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: template.destination.geoPoint.latitude, longitude: template.destination.geoPoint.longitude)))
                self.createPackageCoordinator.category = template.categories.first
                self.createPackageCoordinator.packageCoverPhotoImage = nil
                self.createPackageCoordinator.packageDueDate = template.dueDate!.end!
                self.createPackageCoordinator.packageHeadline = template.headline
                self.createPackageCoordinator.packageDescription = template.description
                self.createPackageCoordinator.usingTemplate = true
                self.createPackageCoordinator.template = template
                self.createPackageCoordinator.dropoffMessage = template.dropoffMessage
                self.createPackageCoordinator.setContentAndPushToReview(promptTemplate: false, coverImageUrl: URL(string: template.coverImageUrl!))
            }
        }
    }
}

extension CreatePackageTemplatesViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

