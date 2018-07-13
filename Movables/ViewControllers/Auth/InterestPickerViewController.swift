//
//  InterestPickerViewController.swift
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

class InterestPickerViewController: UIViewController {

    var authCoordinator: AuthCoordinator!
    
    let CONTENT_INSET_TOP: CGFloat = UIApplication.shared.keyWindow!.safeAreaInsets.top
    let CONTENT_INSET_BOTTOM: CGFloat = UIApplication.shared.keyWindow!.safeAreaInsets.bottom + 30 + (UIDevice.isIphoneX ? 10 : 28)
    
    var tableView: UITableView!
    var instructionLabel: MCPill!
    
    var floatingButtonsContainerView: UIView!
    var setButtonBaseView: UIView!
    var setButton: UIButton!
    var bottomConstraintFAB: NSLayoutConstraint!
    
    var categories: [PackageCategory] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        setupTableView()
        setupFAB()
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
    }
    
    private func setupFAB() {
        floatingButtonsContainerView = UIView(frame: .zero)
        floatingButtonsContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(floatingButtonsContainerView)
        
        setButtonBaseView = UIView(frame: .zero)
        setButtonBaseView.translatesAutoresizingMaskIntoConstraints = false
        setButtonBaseView.layer.shadowColor = UIColor.black.cgColor
        setButtonBaseView.layer.shadowOpacity = 0.3
        setButtonBaseView.layer.shadowRadius = 14
        setButtonBaseView.layer.shadowOffset = CGSize(width: 0, height: 0)
        floatingButtonsContainerView.addSubview(setButtonBaseView)
        
        setButton = UIButton(frame: .zero)
        setButton.translatesAutoresizingMaskIntoConstraints = false
        setButton.setImage(UIImage(named: "round_done_black_24pt"), for: .normal)
        setButton.tintColor = .white
        setButton.setBackgroundColor(color: Theme().grayTextColor, forUIControlState: .normal)
        setButton.setBackgroundColor(color: Theme().grayTextColorHighlight, forUIControlState: .highlighted)
        setButton.contentEdgeInsets = .zero
        setButton.layer.cornerRadius = 25
        setButton.clipsToBounds = true
        setButton.addTarget(self, action: #selector(didTapSetButton(sender:)), for: .touchUpInside)
        setButton.isEnabled = true
        setButtonBaseView.addSubview(setButton)
        
        let backHConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[setButton(50)]|", options: .directionLeadingToTrailing, metrics: nil, views: ["setButton": setButton])
        setButtonBaseView.addConstraints(backHConstraints)
        let backVConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[setButton(50)]|", options: .alignAllTrailing, metrics: nil, views: ["setButton": setButton])
        setButtonBaseView.addConstraints(backVConstraints)
        
        let containerViewCenterXConstraint = NSLayoutConstraint(item: floatingButtonsContainerView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        view.addConstraint(containerViewCenterXConstraint)
        
        let hBaseViewsConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[setButtonBaseView]|", options: [.alignAllTop, .alignAllBottom], metrics: nil, views: ["setButtonBaseView": setButtonBaseView])
        let vBaseViewsConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[setButtonBaseView]|", options: [.alignAllTop, .alignAllBottom], metrics: nil, views: ["setButtonBaseView": setButtonBaseView])
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
        
        instructionLabel = MCPill(frame: .zero, character: "1", image: nil, body: "What Are Your Passions?", color: .white)
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
    
    @objc private func didTapSetButton(sender: UIButton) {
        // save interests then show main
        print("save interests then show main")
        var interestsDictionary:[String: Bool] = [:]
        for category in self.categories {
            interestsDictionary.updateValue(true, forKey: getStringForCategory(category: category))
        }
        fetchUserDoc(uid: Auth.auth().currentUser!.uid) { (userDoc) in
            userDoc?.reference.updateData(["private_profile.interests": interestsDictionary], completion: { (error) in
                if let error = error {
                    print(error)
                } else {
                    // show main
                    self.authCoordinator.delegate?.coordinatorDidAuthenticate(with: nil)
                }
            })
        }
    }

}

extension InterestPickerViewController: UITableViewDataSource {
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
        cell.titleLabel.textColor = categories.contains(category) ? getTintForCategory(category: category) : Theme().textColor
        return cell
    }
}

extension InterestPickerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected \(indexPath)")
        let category = packageCategoriesEnumArray[indexPath.row]
        if !categories.contains(category) {
            categories.append(category)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let category = packageCategoriesEnumArray[indexPath.row]
        if categories.contains(category) {
            categories.remove(at: categories.index(of: category)!)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

extension InterestPickerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
