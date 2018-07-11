//
//  MonitorViewController.swift
//  Movables
//
//  Created by Eddie Chen on 5/10/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit
import GoogleSignIn
import MapKit
import CoreLocation
import Firebase
import NVActivityIndicatorView
import TTTAttributedLabel

protocol MonitorViewControllerDelegate: class {
    func showPackageDetail(with packageId: String, and headline: String)
}


class MonitorViewController: UIViewController {
    
    var delegate: MonitorViewControllerDelegate?
    var mainCoordinatorDelegate: MainCoordinatorDelegate?
    var mainCoordinator: MainCoordinator?
    var tableView: UITableView!
    var activityIndicatorView: NVActivityIndicatorView!
    var refreshControl: UIRefreshControl!
    
    var emptyStateView: EmptyStateView!

    var publicActivities: [PublicActivity]?
    
    var rowsForIndexPaths: [IndexPath: [LogisticsRow]] = [:]
    var annotationsForIndexPaths: [IndexPath: [MKAnnotation]] = [:]
    var mapPreviewImagesForIndexPaths: [IndexPath: UIImage] = [:] {
        didSet {
            if mapPreviewImagesForIndexPaths.count == self.annotationsForIndexPaths.count {
                DispatchQueue.main.async {
                    self.activityIndicatorView.stopAnimating()
                    if self.publicActivities!.count == 0 {
                        self.emptyStateView.isHidden = false
                    } else {
                        self.emptyStateView.isHidden = true
                    }
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        setupTableView()
        fetchPublicActivities()
    }
    
    private func fetchPublicActivities() {
        let db = Firestore.firestore()
        db.collection("public_activities").whereField("followers.\(Auth.auth().currentUser!.uid)", isGreaterThan: 0).order(by: "followers.\(Auth.auth().currentUser!.uid)", descending: true).getDocuments { (querySnapshot, error) in
            if let error = error {
                print(error)
                return
            } else {
                if let snapshot = querySnapshot {
                    var publicActivitiesTemp:[PublicActivity] = []
                    snapshot.documents.forEach({ (docSnapshot) in
                        publicActivitiesTemp.append(PublicActivity(with: docSnapshot.data()))
                    })
                    self.publicActivities = publicActivitiesTemp
                    self.rowsForIndexPaths.removeAll()
                    self.annotationsForIndexPaths.removeAll()
                    for (index, activity) in self.publicActivities!.enumerated() {
                        self.rowsForIndexPaths.updateValue(self.generateRows(for: activity.supplements!, with: activity.supplementsType!), forKey: IndexPath(row: index, section: 0))
                    self.annotationsForIndexPaths.updateValue(self.generateAnnotations(for: activity.supplements!, with: activity.supplementsType!), forKey: IndexPath(row: index, section: 0))
                    }
                    
                    self.generateMapImages()
                } else {
                    print("snapshot nil")
                }
            }
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
        
        tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = Theme().backgroundShade
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 250
        tableView.separatorStyle = .none
        tableView.register(ActivityTableViewCell.self, forCellReuseIdentifier: "activityCell")
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didRefresh(sender:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        activityIndicatorView = NVActivityIndicatorView(frame: .zero, type: .ballScale, color: Theme().textColor, padding: 0)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.startAnimating()
        tableView.backgroundView = activityIndicatorView
        
        emptyStateView = EmptyStateView(frame: .zero)
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.titleLabel.text = "Wanna see something?"
        emptyStateView.subtitleLabel.text = "Gotta do something first."
        emptyStateView.actionButton.isHidden = true
        emptyStateView.isHidden = true
        view.addSubview(emptyStateView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            activityIndicatorView.heightAnchor.constraint(equalToConstant: 50),
            activityIndicatorView.widthAnchor.constraint(equalToConstant: 50),
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

extension MonitorViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // activity row
        let cell = tableView.dequeueReusableCell(withIdentifier: "activityCell") as! ActivityTableViewCell
        let activity = self.publicActivities![indexPath.row]
        let eventText = generateLabelTextForPublicActivity(publicActivity: activity)
        cell.userEventView.eventLabel.text = eventText
        if activity.actorPic != nil {
            cell.userEventView.profilePicImageView.sd_setImage(with: URL(string: activity.actorPic!)) { (image, error, cacheType, url) in
                print("loaded actor pic")
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
        cell.imageMapView.image = self.mapPreviewImagesForIndexPaths[indexPath]
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
                print("loaded image")
            }
        } else {
            rowView.imageView.image = getImage(for: rowViewData.logisticRowType)
        }
        rowView.titleLabel.text = rowViewData.titleText
        rowView.subtitleLabel.text = rowViewData.subtitleText
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.publicActivities?.count ?? 0
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
            
            
            let destinationRow = LogisticsRow(circleImageUrl: nil, circleText: nil, circleSubscript: nil, titleText: destination.name ?? string(from: destination.geoPoint), subtitleText: "Destination", tint: Theme().textColor, actions: nil, type: .Destination)
            let moversCountRow = LogisticsRow(circleImageUrl: nil, circleText: nil, circleSubscript: nil, titleText: "\(moversCount)", subtitleText: "Movers", tint: Theme().textColor, actions: nil, type: .PersonCount)
            let distanceTotalRow = LogisticsRow(circleImageUrl: nil, circleText: nil, circleSubscript: nil, titleText: distanceTotalString, subtitleText: "Distance Total", tint: Theme().textColor, actions: nil, type: .Distance)
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
            let destinationRow = LogisticsRow(circleImageUrl: nil, circleText: nil, circleSubscript: nil, titleText: destination.name ?? string(from: destination.geoPoint), subtitleText: "Destination", tint: Theme().textColor, actions: nil, type: .Destination)
            let distanceRemainingRow = LogisticsRow(circleImageUrl: nil, circleText: nil, circleSubscript: nil, titleText: distanceString, subtitleText: "Distance Remaining", tint: Theme().textColor, actions: nil, type: .Directions)
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
            timeFormatter.includesTimeRemainingPhrase = true
            timeFormatter.allowedUnits = [.day, .hour, .minute]
            
            let timeRemainingString = (dueDate.timeIntervalSince1970 - Date().timeIntervalSince1970) > 0 ? timeFormatter.string(from: dueDate.timeIntervalSince1970 - Date().timeIntervalSince1970)! : "Due"
            
            let recipientRow = LogisticsRow(circleImageUrl: recipient.photoUrl, circleText: nil, circleSubscript: nil, titleText: recipient.displayName, subtitleText: String(NSLocalizedString("label.recipient", comment: "title label for recipient")), tint: Theme().textColor, actions: nil, type: .Person)
            let distanceRemainingRow = LogisticsRow(circleImageUrl: nil, circleText: nil, circleSubscript: nil, titleText: distanceRemainingString, subtitleText: "Distance Remaining", tint: Theme().textColor, actions: nil, type: .Directions)
            let timeRemainingRow = LogisticsRow(circleImageUrl: nil, circleText: nil, circleSubscript: nil, titleText: timeRemainingString, subtitleText: "Time Remaining", tint: Theme().textColor, actions: nil, type: .Time)
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

extension MonitorViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected \(indexPath.row)")
        let activity = self.publicActivities![indexPath.row]
        delegate?.showPackageDetail(with: activity.objectReference.documentID, and: activity.objectName)
    }
}

extension MonitorViewController: TTTAttributedLabelDelegate {
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

