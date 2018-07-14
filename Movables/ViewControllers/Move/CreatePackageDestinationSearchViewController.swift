//
//  CreatePackageDestinationSearchViewController.swift
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
import MapKit
import Contacts
import NVActivityIndicatorView

struct DestinationResultItem {
    var name: String?
    var placemark: MKPlacemark
    
    init(name: String?, placemark: MKPlacemark) {
        self.name = name
        self.placemark = placemark
    }
}

class CreatePackageDestinationSearchViewController: UIViewController {

    let CONTENT_INSET_TOP: CGFloat = UIApplication.shared.keyWindow!.safeAreaInsets.top != 0 ? UIApplication.shared.keyWindow!.safeAreaInsets.top + 39.5 + 12 : 45.5 + 39.5 + 12
    let CONTENT_INSET_BOTTOM: CGFloat = UIApplication.shared.keyWindow!.safeAreaInsets.bottom != 0 ? UIApplication.shared.keyWindow!.safeAreaInsets.bottom + 30 + 10 : 34 + 30 + 28

    var createPackageCoordinator: CreatePackageCoordinator!
    var textField: UITextField!
    var textFieldContainer: MCCard!
    var tableView: UITableView!
    var results:[DestinationResultItem] = []
    var activityIndicatorView: NVActivityIndicatorView!
    
    var instructionLabel: MCPill!
    var floatingButtonsContainerView: UIView!
    var backButtonBaseView: UIView!
    var backButton: UIButton!
    var bottomConstraintFAB: NSLayoutConstraint!
    
    var searchId = 0
    var displayedSearchId = -1
    var loadedPage: UInt = 0
    var nbPages: UInt = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        setupTableView()
        setupTextFieldView()
        setupFAB()
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true

        
        registerKeyboardNotifications()
        
        self.performSearch(with: "government")
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
        tableView.backgroundColor = .white
        tableView.contentInset.top = CONTENT_INSET_TOP
        tableView.contentInset.bottom = CONTENT_INSET_BOTTOM
        tableView.register(LargeTitleWithSubtitleTableViewCell.self, forCellReuseIdentifier: "locationCell")
        self.tableView.separatorStyle = .none
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
        textField.placeholder = String(NSLocalizedString("label.searchDestinations", comment: "label text for search destinations"))
        textField.textColor = Theme().textColor
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textField.returnKeyType = .search
        textField.delegate = self
        textField.clearButtonMode = .whileEditing
        textFieldContainer.addSubview(textField)
        
        instructionLabel = MCPill(frame: .zero, character: "\(self.navigationController!.childViewControllers.count)", image: nil, body: String(NSLocalizedString("label.setADestination", comment: "label text for set a destination")), color: .white)
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
    
    func performSearch(with text:String) {
        print("begin search")
        LocationManager.shared.desiredAccuracy = kCLLocationAccuracyHundredMeters
        LocationManager.shared.requestLocation()
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = text
        request.region = MKCoordinateRegionMakeWithDistance(LocationManager.shared.location!.coordinate, 100000, 100000)
        
        let search = MKLocalSearch(request: request)
        
        search.start(completionHandler: {(response, error) in
            
            if error != nil {
                print("Error occurred in search: \(error!.localizedDescription)")
            } else if response!.mapItems.count == 0 {
                print("No matches found")
            } else {
                print("Matches found")
                self.results.removeAll()
                for item in response!.mapItems {
                    self.results.append(DestinationResultItem(name: item.name, placemark: item.placemark))
                }
                self.activityIndicatorView.stopAnimating()
                self.tableView.separatorStyle = .singleLine
                self.tableView.reloadData()
            }
        })

    }
}

extension CreatePackageDestinationSearchViewController: UITableViewDataSource {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell") as! LargeTitleWithSubtitleTableViewCell
        cell.largeTitleLabel.text = resultItem.name
        cell.subtitleLabel.text = resultItem.placemark.postalAddress != nil && !resultItem.placemark.postalAddress!.street.isEmpty && !resultItem.placemark.postalAddress!.subAdministrativeArea.isEmpty ? "\(resultItem.placemark.postalAddress!.street), \(resultItem.placemark.postalAddress!.subAdministrativeArea)" : "\(resultItem.placemark.location!.coordinate.longitude), \(resultItem.placemark.location!.coordinate.latitude)"
        return cell
    }
    
}

extension CreatePackageDestinationSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        createPackageCoordinator.destinationResultItem = self.results[indexPath.row]
        createPackageCoordinator.pushToContent()
    }
}

extension CreatePackageDestinationSearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.performSearch(with: "")
        self.results.removeAll()
        self.tableView.reloadData()
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
        self.performSearch(with: updatedText!)
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.results.removeAll()
        self.tableView.reloadData()
        return true
    }
}

extension CreatePackageDestinationSearchViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
