//
//  OrganizeDetailViewController.swift
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
import NVActivityIndicatorView
import CoreLocation
import AlgoliaSearch

protocol OrganizeDetailViewControllerDelegate {
    func dismissOrganizeDetailVC()
    func showPostsVC(for reference: DocumentReference, referenceType: CommunityType)
}

class OrganizeDetailViewController: UIViewController {

    let apiClient = Client(appID: (UIApplication.shared.delegate as! AppDelegate).algoliaClientId!, apiKey: (UIApplication.shared.delegate as! AppDelegate).algoliaAPIKey!)
    
    var delegate: OrganizeDetailViewControllerDelegate?
    
    var navBarIsTransparent: Bool = true
    
    var tableView: UITableView!
    
    var organizeTopic: OrganizeTopic!
    var favoriteCommunities: [Community]? {
        didSet {
            if nearbyCommunities != nil && topic != nil {
                self.activityIndicatorView?.stopAnimating()
                self.tableView.reloadData()
            }
        }
    }
    var nearbyCommunities: [Community]? {
        didSet {
            if favoriteCommunities != nil && topic != nil {
                self.activityIndicatorView?.stopAnimating()
                self.tableView.reloadData()
            }
        }
    }
    
    var topic: Topic? {
        didSet {
            self.addButton.isEnabled = true
            if favoriteCommunities != nil && nearbyCommunities != nil {
                self.activityIndicatorView?.stopAnimating()
                self.tableView.reloadData()
            }
        }
    }
    
    var activityIndicatorView: NVActivityIndicatorView!
    var addButton: UIBarButtonItem!
    
    var legislativeAreas: [(String, String)]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        updateNavigationBarAppearance(withTransparency: self.navBarIsTransparent)
        
        // Do any additional setup after loading the view.
        let closeButton = UIBarButtonItem(image: UIImage(named: "round_keyboard_arrow_down_black_36pt"), style: .plain, target: self, action: #selector(didTapCloseButton(sender:)))
        navigationItem.leftBarButtonItem = closeButton

        addButton = UIBarButtonItem(image: UIImage(named: "round_add_black_24pt"), style: .plain, target: self, action: #selector(didTapAddButton(sender:)))
        addButton.isEnabled = false
        navigationItem.rightBarButtonItem = addButton
        
        LocationManager.shared.desiredAccuracy = kCLLocationAccuracyHundredMeters

        setupTableView()
        fetchTopicDetail()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func fetchTopicDetail() {
        let db = Firestore.firestore()
        db.collection("topics").whereField("tag", isEqualTo: organizeTopic.tag).limit(to: 1).getDocuments { (querySnapshot, error) in
            guard let snapshot = querySnapshot else { return }
            snapshot.documents.forEach({ (docSnapshot) in
                self.topic = Topic(with: docSnapshot.data(), reference: docSnapshot.reference)
                self.loadMyConversations()
            })
        }
    }
    
    func loadMyConversations() {
        topic!.reference.collection("conversations").whereField("participants.\(Auth.auth().currentUser!.uid)", isGreaterThan: 0).getDocuments { (querySnapshot, error) in
            if let error = error {
                print(error)
                return
            } else {
                if let snapshot = querySnapshot {
                    var tempMyLegislativeAreaConversations:[Community] = []
                    snapshot.documents.forEach({ (docSnapshot) in
                        let legislativeArea = docSnapshot.data()["legislative_area"] as! [String: String]
                        let legislativeAreaString = legislativeArea.first!.value
                        tempMyLegislativeAreaConversations.append(Community(name: legislativeAreaString, type: .location, reference: docSnapshot.reference))
                    })
                    for package in self.organizeTopic.packagesMoved {
                        tempMyLegislativeAreaConversations.append(Community(name: package.headline, type: .package, reference: package.reference))
                    }
                    self.favoriteCommunities = tempMyLegislativeAreaConversations
                    self.loadNearByConversations()
                }
            }
        }
    }
    
    func loadNearByConversations() {
        LocationManager.shared.requestLocation()
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(LocationManager.shared.location!) { (placemarks, error) in
            if let error = error {
                print(error)
                return
            } else {
                if let placemark = placemarks?.first {
                    let index = self.apiClient.index(withName: "topicConversations")
                    let query = Query(query: "")
                    query.attributesToRetrieve = ["country", "administrative_area", "sub_administrative_area", "locality", "sub_locality", "objectID"]
                    
                    self.legislativeAreas = generateLegislativeAreasTuples(for: placemark)
                    var filterString = ""
                    for (index, (legislativeArea, area)) in self.legislativeAreas!.enumerated() {
                        filterString += "\(legislativeArea): \"\(area)\"\((index != self.legislativeAreas!.count - 1) ? " OR " : "")"
                    }
                    query.filters = filterString
                    print(filterString)
                    
                    index.search(query, completionHandler: { (content, error) -> Void in
                        if error == nil {
                            var communitiesTemp: [Community] = []
                            guard let hits = content!["hits"] as? [[String: AnyObject]] else {
                                print("hits error")
                                return
                            }
                            print(hits)
                            for hit in hits {
                                var name:String = ""
                                if hit["country"] != nil {
                                    name = hit["country"] as! String
                                }
                                else if hit["administrative_area"] != nil {
                                    name = hit["administrative_area"] as! String
                                }
                                else if hit["sub_administrative_area"] != nil {
                                    name = hit["sub_administrative_area"] as! String
                                }
                                else if hit["locality"] != nil {
                                    name = hit["locality"] as! String
                                }
                                else if hit["sub_locality"] != nil {
                                    name = hit["sub_locality"] as! String
                                }
                                let community = Community(name: name, type: .location, reference: self.topic!.reference.collection("conversations").document((hit["objectID"] as! String)))
                                communitiesTemp.append(community)
                            }
                            self.nearbyCommunities = communitiesTemp
                        } else {
                            print(error!)
                        }
                    })
                } else {
                    print("no placemark found")
                }
            }
        }
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.scrollIndicatorInsets.top = UIApplication.shared.keyWindow!.safeAreaInsets.top
        tableView.scrollIndicatorInsets.bottom = UIApplication.shared.keyWindow!.safeAreaInsets.bottom
        tableView.estimatedRowHeight = 100
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = 40
        tableView.contentInset.bottom = UIApplication.shared.keyWindow!.safeAreaInsets.bottom
        tableView.register(OrganizeDetailTableHeaderViewCell.self, forCellReuseIdentifier: "organizeDetailHeader")
        tableView.register(SectionHeaderTableViewHeaderView.self, forHeaderFooterViewReuseIdentifier: "sectionHeader")
        tableView.register(CommunityTableViewCell.self, forCellReuseIdentifier: "communityCell")
        tableView.backgroundColor = .white
        view.addSubview(tableView)
        
        activityIndicatorView = NVActivityIndicatorView(frame: .zero, type: .ballScale, color: Theme().textColor, padding: 0)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.startAnimating()
        tableView.backgroundView = activityIndicatorView
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            activityIndicatorView.heightAnchor.constraint(equalToConstant: 50),
            activityIndicatorView.widthAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    
    @objc private func didTapCloseButton(sender: UIBarButtonItem) {
        delegate?.dismissOrganizeDetailVC()
    }
    
    @objc private func didTapAddButton(sender: UIBarButtonItem) {
        print("did tap add button")
        let createConversationCoordinator = CreateConversationCoordinator(rootViewController: self)
        createConversationCoordinator.topic = self.topic!
        createConversationCoordinator.start()
    }

    
    func updateNavigationBarAppearance(withTransparency: Bool) {
        self.navBarIsTransparent = !self.navBarIsTransparent
        self.navigationController?.navigationBar.setBackgroundImage(withTransparency ? UIImage() : nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = withTransparency ? UIImage() : nil
        self.navigationItem.title = withTransparency ? "" : "#\(organizeTopic.tag)"
        self.navigationController?.navigationBar.tintColor = withTransparency ? Theme().textColor : Theme().textColor
    }
}

extension OrganizeDetailViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == tableView {
            if scrollView.contentOffset.y > (20 + UIApplication.shared.keyWindow!.safeAreaInsets.top)  && navBarIsTransparent == true {
                self.updateNavigationBarAppearance(withTransparency: false)
            }
            if scrollView.contentOffset.y <= (20 + UIApplication.shared.keyWindow!.safeAreaInsets.top) && navBarIsTransparent == false {
                self.updateNavigationBarAppearance(withTransparency: true)
            }
        }
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if scrollView.contentOffset.y < -100 {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != 0 {
            let community: Community
            if indexPath.section == 1 {
                community = favoriteCommunities![indexPath.row]
            } else {
                // section == 2
                community = nearbyCommunities![indexPath.row]
            }
            print("show posts for \(community)")
            delegate?.showPostsVC(for: community.reference, referenceType: community.type)
        }
    }
}

extension OrganizeDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.topic != nil ? 3 : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return favoriteCommunities?.count ?? 1
        default:
            return nearbyCommunities?.count ?? 5
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "organizeDetailHeader") as! OrganizeDetailTableHeaderViewCell
            cell.tagLabel.text = "#\(organizeTopic.tag)"
            cell.descriptionLabel.text = self.topic?.description ?? ""
            return cell
        } else {
            // return favorited communities
            let cell = tableView.dequeueReusableCell(withIdentifier: "communityCell") as! CommunityTableViewCell
            let community: Community = indexPath.section == 1 ? favoriteCommunities![indexPath.row] : nearbyCommunities![indexPath.row]
            cell.nameLabel.text = community.name
            cell.descriptionLabel.text = getDescriptionForCommunity(community: community)
            cell.supplementLabelContainerView.isHidden = true
            cell.communityTypeImageView.image = getImageForCommunityType(type: community.type)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section != 0 {
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "sectionHeader") as! SectionHeaderTableViewHeaderView
            var sectionTitle: String?
            switch section {
            case 1:
                sectionTitle = String(NSLocalizedString("label.myConversations", comment: "label text for my conversations"))
            case 2:
                sectionTitle = String(NSLocalizedString("label.nearbyConversations", comment: "label text for nearby conversations"))
            default:
                sectionTitle = ""
            }
            view.label.text = sectionTitle!
            // add button to create new communities by selecting from the dropoff administrative areas
            // add button to create private communities
            return view
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : UITableViewAutomaticDimension
    }
}

func getDescriptionForCommunity(community: Community) -> String {
    switch community.type {
    case .location:
        return String(NSLocalizedString("label.conversationTypeLocal", comment: "label string for local conversation"))
    case .package:
        return String(NSLocalizedString("label.conversationTypePackage", comment: "label string for package conversation"))
    default:
        return String(NSLocalizedString("label.conversationTypePrivate", comment: "label string for private conversation"))
    }
}

func getImageForCommunityType(type: CommunityType) -> UIImage {
    switch type {
    case .location:
        return UIImage(named: "location_glyph_40pt")!
    case .package:
        return UIImage(named: "package_glyph_40pt")!
    default:
        return UIImage(named: "people_glyph_40pt")!
    }
}

