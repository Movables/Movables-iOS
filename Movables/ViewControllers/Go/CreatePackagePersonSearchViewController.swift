//
//  CreatePackageLogisticsViewController.swift
//  Movables
//
//  Created by Chun-Wei Chen on 6/12/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit
import AlgoliaSearch
import NVActivityIndicatorView

struct RecipientResultItem {
    var name: String
    var picUrl: String?
    var position: String?
    
    init(name: String, picUrl: String?, position: String?) {
        self.name = name
        self.picUrl = picUrl
        self.position = position
    }
}

class CreatePackagePersonSearchViewController: UIViewController {

    let CONTENT_INSET_TOP: CGFloat = UIApplication.shared.keyWindow!.safeAreaInsets.top + 39.5 + 12
    let CONTENT_INSET_BOTTOM: CGFloat = UIApplication.shared.keyWindow!.safeAreaInsets.bottom + 30 + (UIDevice.isIphoneX ? 10 : 28)
    
    var createPackageCoordinator: CreatePackageCoordinator!
    var textField: UITextField!
    var textFieldContainer: MCCard!
    var tableView: UITableView!
    var results:[RecipientResultItem] = []
    var activityIndicatorView: NVActivityIndicatorView!
    
    var instructionLabel: MCPill!
    var floatingButtonsContainerView: UIView!
    var backButtonBaseView: UIView!
    var backButton: UIButton!
    var bottomConstraintFAB: NSLayoutConstraint!
    
    var peopleIndex: Index!
    var query: Query = Query()
    
    var searchId = 0
    var displayedSearchId = -1
    var loadedPage: UInt = 0
    var nbPages: UInt = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        setupQuery()
        
        setupTableView()
        setupTextFieldView()
        setupFAB()
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true

        
        registerKeyboardNotifications()
        
        performQuery(with: "")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        textField.becomeFirstResponder()
    }
    
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardInfo = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
        let keyboardSize = keyboardInfo.cgRectValue.size
        let contentInsets = UIEdgeInsets(top: CONTENT_INSET_TOP, left: 0, bottom: keyboardSize.height - UIApplication.shared.keyWindow!.safeAreaInsets.bottom, right: 0)
        tableView.contentInset = contentInsets
        tableView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let normalInset = UIEdgeInsets(top: CONTENT_INSET_TOP, left: 0, bottom: CONTENT_INSET_BOTTOM, right: 0)
        tableView.contentInset = normalInset
        tableView.scrollIndicatorInsets = normalInset
        tableView.scrollIndicatorInsets.bottom = 0
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    
    private func setupQuery() {
        let apiClient = Client(appID: (UIApplication.shared.delegate as! AppDelegate).algoliaClientId!, apiKey: (UIApplication.shared.delegate as! AppDelegate).algoliaAPIKey!)
        
        peopleIndex = apiClient.index(withName: "people")
        query.hitsPerPage = 15
        query.attributesToRetrieve = ["name", "picUrl", "position"]
        query.attributesToHighlight = ["name"]
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
        tableView.contentInset.top = CONTENT_INSET_TOP
        tableView.contentInset.bottom = CONTENT_INSET_BOTTOM
        tableView.register(PersonLabelsTableViewCell.self, forCellReuseIdentifier: "personCell")
        tableView.separatorStyle = .none
        view.addSubview(tableView)
        
        activityIndicatorView = NVActivityIndicatorView(frame: .zero, type: .ballScale, color: Theme().textColor, padding: 0)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.startAnimating()
        tableView.backgroundView = activityIndicatorView
        
        NSLayoutConstraint.activate([
            tableView.heightAnchor.constraint(equalTo: view.heightAnchor),
            tableView.widthAnchor.constraint(equalTo: view.widthAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            activityIndicatorView.heightAnchor.constraint(equalToConstant: 50),
            activityIndicatorView.widthAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    private func setupTextFieldView() {
        textFieldContainer = MCCard(frame: .zero)
        textFieldContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textFieldContainer)
        
        textField = UITextField(frame: .zero)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Search recipients"
        textField.textColor = Theme().textColor
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textField.returnKeyType = .done
        textField.delegate = self
        textField.clearButtonMode = .whileEditing
        textFieldContainer.addSubview(textField)
        
        instructionLabel = MCPill(frame: .zero, character: "\(self.navigationController!.childViewControllers.count)", image: nil, body: "Designate a Recipient", color: .white)
        instructionLabel.bodyLabel.textColor = Theme().textColor
        instructionLabel.circleMask.backgroundColor = Theme().textColor
        instructionLabel.characterLabel.textColor = .white
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(instructionLabel)
        
        NSLayoutConstraint.activate([
            instructionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            instructionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6),
            textFieldContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            textFieldContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            textFieldContainer.topAnchor.constraint(equalTo: instructionLabel.centerYAnchor),
            textField.leadingAnchor.constraint(equalTo: textFieldContainer.leadingAnchor, constant: 15),
            textField.trailingAnchor.constraint(equalTo: textFieldContainer.trailingAnchor, constant: -15),
            textField.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 14),
            textField.bottomAnchor.constraint(lessThanOrEqualTo: textFieldContainer.bottomAnchor, constant: -14),
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

extension CreatePackagePersonSearchViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return results.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let resultItem = self.results[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "personCell") as! PersonLabelsTableViewCell
        if resultItem.picUrl != nil {
            cell.profileImageView.sd_setImage(with: URL(string: resultItem.picUrl!)) { (image, error, cacheType, url) in
                print("loaded")
            }
        } else {
            cell.profileImageView.image = UIImage(named: "user_black_56pt")
        }
        cell.titleLabel.text = resultItem.name
        cell.subtitleLabel.text = resultItem.position ?? "No position available"
        return cell
    }
    
    private func performQuery(with queryString: String) {
        query.query = queryString
        print("queryString is \(queryString)")
        let curSearchId = searchId
        peopleIndex.search(query) { (data, error) in
            if (curSearchId <= self.displayedSearchId) || (error != nil) {
                print(error!)
                return
            }
            self.displayedSearchId = curSearchId
            self.loadedPage = 0
            
            guard let hits = data!["hits"] as? [[String: Any]] else { return }
            guard let nbPages = data!["nbPages"] as? UInt else { return }
            self.nbPages = nbPages
            self.results.removeAll()
            print(hits.count)
            for hit in hits {
                self.results.append(RecipientResultItem(name: hit["name"] as! String, picUrl: hit["picUrl"] as? String, position: hit["position"] as? String))
            }
            DispatchQueue.main.async {
                self.tableView.separatorStyle = .singleLine
                self.activityIndicatorView.stopAnimating()
                self.tableView.reloadData()
            }
        }
        self.searchId += 1
    }
}

extension CreatePackagePersonSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected \(indexPath)")
        createPackageCoordinator.recipientResultItem = self.results[indexPath.row]
        createPackageCoordinator.pushToDestination()
    }
}

extension CreatePackagePersonSearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var updatedText: String?
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            updatedText = text.replacingCharacters(in: textRange,
                                                   with: string)
            //            print(updatedText)
            // update query and results
            
        }
        performQuery(with: updatedText ?? "")
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        performQuery(with: "")
        return true
    }
}

extension CreatePackagePersonSearchViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
