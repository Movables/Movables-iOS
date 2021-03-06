//
//  CreatePackageTopicSearchViewController.swift
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
import InstantSearchClient
import NVActivityIndicatorView
import class Firebase.Firestore

struct PackageTopicResultItem {
    var name: String
    var templatesCount: Int?
    var packagesCount: Int?
    var documentID: String
    
    init(name: String, templatesCount: Int?, packagesCount: Int?, documentID: String) {
        self.name = name
        self.templatesCount = templatesCount
        self.packagesCount = packagesCount
        self.documentID = documentID
    }
    
    init(hit: [String: Any]) {
        self.name = hit["name"] as! String
        self.templatesCount = (hit["count"] as! [String: Int])["templates"]
        self.packagesCount = (hit["count"] as! [String: Int])["packages"]
        self.documentID = hit["objectID"] as! String
    }
}

class CreatePackageTopicSearchViewController: UIViewController {
    
    let CONTENT_INSET_TOP: CGFloat = UIApplication.shared.keyWindow!.safeAreaInsets.top != 0 ? UIApplication.shared.keyWindow!.safeAreaInsets.top + 39.5 + 12 : 45.5 + 39.5 + 12
    let CONTENT_INSET_BOTTOM: CGFloat = UIApplication.shared.keyWindow!.safeAreaInsets.bottom != 0 ? UIApplication.shared.keyWindow!.safeAreaInsets.bottom + 30 + 10 : 34 + 30 + 28
    
    var createPackageCoordinator: CreatePackageCoordinator!
    var topic: Topic?
    var textField: UITextField!
    var textFieldContainer: MCCard!
    var tableView: UITableView!
    var results:[PackageTopicResultItem] = []
    
    var instructionLabel: MCPill!
    var floatingButtonsContainerView: UIView!
    var cancelButtonBaseView: UIView!
    var cancelButton: UIButton!
    var bottomConstraintFAB: NSLayoutConstraint!

    var topicsIndex: Index!
    var query: Query = Query()
    
    var searchId = 0
    var displayedSearchId = -1
    var loadedPage: UInt = 0
    var nbPages: UInt = 0
    var activityIndicatorView: NVActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("bottom safe: \(UIApplication.shared.keyWindow!.safeAreaInsets.bottom)")
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        setupQuery()
        
        setupTableView()
        setupTextFieldView()
        setupFAB()
        
        registerKeyboardNotifications()
        
        performQuery(with: "")
    }
    
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardInfo = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let keyboardSize = keyboardInfo.cgRectValue.size
        let contentInsets = UIEdgeInsets(top: CONTENT_INSET_TOP, left: 0, bottom: keyboardSize.height - UIApplication.shared.keyWindow!.safeAreaInsets.bottom, right: 0)
        tableView.contentInset = contentInsets
        tableView.scrollIndicatorInsets = contentInsets
        tableView.scrollIndicatorInsets.top = 0
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let normalInset = UIEdgeInsets(top: CONTENT_INSET_TOP, left: 0, bottom: CONTENT_INSET_BOTTOM, right: 0)
        tableView.contentInset = normalInset
        tableView.scrollIndicatorInsets = normalInset
        tableView.scrollIndicatorInsets.bottom = 0
        tableView.scrollIndicatorInsets.top = 0
    }

    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    
    private func setupQuery() {
        let apiClient = Client(appID: (UIApplication.shared.delegate as! AppDelegate).algoliaClientId!, apiKey: (UIApplication.shared.delegate as! AppDelegate).algoliaAPIKey!)
        topicsIndex = apiClient.index(withName: "topics")
        query.hitsPerPage = 15
        query.attributesToRetrieve = ["name", "count", "objectID"]
        query.attributesToHighlight = ["name"]
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
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 88
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = Theme().backgroundShade
        tableView.contentInset.top = CONTENT_INSET_TOP
        tableView.contentInset.bottom = CONTENT_INSET_BOTTOM
        tableView.register(LargeTitleWithSubtitleTableViewCell.self, forCellReuseIdentifier: "topicResultItem")
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
        textField.placeholder = String(NSLocalizedString("label.searchTopics", comment: "label text for search topics"))
        textField.textColor = Theme().textColor
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textField.returnKeyType = .done
        textField.delegate = self
        textField.clearButtonMode = .whileEditing
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textFieldContainer.addSubview(textField)
        
        instructionLabel = MCPill(frame: .zero, character: "1", image: nil, body: String(NSLocalizedString("label.tagYourPackage", comment: "label text for tag your package")), color: .white)
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
    
    @objc private func didTapCancelButton(sender: UIButton) {
        createPackageCoordinator.cancelPacakgeCreation()
        print("backed")
    }
}

extension CreatePackageTopicSearchViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return results.count
        } else {
            if !self.textField.text!.isEmpty && results.count == 0 {
                return 1
            } else {
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let resultItem = self.results[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "topicResultItem") as! LargeTitleWithSubtitleTableViewCell
            cell.largeTitleLabel.text = "#\(resultItem.name)"
            let templatesCountString: String = resultItem.templatesCount == nil || resultItem.templatesCount == 0 ? "" : (resultItem.templatesCount! == 1 ? String(format: NSLocalizedString("label.templateCount", comment: "label text for singular template count"), resultItem.templatesCount!) : String(format: NSLocalizedString("label.templatesCount", comment: "label text for plural template count"), resultItem.templatesCount!))
            let packagesCountString: String = resultItem.packagesCount == nil || resultItem.packagesCount! == 0 ? "" : (resultItem.packagesCount! == 1 ? String(format: NSLocalizedString("label.packageCount", comment: "label text for singular package count"), resultItem.packagesCount!) : String(format: NSLocalizedString("label.packagesCount", comment: "label text for plural packages count"), resultItem.packagesCount!))
            cell.subtitleLabel.text = "\(templatesCountString)\(packagesCountString)"
            cell.subtitleLabel.textColor = Theme().textColor
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "topicResultItem") as! LargeTitleWithSubtitleTableViewCell
            cell.largeTitleLabel.text = "#\(self.textField.text!)"
            cell.subtitleLabel.text = "Tap to create new topic"
            cell.subtitleLabel.textColor = Theme().keyTint
            return cell
        }
    }
    
    private func performQuery(with queryString: String) {
        query.query = queryString
        print("queryString is \(queryString)")
        let curSearchId = searchId
        topicsIndex.search(query) { (data, error) in
            if (curSearchId <= self.displayedSearchId) || (error != nil) {
                print(error.debugDescription)
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
                self.results.append(PackageTopicResultItem(hit: hit))
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

extension CreatePackageTopicSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected \(indexPath)")
        if results.count > 0 {
            createPackageCoordinator.topicResultItem = self.results[indexPath.row]
            if createPackageCoordinator.topicResultItem!.templatesCount! == 0 {
                createPackageCoordinator.pushToCategory()
            } else {
                createPackageCoordinator.pushToTemplates()
            }
        } else {
            // create new topic w/ text in textfield
            let topic = textField.text
            createPackageCoordinator.topicResultItem = PackageTopicResultItem(name: topic!, templatesCount: nil, packagesCount: nil, documentID: Firestore.firestore().collection("topics").document().documentID)
            createPackageCoordinator.pushToCategory()
        }
    }
}

extension CreatePackageTopicSearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var updatedText: String?
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            if string != " " {
                updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
//            print(updatedText)
            // update query and results
                performQuery(with: updatedText ?? "")
            } else {
                return false
            }
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        performQuery(with: "")
        return true
    }
}
