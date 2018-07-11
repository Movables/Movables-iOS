//
//  CreateConversationTypeSelectViewController.swift
//  Movables
//
//  Created by Eddie Chen on 7/3/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit

class CreateConversationTypeSelectViewController: UIViewController {

    var createConversationCoordinator: CreateConversationCoordinator!
    
    var availableTypes: [CommunityType] = [.location, .group]
    var type: CommunityType?
    
    let CONTENT_INSET_TOP: CGFloat = UIApplication.shared.keyWindow!.safeAreaInsets.top
    let CONTENT_INSET_BOTTOM: CGFloat = UIApplication.shared.keyWindow!.safeAreaInsets.bottom + 30 + (UIDevice.isIphoneX ? 10 : 28)

    var tableView: UITableView!

    var instructionLabel: MCPill!
    var floatingButtonsContainerView: UIView!
    var cancelButtonBaseView: UIView!
    var cancelButton: UIButton!
    var bottomConstraintFAB: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: false)

        setupTableView()
        setupFAB()

    }

    private func setupFAB() {
        
        floatingButtonsContainerView = UIView(frame: .zero)
        floatingButtonsContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(floatingButtonsContainerView)
        
        cancelButtonBaseView = UIView(frame: .zero)
        cancelButtonBaseView.translatesAutoresizingMaskIntoConstraints = false
        cancelButtonBaseView.layer.shadowColor = UIColor.black.cgColor
        cancelButtonBaseView.layer.shadowOpacity = 0.3
        cancelButtonBaseView.layer.shadowRadius = 14
        cancelButtonBaseView.layer.shadowOffset = CGSize(width: 0, height: 0)
        floatingButtonsContainerView.addSubview(cancelButtonBaseView)
        
        cancelButton = UIButton(frame: .zero)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setImage(UIImage(named: "round_close_black_50pt"), for: .normal)
        cancelButton.tintColor = .white
        cancelButton.setBackgroundColor(color: Theme().grayTextColor, forUIControlState: .normal)
        cancelButton.setBackgroundColor(color: Theme().grayTextColorHighlight, forUIControlState: .highlighted)
        cancelButton.contentEdgeInsets = .zero
        cancelButton.layer.cornerRadius = 25
        cancelButton.clipsToBounds = true
        cancelButton.addTarget(self, action: #selector(didTapCancelButton(sender:)), for: .touchUpInside)
        cancelButton.isEnabled = true
        cancelButtonBaseView.addSubview(cancelButton)
        
        let cancelHConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[cancelButton(50)]|", options: .directionLeadingToTrailing, metrics: nil, views: ["cancelButton": cancelButton])
        cancelButtonBaseView.addConstraints(cancelHConstraints)
        let cancelVConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[cancelButton(50)]|", options: .alignAllTrailing, metrics: nil, views: ["cancelButton": cancelButton])
        cancelButtonBaseView.addConstraints(cancelVConstraints)
        
        let containerViewCenterXConstraint = NSLayoutConstraint(item: floatingButtonsContainerView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        view.addConstraint(containerViewCenterXConstraint)
        
        let hBaseViewsConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[cancelButtonBaseView(50)]|", options: [.alignAllTop, .alignAllBottom], metrics: nil, views: ["cancelButtonBaseView": cancelButtonBaseView])
        let vBaseViewsConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[cancelButtonBaseView(50)]|", options: [.alignAllTop, .alignAllBottom], metrics: nil, views: ["cancelButtonBaseView": cancelButtonBaseView])
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
        tableView.contentInset.top = CONTENT_INSET_TOP
        tableView.contentInset.bottom = CONTENT_INSET_BOTTOM
        tableView.register(LargeTitleWithSubtitleTableViewCell.self, forCellReuseIdentifier: "typeItem")
        view.addSubview(tableView)
        
        instructionLabel = MCPill(frame: .zero, character: "\(self.navigationController!.childViewControllers.count)", image: nil, body: String(NSLocalizedString("label.selectConversationType", comment: "label text for select conversatino type")), color: .white)
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
    
    @objc private func didTapCancelButton(sender: UIButton) {
        createConversationCoordinator.cancelConversationCreation(created: false)
        print("backed")
    }
}


extension CreateConversationTypeSelectViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
         return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "typeItem") as! LargeTitleWithSubtitleTableViewCell
        let type = availableTypes[indexPath.row]
        cell.largeTitleLabel.text = getStringForCommunityType(type: type)
        cell.subtitleLabel.text = getDescriptionForCommunityType(type: type)
        return cell
    }
}

extension CreateConversationTypeSelectViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        let selectedType = availableTypes[indexPath.row]
        if selectedType == .location {
            createConversationCoordinator.type = selectedType
            createConversationCoordinator.showLegislativeAreaSelectVC()
        } else {
            let alertController = UIAlertController(title: String(NSLocalizedString("copy.alert.privateConversation", comment: "alert copy for private conversation")), message: nil, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: String(NSLocalizedString("button.ok", comment: "button title for OK")), style: .default, handler: { (action) in
                self.createConversationCoordinator.cancelConversationCreation(created: false)
            }))
            present(alertController, animated: true, completion: nil)
        }
        
    }
}
