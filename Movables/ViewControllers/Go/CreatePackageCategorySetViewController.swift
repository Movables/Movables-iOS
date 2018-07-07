//
//  CreatePackageCategorySetViewController.swift
//  Movables
//
//  Created by Eddie Chen on 6/14/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit

class CreatePackageCategorySetViewController: UIViewController {

    let CONTENT_INSET_TOP: CGFloat = UIApplication.shared.keyWindow!.safeAreaInsets.top
    let CONTENT_INSET_BOTTOM: CGFloat = UIApplication.shared.keyWindow!.safeAreaInsets.bottom + 30 + (UIDevice.isIphoneX ? 10 : 28)
    
    var createPackageCoordinator: CreatePackageCoordinator!
    var tableView: UITableView!
    var instructionLabel: MCPill!
    
    var floatingButtonsContainerView: UIView!
    var backButtonBaseView: UIView!
    var backButton: UIButton!
    var bottomConstraintFAB: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        setupTableView()
        setupFAB()
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
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
        tableView.register(CategoryLabelsTableViewCell.self, forCellReuseIdentifier: "categoryCell")
        tableView.contentInset.top = CONTENT_INSET_TOP
        tableView.contentInset.bottom = CONTENT_INSET_BOTTOM
        tableView.contentOffset.y = -CONTENT_INSET_TOP
        view.addSubview(tableView)
        
        instructionLabel = MCPill(frame: .zero, character: "\(self.navigationController!.childViewControllers.count)", image: nil, body: "Select a Category", color: .white)
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
        createPackageCoordinator.unwind()
        print("backed")
    }
}

extension CreatePackageCategorySetViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return packageCategoriesEnumArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell") as! CategoryLabelsTableViewCell
        let category = packageCategoriesEnumArray[indexPath.row]
        cell.categoryLabel.text = getEmojiForCategory(category: category)
        cell.titleLabel.text = getReadableStringForCategory(category: category)
        return cell
    }
}

extension CreatePackageCategorySetViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected \(indexPath)")
        createPackageCoordinator.category = packageCategoriesEnumArray[indexPath.row]
        createPackageCoordinator.pushToRecipient()
    }
}

extension CreatePackageCategorySetViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
