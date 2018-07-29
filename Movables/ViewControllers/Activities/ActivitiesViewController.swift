//
//  ActivitiesViewController.swift
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
import GoogleSignIn
import MapKit
import CoreLocation
import Firebase
import NVActivityIndicatorView
import TTTAttributedLabel

protocol ActivitiesViewControllerDelegate: class {
    func showPackageDetail(with packageId: String, and headline: String)
}


class ActivitiesViewController: UIViewController {
    
    var delegate: ActivitiesViewControllerDelegate?
    var mainCoordinatorDelegate: MainCoordinatorDelegate?
    var mainCoordinator: MainCoordinator?
    var tableView: UITableView!
    var refreshControl: UIRefreshControl!
    
    var emptyStateView: EmptyStateView!

    var publicActivities: [PublicActivity] = []
    var documents: [QueryDocumentSnapshot] = []
    
    var rowsForIndexPaths: [IndexPath: [LogisticsRow]] = [:]
    var annotationsForIndexPaths: [IndexPath: [MKAnnotation]] = [:]
    var mapPreviewImagesForIndexPaths: [IndexPath: UIImage] = [:] {
        didSet {
            if mapPreviewImagesForIndexPaths.count == self.annotationsForIndexPaths.count {
                DispatchQueue.main.async {
                    if self.publicActivities.count == 0 {
                        self.emptyStateView.isHidden = false
                        self.view.backgroundColor = .white
                    } else {
                        self.emptyStateView.isHidden = true
                        self.view.backgroundColor = Theme().backgroundShade
                    }
                    for rowIndex in self.tableView.indexPathsForVisibleRows ?? [] {
                        if let cell = self.tableView.cellForRow(at: rowIndex) {
                            if cell.isMember(of: ActivityTableViewCell.self) {
                                (cell as! ActivityTableViewCell).imageMapView.image = self.mapPreviewImagesForIndexPaths[rowIndex] ?? nil
                            }
                        }
                    }
                }
            }
        }
    }
    
    let query = Firestore.firestore().collection("public_activities").whereField("followers.\(Auth.auth().currentUser!.uid)", isGreaterThan: Date(timeIntervalSince1970: 0)).order(by: "followers.\(Auth.auth().currentUser!.uid)", descending: true)
    
    var queryInProgress: Bool = false
    var initialFetchPerformed = false
    var noMorePublicActivities: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        setupTableView()
        fetchPublicActivities()
    }
    
    private func fetchMorePublicActivities() {
        if let lastDocument = self.documents.last {
            if !self.queryInProgress {
                self.queryInProgress = true
                print("start next query")
                query.start(afterDocument: lastDocument).limit(to: 10).getDocuments { (snapshot, error) in
                    guard let snapshot = snapshot else {
                        print("error retrieving public activities: \(error.debugDescription)")
                        self.queryInProgress = false
                        return
                    }
                    guard snapshot.documents.last != nil else {
                        // no more documents
                        self.noMorePublicActivities = true
                        print("no more public activities")
                        if let cell = self.tableView.cellForRow(at: IndexPath(row: self.publicActivities.count, section: 0)) as? LoadingIndicatorTableViewCell {
                            cell.activityIndicator.stopAnimating()
                            if self.publicActivities.count > 0 {
                                cell.label.isHidden = false
                            } else {
                                cell.label.isHidden = true
                            }
                        }
                        self.queryInProgress = false
                        return
                    }
                    var publicActivitiesTemp:[PublicActivity] = []
                    snapshot.documents.forEach({ (docSnapshot) in
                        publicActivitiesTemp.append(PublicActivity(with: docSnapshot.data()))
                    })
                    self.documents.append(contentsOf: snapshot.documents)
                    let startingRow = self.publicActivities.count
                    var indexPathsToInsert:[IndexPath] = []
                    self.publicActivities.append(contentsOf: publicActivitiesTemp)
                    for (index, activity) in publicActivitiesTemp.enumerated() {
                        self.rowsForIndexPaths.updateValue(self.generateRows(for: activity.supplements!, with: activity.supplementsType!), forKey: IndexPath(row: startingRow + index, section: 0))
                        self.annotationsForIndexPaths.updateValue(self.generateAnnotations(for: activity.supplements!, with: activity.supplementsType!), forKey: IndexPath(row: startingRow + index, section: 0))
                        indexPathsToInsert.append(IndexPath(row: startingRow + index, section: 0))
                    }
                    self.generateMapImages()
                    indexPathsToInsert.append(IndexPath(row: self.publicActivities.count, section: 0))
                    print("insert indexes: \(indexPathsToInsert)")
                    print("number of rows: \(self.tableView.numberOfRows(inSection: 0))")
                    DispatchQueue.main.async {
                        self.tableView.beginUpdates()
                        self.tableView.deleteRows(at: [IndexPath(row: startingRow, section: 0)], with: .none)
                        self.tableView.insertRows(at: indexPathsToInsert, with: .none)
                        self.tableView.endUpdates()
                    }
                    self.queryInProgress = false
                }
            }
        }
    }
    
    private func fetchPublicActivities() {
        print("fetch public activities")
        if !queryInProgress {
            queryInProgress = true
            self.noMorePublicActivities = false
            query.limit(to: 10).getDocuments(completion: { (snapshot, error) in
                guard let snapshot = snapshot else {
                    print("error retrieving public activities: \(error.debugDescription)")
                    self.initialFetchPerformed = true
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                    if self.publicActivities.count == 0 {
                        self.emptyStateView.isHidden = false
                        self.view.backgroundColor = .white
                    } else {
                        self.emptyStateView.isHidden = true
                        self.view.backgroundColor = Theme().backgroundShade
                    }
                    self.queryInProgress = false
                    return
                }
                guard snapshot.documents.last != nil else {
                    // empty results
                    print("empty results")
                    self.noMorePublicActivities = true
                    self.initialFetchPerformed = true
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                    if self.publicActivities.count == 0 {
                        self.emptyStateView.isHidden = false
                        self.view.backgroundColor = .white
                    } else {
                        self.emptyStateView.isHidden = true
                        self.view.backgroundColor = Theme().backgroundShade
                    }
                    self.queryInProgress = false
                    return
                }
                print("some results")
                self.rowsForIndexPaths.removeAll()
                self.mapPreviewImagesForIndexPaths.removeAll()
                self.annotationsForIndexPaths.removeAll()
                self.publicActivities.removeAll()
                self.documents.removeAll()
                self.documents.append(contentsOf: snapshot.documents)
                
                var publicActivitiesTemp:[PublicActivity] = []
                snapshot.documents.forEach({ (docSnapshot) in
                    publicActivitiesTemp.append(PublicActivity(with: docSnapshot.data()))
                })
                
                self.publicActivities.append(contentsOf: publicActivitiesTemp)
                for (index, activity) in self.publicActivities.enumerated() {
                    self.rowsForIndexPaths.updateValue(self.generateRows(for: activity.supplements!, with: activity.supplementsType!), forKey: IndexPath(row: index, section: 0))
                    self.annotationsForIndexPaths.updateValue(self.generateAnnotations(for: activity.supplements!, with: activity.supplementsType!), forKey: IndexPath(row: index, section: 0))
                }
                self.generateMapImages()
                self.initialFetchPerformed = true
                self.tableView.reloadData()
                if self.publicActivities.count == 0 {
                    self.emptyStateView.isHidden = false
                    self.view.backgroundColor = .white
                } else {
                    self.emptyStateView.isHidden = true
                    self.view.backgroundColor = Theme().backgroundShade
                }
                self.refreshControl.endRefreshing()
                self.queryInProgress = false
            })
        }
    }
    
    private func generateMapImages() {
        for entry in self.annotationsForIndexPaths {
            let coords = entry.value.first!.coordinate
            let distanceInMeters: Double = 500
            
            let options = MKMapSnapshotOptions()
            options.region = MKCoordinateRegionMakeWithDistance(coords, distanceInMeters, distanceInMeters)
            options.size = CGSize(width: UIScreen.main.bounds.width - 18, height: 200)
            
            /// 4.
            let bgQueue = DispatchQueue.global(qos: .background)
            let snapShotter = MKMapSnapshotter(options: options)
            snapShotter.start(with: bgQueue, completionHandler: { [weak self] (snapshot, error) in
                guard error == nil else {
                    return
                }
                
                if let snapShotImage = snapshot?.image{
                    self?.mapPreviewImagesForIndexPaths.updateValue(snapShotImage, forKey: entry.key)
                }
            })
        }
    }
    
    private func setupTableView() {
        
        view.backgroundColor = Theme().backgroundShade
        
        tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 250
        tableView.separatorStyle = .none
        tableView.register(ActivityTableViewCell.self, forCellReuseIdentifier: "activityCell")
        tableView.register(LoadingIndicatorTableViewCell.self, forCellReuseIdentifier: "loadingCell")
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didRefresh(sender:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        emptyStateView = EmptyStateView(frame: .zero)
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.titleLabel.text = String(NSLocalizedString("copy.wannaSeeSomeActivities", comment: "title for wanna see some activities"))
        emptyStateView.subtitleLabel.text = String(NSLocalizedString("copy.wannaSeeSomeActivitiesBody", comment: "body for wanna see some activities"))
        emptyStateView.actionButton.isHidden = true
        emptyStateView.isHidden = true
        view.addSubview(emptyStateView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func didRefresh(sender: UIRefreshControl) {
        sender.beginRefreshing()
        fetchPublicActivities()
    }

}

extension ActivitiesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.publicActivities.isEmpty || indexPath.row == self.publicActivities.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell") as! LoadingIndicatorTableViewCell
            cell.label.text = String(NSLocalizedString("copy.noMoreActivities", comment: "label for no more activities"))
            if self.noMorePublicActivities {
                cell.activityIndicator.stopAnimating()
                cell.label.isHidden = false
            } else {
                cell.activityIndicator.startAnimating()
                cell.label.isHidden = true
            }
            if self.initialFetchPerformed && self.publicActivities.isEmpty {
                cell.label.isHidden = true
            }
            return cell
        }
        
        // activity row
        let cell = tableView.dequeueReusableCell(withIdentifier: "activityCell") as! ActivityTableViewCell
        let activity = self.publicActivities[indexPath.row]
        let eventText = generateLabelTextForPublicActivity(publicActivity: activity)
        cell.userEventView.eventLabel.text = eventText
        if activity.actorPic != nil {
            cell.userEventView.profilePicImageView.sd_setImage(with: URL(string: activity.actorPic!)) { (image, error, cacheType, url) in
//                print("loaded actor pic")
            }
        }
        let eventTextNSString = eventText as NSString
        let rangeOfObject = eventTextNSString.range(of: activity.objectName)
        let urlForObject = URL(string: "packages/\(activity.objectReference.documentID)/\(activity.objectName)".addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)
        cell.userEventView.eventLabel.addLink(to: urlForObject, with: rangeOfObject)
        let rangeOfActor = eventTextNSString.range(of: activity.actorName)
        let urlForActor = URL(string: "users/\(activity.actorReference.documentID)".addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)
        cell.userEventView.eventLabel.addLink(to: urlForActor, with: rangeOfActor)
        cell.userEventView.eventLabel.delegate = self
        cell.userEventView.dateLabel.text = activity.date.timeAgoSinceNow
        cell.imageMapView.image = self.mapPreviewImagesForIndexPaths[indexPath] ?? nil
        let rows = rowsForIndexPaths[indexPath]!
        
        let firstRow = rows[0]
        let firstRowData = ActivityRowViewData(profilePicUrl: firstRow.circleImageUrl, logisticRowType: firstRow.type, titleText: firstRow.titleText, subtitleText: firstRow.subtitleText.uppercased())
        
        let secondRow = rows[1]
        let secondRowData = ActivityRowViewData(profilePicUrl: secondRow.circleImageUrl, logisticRowType: secondRow.type, titleText: secondRow.titleText, subtitleText: secondRow.subtitleText.uppercased())
        
        let thirdRow = rows[2]
        let thirdRowData = ActivityRowViewData(profilePicUrl: thirdRow.circleImageUrl, logisticRowType: thirdRow.type, titleText: thirdRow.titleText, subtitleText: thirdRow.subtitleText.uppercased())
        
        let annotations = self.annotationsForIndexPaths[indexPath]!
        
        DispatchQueue.main.async {
            
            self.configureActivityRowViewWithRowViewData(rowView: cell.firstRow, with: firstRowData)
            self.configureActivityRowViewWithRowViewData(rowView: cell.secondRow, with: secondRowData)
            self.configureActivityRowViewWithRowViewData(rowView: cell.thirdRow, with: thirdRowData)
            
            switch activity.type {
            case .packageDelivery:
                let annotation = annotations.first! as! ActivityDeliveryAnnotation
                if annotation.person.photoUrl != nil {
                    cell.annotationView.imageView.sd_setImage(with: URL(string: annotation.person.photoUrl!)!) { (image, error, cacheType, url) in
                        print("loaded recipient image")
                    }
                } else {
                    cell.annotationView.imageView.image = getImage(for: .Person)
                }
                cell.annotationView.labelTextLabel.text = annotation.person.displayName
                cell.annotationView.imageView.tintColor = Theme().textColor
                cell.annotationView.labelContainer.backgroundColor = Theme().textColor
                cell.annotationView.circleMask.layer.borderColor = Theme().textColor.cgColor
            case .packageDropoff:
                cell.annotationView.imageView.image = UIImage(named: "ActivityType--packageDropoff")
                cell.annotationView.labelTextLabel.text = String(NSLocalizedString("annotation.dropoff", comment: "title for dropoff annotation view"))
                cell.annotationView.imageView.tintColor = Theme().grayTextColor
                cell.annotationView.imageView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
                cell.annotationView.labelContainer.backgroundColor = Theme().grayTextColor
                cell.annotationView.circleMask.layer.borderColor = Theme().grayTextColor.cgColor
            case .packagePickup:
                cell.annotationView.imageView.image = UIImage(named: "ActivityType--packagePickup")
                cell.annotationView.labelTextLabel.text = String(NSLocalizedString("annotation.pickup", comment: "title for pickup annotation view"))
                cell.annotationView.imageView.tintColor = Theme().grayTextColor
                cell.annotationView.imageView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
                cell.annotationView.labelContainer.backgroundColor = Theme().grayTextColor
                cell.annotationView.circleMask.layer.borderColor = Theme().grayTextColor.cgColor
            default:
                print("default")
            }
        }
        return cell
        
    }
    
    private func configureActivityRowViewWithRowViewData(rowView: ActivityRowView, with rowViewData: ActivityRowViewData) {
        if rowViewData.profilePicUrl != nil {
            rowView.imageView.sd_setImage(with: URL(string: rowViewData.profilePicUrl!)!) { (image, error, cacheType, url) in
//                print("loaded image")
            }
        } else {
            rowView.imageView.image = getImage(for: rowViewData.logisticRowType)
        }
        rowView.titleLabel.text = rowViewData.titleText
        rowView.subtitleLabel.text = rowViewData.subtitleText
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.publicActivities.count + 1
    }
    
    private func generateRows(for supplements: [String: Any], with type:ActivitySupplementsType) -> [LogisticsRow] {
        switch type {
        case .delivery:
            print("configure delivery")
            let destination = Location(dict: supplements["destination"] as! [String: Any])
            let moversCount = supplements["movers_count"] as! Int
            let distanceTotal = supplements["distance_total"] as! Double
            
            let totalDistanceformatter = MeasurementFormatter()
            totalDistanceformatter.unitStyle = .long
            totalDistanceformatter.unitOptions = .naturalScale
            totalDistanceformatter.numberFormatter.maximumFractionDigits = 2
            
            let totalDistanceMeasurement = Measurement(value: distanceTotal, unit: UnitLength.meters)
            
            let distanceTotalString = totalDistanceformatter.string(from: totalDistanceMeasurement)
            
            
            let timeTotalformatter = DateComponentsFormatter()
            timeTotalformatter.unitsStyle = .full
            timeTotalformatter.includesApproximationPhrase = false
            timeTotalformatter.includesTimeRemainingPhrase = false
            timeTotalformatter.allowedUnits = [.day, .hour, .minute]
            
            
            let destinationRow = LogisticsRow(circleImageUrl: nil, circleText: nil, circleSubscript: nil, titleText: destination.name ?? string(from: destination.geoPoint), subtitleText: String(NSLocalizedString("label.destination", comment: "label text for recipient annotation view")), tint: Theme().textColor, actions: nil, type: .Destination)
            let moversCountRow = LogisticsRow(circleImageUrl: nil, circleText: nil, circleSubscript: nil, titleText: "\(moversCount)", subtitleText: String(NSLocalizedString("label.moversTotal", comment: "label text for movers total")), tint: Theme().textColor, actions: nil, type: .PersonCount)
            let distanceTotalRow = LogisticsRow(circleImageUrl: nil, circleText: nil, circleSubscript: nil, titleText: distanceTotalString, subtitleText: String(NSLocalizedString("label.distanceTotal", comment: "label text for distance total")), tint: Theme().textColor, actions: nil, type: .Distance)
            return [destinationRow, moversCountRow, distanceTotalRow]
        case .pickup:
            print("configure pickup")
            let recipient = Person(dict: supplements["recipient"] as! [String : Any])
            let destination = Location(dict: supplements["destination"] as! [String: Any])
            let pickupLocation = supplements["pickup_location"] as! GeoPoint
            let pickupLocationCL = CLLocation(latitude: pickupLocation.latitude, longitude: pickupLocation.longitude)
            
            let distanceFormatter = MeasurementFormatter()
            distanceFormatter.unitStyle = .long
            distanceFormatter.unitOptions = .naturalScale
            distanceFormatter.numberFormatter.maximumFractionDigits = 2
            
            let distanceMeasurement = Measurement(value: pickupLocationCL.distance(from: CLLocation(latitude: destination.geoPoint.latitude, longitude: destination.geoPoint.longitude)), unit: UnitLength.meters)
            
            let distanceString = distanceFormatter.string(from: distanceMeasurement)
            
            let recipientRow = LogisticsRow(circleImageUrl: recipient.photoUrl, circleText: nil, circleSubscript: nil, titleText: recipient.displayName, subtitleText: String(NSLocalizedString("label.recipient", comment: "title label for recipient")), tint: Theme().textColor, actions: nil, type: .Person)
            let destinationRow = LogisticsRow(circleImageUrl: nil, circleText: nil, circleSubscript: nil, titleText: destination.name ?? string(from: destination.geoPoint), subtitleText: String(NSLocalizedString("label.destination", comment: "label text for recipient annotation view")), tint: Theme().textColor, actions: nil, type: .Destination)
            let distanceRemainingRow = LogisticsRow(circleImageUrl: nil, circleText: nil, circleSubscript: nil, titleText: distanceString, subtitleText: String(NSLocalizedString("label.distanceRemaining", comment: "label text for distance remaining")), tint: Theme().textColor, actions: nil, type: .Directions)
            return [recipientRow, destinationRow, distanceRemainingRow]
        case .dropoff:
            print("configure dropoff")
            let recipient = Person(dict: supplements["recipient"] as! [String : Any])
            let destination = Location(dict: supplements["destination"] as! [String: Any])
            let dropoffLocation = supplements["dropoff_location"] as! GeoPoint
            let dropoffLocationCL = CLLocation(latitude: dropoffLocation.latitude, longitude: dropoffLocation.longitude)
            let dueDate = (supplements["due_date"] as! Timestamp).dateValue()
            
            let distanceFormatter = MeasurementFormatter()
            distanceFormatter.unitStyle = .long
            distanceFormatter.unitOptions = .naturalScale
            distanceFormatter.numberFormatter.maximumFractionDigits = 2
            
            let distanceRemainingMeasurement = Measurement(value: dropoffLocationCL.distance(from: CLLocation(latitude: destination.geoPoint.latitude, longitude: destination.geoPoint.longitude)), unit: UnitLength.meters)
            
            let distanceRemainingString = distanceFormatter.string(from: distanceRemainingMeasurement)
            
            let timeFormatter = DateComponentsFormatter()
            timeFormatter.unitsStyle = .full
            timeFormatter.includesApproximationPhrase = false
            timeFormatter.includesTimeRemainingPhrase = false
            timeFormatter.allowedUnits = [.day, .hour, .minute]
            
            let timeRemainingString = (dueDate.timeIntervalSince1970 - Date().timeIntervalSince1970) > 0 ? timeFormatter.string(from: dueDate.timeIntervalSince1970 - Date().timeIntervalSince1970)! : String(NSLocalizedString("label.due", comment: "label text for due"))
            
            let recipientRow = LogisticsRow(circleImageUrl: recipient.photoUrl, circleText: nil, circleSubscript: nil, titleText: recipient.displayName, subtitleText: String(NSLocalizedString("label.recipient", comment: "title label for recipient")), tint: Theme().textColor, actions: nil, type: .Person)
            let distanceRemainingRow = LogisticsRow(circleImageUrl: nil, circleText: nil, circleSubscript: nil, titleText: distanceRemainingString, subtitleText: String(NSLocalizedString("label.distanceRemaining", comment: "label text for distance remaining")), tint: Theme().textColor, actions: nil, type: .Directions)
            let timeRemainingRow = LogisticsRow(circleImageUrl: nil, circleText: nil, circleSubscript: nil, titleText: timeRemainingString, subtitleText: String(NSLocalizedString("label.timeRemaining", comment: "label text for time remaining")), tint: Theme().textColor, actions: nil, type: .Time)
            return [recipientRow, distanceRemainingRow, timeRemainingRow]
        case .unknown:
            print("configure unknown")
            return []
        }
    }
    
    private func generateAnnotations(for supplements: [String: Any], with type:ActivitySupplementsType) -> [MKAnnotation] {
        switch type {
        case .delivery:
            print("configure delivery")
            let recipient = Person(dict: supplements["recipient"] as! [String : Any])
            let destination = Location(dict: supplements["destination"] as! [String: Any])
            let destinationAnnotation = ActivityDeliveryAnnotation(with: recipient.displayName, subtitle: destination.name ?? nil, coordinate: coordinate(from: destination.geoPoint), person: recipient)
            return [destinationAnnotation]
        case .pickup:
            print("configure pickup")
            let pickupAnnotation = ActivityPickupAnnotation(with: "Pickup Annotation", subtitle: nil, coordinate: coordinate(from: supplements["pickup_location"] as! GeoPoint))
            return [pickupAnnotation]
        case .dropoff:
            print("configure dropoff")
            let dropoffAnnotation = ActivityDropoffAnnotation(with: "Dropoff Location", subtitle: nil, coordinate: coordinate(from: supplements["dropoff_location"] as! GeoPoint))
            return [dropoffAnnotation]
        case .unknown:
            print("configure unknown")
            return []
        }
    }

}

extension ActivitiesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected \(indexPath.row)")
        if indexPath.row != tableView.numberOfRows(inSection: 0) - 1 {
            let activity = self.publicActivities[indexPath.row]
            delegate?.showPackageDetail(with: activity.objectReference.documentID, and: activity.objectName)
        } else {
            print("selected last row")
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !self.noMorePublicActivities && !self.queryInProgress && indexPath.row == self.publicActivities.count {
            print("fetch more public activities")
            fetchMorePublicActivities()
        }
    }
}

extension ActivitiesViewController: TTTAttributedLabelDelegate {
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        print(url.absoluteString)
        let decodedString = url.absoluteString.removingPercentEncoding!
        let parameters = decodedString.split(separator: "/")
        let key = String(parameters[0])
        let value = String(parameters[1])
        
        if key == "packages" {
            let headline = String(parameters[2])
            delegate?.showPackageDetail(with: value, and: headline)
        }


    }
}

