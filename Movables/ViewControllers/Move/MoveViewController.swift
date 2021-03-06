//
//  MoveViewController.swift
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
import MapKit
import Firebase
import CountdownLabel

protocol MoveViewControllerDelegate: class {
    func showPackageDetail(with package: Package)
}

class MoveViewController: UIViewController {
    let ACTIONABLE_DISTANCE = 100.0
    let TOO_FAR_DISTANCE = 50000.0

    @IBOutlet weak var mapView: MKMapView!
    var mapCameraSet: Bool = false
    var routeToDestinationDrawn: Bool = false
    
    var proposedRouteOverlay: MKOverlay?
    
    var mainCoordinator: MainCoordinator?
    var mainCoordinatorDelegate: MainCoordinatorDelegate?
    
    var delegate: MoveViewControllerDelegate?
    
    var currentPackageListener: ListenerRegistration?
    var currentTransitRecordListener: ListenerRegistration?

    var moveCardView: MCMoveCardView!
    var emptyStateCardView: MCEmptyStateCardView!
    
    var userDocument: UserDocument? {
        didSet {
            refreshCardState()
        }
    }
    
    var moveLocationManager: CLLocationManager = CLLocationManager()
    
    var currentPackage: Package? {
        didSet {
            if currentPackage != nil {
                self.listenToTransitRecord()
                self.routeToDestinationDrawn = false
                self.progress = nil
            } else {
                self.currentPackageListener?.remove()
                self.currentTransitRecordListener?.remove()
                self.moveCardView.isHidden = true
                self.emptyStateCardView.isHidden = false
                self.mapView.removeOverlays(self.mapView.overlays)
                self.mapView.removeAnnotations(self.mapView.annotations)
            }
        }
    }
    
    var currentTransitRecord: TransitRecord? {
        didSet {
            if currentTransitRecord != nil {
                self.moveCardView.isHidden = false
                if self.currentPackage != nil {
                    self.moveCardView.pillView.pillContainerView.backgroundColor = getTintForCategory(category: self.currentPackage!.category)
                }
                self.emptyStateCardView.isHidden = true
                self.progress = nil
            } else {
                self.moveCardView.isHidden = true
                self.emptyStateCardView.isHidden = false
                self.mapView.removeOverlays(self.mapView.overlays)
                self.mapView.removeAnnotations(self.mapView.annotations)
            }
        }
    }
    
    var movements: [TransitMovement]?
    
    private var progress: ProgressPath?
    private var progressPathRenderer: ProgressPathRenderer?
    private var drawingAreaRenderer: MKPolygonRenderer?   // shown if kDebugShowArea is set to 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Go"
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        moveLocationManager.delegate = self
        moveLocationManager.activityType = .fitness
        
        mapView.tintColor = Theme().keyTint
        mapView.showsUserLocation = true
        mapView.mapType = .mutedStandard
        mapView.showsPointsOfInterest = false
        mapView.showsCompass = false
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = true
        mapView.delegate = self
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "originView")

        emptyStateCardView = MCEmptyStateCardView(frame: .zero)
        emptyStateCardView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateCardView.isHidden = true
        emptyStateCardView.actionButton.addTarget(self, action: #selector(addPackageButtonTapped(sender:)), for: .touchUpInside)
        view.addSubview(emptyStateCardView)
        
        view.addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[emptyStateCardView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["emptyStateCardView": emptyStateCardView])
        )
        NSLayoutConstraint.activate([
            emptyStateCardView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            emptyStateCardView.heightAnchor.constraint(greaterThanOrEqualTo: self.view.heightAnchor, multiplier: 3 / 7, constant: -8),
            emptyStateCardView.containerView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -44),
        ])

        
        moveCardView = MCMoveCardView(frame: .zero)
        moveCardView.translatesAutoresizingMaskIntoConstraints = false
        moveCardView.isHidden = true
        view.addSubview(moveCardView)
        
        view.addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[moveCardView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["moveCardView": moveCardView])
        )
        NSLayoutConstraint.activate([
            moveCardView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            moveCardView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 3 / 7, constant: -8),
            moveCardView.dropoffButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -18)
            ])
        
        
        mapView.layoutMargins = UIEdgeInsets(top: view.safeAreaInsets.top + 94, left: 20, bottom: (self.view.frame.height - (self.view.safeAreaInsets.top + self.view.safeAreaInsets.bottom)) / 3 + 66, right: 20)

        self.userDocument = UserManager.shared.userDocument
        
        NotificationCenter.default.addObserver(self, selector: #selector(userDocumentUpdated(notification:)), name: Notification.Name.currentUserDocumentUpdated, object: nil)
    }
    
    @objc private func userDocumentUpdated(notification: Notification) {
        self.userDocument = (notification.userInfo as! [String: Any])["userDocument"] as? UserDocument
        print("received notification and set userDocument")
    }
    
    func refreshCardState() {
        if userDocument?.privateProfile.currentPackage != nil {
            self.routeToDestinationDrawn = false
            self.progress = nil
            self.listenToPackage()
        } else {
            self.moveCardView.isHidden = true
            self.emptyStateCardView.isHidden = false
            self.mapView.removeOverlays(self.mapView.overlays)
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.progress = nil
            self.currentPackage = nil
            self.currentTransitRecord = nil
        }
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        currentPackageListener?.remove()
        currentTransitRecordListener?.remove()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func addPackageButtonTapped(sender: UIButton) {
        print("add package button tapped")
        sender.isEnabled = false
        // check if current package exists for user
        if userDocument?.privateProfile.currentPackage != nil {
            let alertController = UIAlertController(title: String(NSLocalizedString("copy.alert.unableToCreatePackage", comment: "alert title for unable to create a package")), message: String(NSLocalizedString("copy.alert.unableToCreatePackageDescExisting", comment: "alert body for existing current package")), preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: String(NSLocalizedString("button.ok", comment: "button title for ok")), style: .cancel, handler: { (action) in
                print("canceld no add package alert")
                sender.isEnabled = true
            }))
            self.present(alertController, animated: true, completion: {
                print("presented ")
            })
        } else if userDocument!.privateProfile.pointsBalance < 100.0 {
            let alertController = UIAlertController(title: String(NSLocalizedString("copy.alert.unableToCreatePackage", comment: "alert title for unable to create a package")), message: String(NSLocalizedString("copy.alert.unableToCreatePackageDescCredits", comment: "alert body for insufficient points")), preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: String(NSLocalizedString("button.ok", comment: "button title for ok")), style: .cancel, handler: { (action) in
                print("canceld no add package alert")
                sender.isEnabled = true
            }))
            self.present(alertController, animated: true, completion: {
                print("presented ")
            })
        } else {
            sender.isEnabled = true
            let createPackageCoordinator = CreatePackageCoordinator(rootViewController: self)
            createPackageCoordinator.start()
        }
    }
    
    private func listenToPackage() {
        // fetch current package details
        self.currentPackageListener = userDocument?.privateProfile.currentPackage?.addSnapshotListener({ (documentSnapshot, error) in
            guard let snapshot = documentSnapshot else {
                print("error fetching document: \(error?.localizedDescription)")
                self.moveLocationManager.stopUpdatingHeading()
                self.moveLocationManager.stopUpdatingLocation()
                self.currentPackage = nil
                return
            }
            self.moveLocationManager.startUpdatingHeading()
            self.moveLocationManager.startUpdatingLocation()
            self.moveLocationManager.requestLocation()
            if self.currentPackage != nil {
                let snapshotPackage = Package(snapshot: snapshot)
                if snapshotPackage == self.currentPackage! {
                    print("packages equal")
                } else {
                    print("replace package")
                    self.currentPackage = snapshotPackage
                }
            } else {
                if self.userDocument?.privateProfile.currentPackage != nil {
                    print("set new current package")
                    self.currentPackage = Package(snapshot: snapshot)
                } else {
                    print("clear current package")
                    self.currentPackage = nil
                }
            }
        })
    }
    
    private func updateGoCard() {
        if self.currentPackage != nil {
            self.moveCardView.headlineLabel.text = self.currentPackage?.headline
            self.moveCardView.pillView.bodyLabel.text = self.currentPackage?.topic.name
            self.moveCardView.pillView.characterLabel.text = getEmojiForCategory(category: self.currentPackage!.category)
            self.moveCardView.countdownLabelView.keyLabel.text = String(NSLocalizedString("label.timeRemaining", comment: "label text for time remaining"))
            self.moveCardView.countdownLabelView.valueLabel.setCountDownDate(targetDate: self.currentTransitRecord!.pickupDate!.add(1.hours) as NSDate)
            self.moveCardView.countdownLabelView.valueLabel.start()
            self.moveCardView.distanceLabelView.keyLabel.text = String(NSLocalizedString("label.distanceRemaining", comment: "label text for distance left"))
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapDetailsButton(sender:)))
            self.moveCardView.addGestureRecognizer(tapGestureRecognizer)
            self.moveCardView.dropoffButton.addTarget(self, action: #selector(didTapDropoffButton(sender:)), for: .touchUpInside)
        }
    }
    
    private func listenToTransitRecord() {
        self.currentTransitRecordListener = self.currentPackage?.reference.collection("transit_records").document(userDocument!.publicProfile.uid).addSnapshotListener({ (documentSnapshot, error) in
            guard documentSnapshot != nil else {
                print("Error fetching transit record: \(error?.localizedDescription)")
                self.currentTransitRecord = nil
                return
            }
            if self.userDocument?.privateProfile.currentPackage != nil {
                self.currentTransitRecord = TransitRecord(dict: documentSnapshot!.data()!, reference: documentSnapshot!.reference)
                self.fetchMovements()
                self.updateGoCard()
            }
        })
    }
    
    @objc private func didTapDetailsButton(sender: UITapGestureRecognizer) {
        print("details button tapped")
        delegate?.showPackageDetail(with: self.currentPackage!)
    }
    
    @objc private func didTapDropoffButton(sender: UIButton) {
        print("dropoff button tapped")
        sender.isEnabled = false
        let packageTemp = self.currentPackage!
        dropoffPackage(with: self.currentPackage!.reference, userReference: self.userDocument!.reference) { (success, response, alertVC) in
            if alertVC != nil {
                self.present(alertVC!, animated: true, completion: {
                    print("presented alert")
                    sender.isEnabled = true
                })
            } else {
                self.mainCoordinatorDelegate?.presentDropoffDialog(with: packageTemp, response: response!)
                sender.isEnabled = true
                self.currentPackage = nil
                self.currentTransitRecord = nil
            }
        }
    }
}

extension MoveViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if !routeToDestinationDrawn {
            drawRouteToDestination()
        }
        let userLocationView = mapView.view(for: userLocation)
        userLocationView?.canShowCallout = false
        userLocationView?.isEnabled = false
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        var renderer: MKOverlayRenderer? = nil
        if overlay is ProgressPath {
            if self.progressPathRenderer == nil {
                progressPathRenderer = ProgressPathRenderer(overlay: overlay)
            }
            renderer = self.progressPathRenderer
        } else if self.proposedRouteOverlay != nil && overlay.isEqual(self.proposedRouteOverlay!) {
            let proposedRouteRenderer = MKPolylineRenderer(overlay: overlay)
            proposedRouteRenderer.strokeColor = Theme().routeTint
            proposedRouteRenderer.lineWidth = 3.0
            proposedRouteRenderer.lineDashPattern = [5, 10]
            return proposedRouteRenderer
        }
        return renderer ?? MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let userLocation = annotation as? MKUserLocation {
            userLocation.title = ""
            return nil
        }
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: "originView", for: annotation) as! MKMarkerAnnotationView
        if annotation.isMember(of: RecipientAnnotation.self) {
            view.glyphImage = UIImage(named: "destination_glyph_40pt")
        } else if annotation.isMember(of: PickupAnnotation.self) {
            view.glyphImage = UIImage(named: "navigation_glyph_40pt")
        } else {
            view.glyphImage = UIImage(named: "origin_glyph_40pt")
        }
        view.markerTintColor = Theme().mapStampTint
        view.titleVisibility = .adaptive
        view.isEnabled = false
        view.clusteringIdentifier = nil
        view.displayPriority = .required
        return view
    }

}

extension MoveViewController: CLLocationManagerDelegate {
    
    private func coordinateRegionWithCenter(_ centerCoordinate: CLLocationCoordinate2D, approximateRadiusInMeters radiusInMeters: CLLocationDistance) -> MKCoordinateRegion {
        // Multiplying by MKMapPointsPerMeterAtLatitude at the center is only approximate, since latitude isn't fixed
        //
        let radiusInMapPoints = radiusInMeters * MKMapPointsPerMeterAtLatitude(centerCoordinate.latitude)
        let radiusSquared = MKMapSize(width: radiusInMapPoints, height: radiusInMapPoints)
        
        let regionOrigin = MKMapPoint(centerCoordinate)
        var regionRect = MKMapRect(origin: regionOrigin, size: radiusSquared)
        
        regionRect = regionRect.offsetBy(dx: -radiusInMapPoints/2, dy: -radiusInMapPoints/2)
        
        // clamp the rect to be within the world
        regionRect = regionRect.intersection(.world)
        
        let region = MKCoordinateRegion(regionRect)
        return region
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("did fail with error: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty {
            let newLocation = locations[0]
            if self.currentPackage != nil && self.moveCardView.isHidden == false {
                
                let distanceLeftFormatter = MeasurementFormatter()
                distanceLeftFormatter.unitStyle = .long
                distanceLeftFormatter.unitOptions = .naturalScale
                distanceLeftFormatter.numberFormatter.maximumIntegerDigits = 3
                distanceLeftFormatter.numberFormatter.maximumFractionDigits = 0
                let currentLocation = locations.first!
                let destinationLocation = CLLocation(latitude: self.currentPackage!.destination.geoPoint.latitude, longitude: self.currentPackage!.destination.geoPoint.longitude)
                let distanceLeftString = distanceLeftFormatter.string(from: Measurement(value: currentLocation.distance(from: destinationLocation), unit: UnitLength.meters))
                
                self.moveCardView.distanceLabelView.valueLabel.text = distanceLeftString
                if self.progress != nil {
                    var boundingMapRectChanged = false
                    var updateRect = self.progress!.addCoordinate(newLocation.coordinate, boundingMapRectChanged: &boundingMapRectChanged)
                    if boundingMapRectChanged {
                        self.mapView.removeOverlay(self.progress! as MKOverlay)
                        self.progressPathRenderer = nil
                        self.mapView.addOverlay(self.progress!, level: .aboveRoads)
                    }
                    if !updateRect.isNull {
                        // There is a non null update rect.
                        // Compute the currently visible map zoom scale
                        let currentZoomScale = MKZoomScale(self.mapView.bounds.size.width / CGFloat(self.mapView.visibleMapRect.size.width))
                        // Find out the line width at this zoom scale and outset the updateRect by that amount
                        let lineWidth = MKRoadWidthAtZoomScale(currentZoomScale)
                        updateRect = updateRect.insetBy(dx: Double(-lineWidth), dy: Double(-lineWidth))
                        // Ask the overlay view to update just the changed area.
                        self.progressPathRenderer?.setNeedsDisplay(updateRect)
                        print("updated rect")
                        self.recordMovement(at: newLocation)
                    }
                }
            }
        }
    }
    
    private func fetchMovements() {
        print("fetch movements now")
        let movementsTemp:[TransitMovement] = currentTransitRecord?.movements ?? []
        self.movements = movementsTemp
        if self.movements!.isEmpty {
            self.progress = ProgressPath(center: CLLocationCoordinate2D(latitude: self.currentTransitRecord!.pickupGeoPoint!.latitude, longitude: self.currentTransitRecord!.pickupGeoPoint!.longitude))
            self.recordMovement(at: CLLocation(latitude: self.currentTransitRecord!.pickupGeoPoint!.latitude, longitude: self.currentTransitRecord!.pickupGeoPoint!.longitude))
        } else {
            for (index, movement) in self.movements!.enumerated() {
                if index == 0 {
                    self.progress = ProgressPath(center: CLLocationCoordinate2D(latitude: movement.geoPoint.latitude, longitude: movement.geoPoint.longitude))
                    self.mapView.removeOverlay(self.progress as! MKOverlay)
                    self.progressPathRenderer = nil
                    self.mapView.addOverlay(self.progress!, level: .aboveRoads)
                    
                    let r = self.progress!.boundingMapRect
                    var pts: [MKMapPoint] = [
                        MKMapPoint(x: r.minX, y: r.minY),
                        MKMapPoint(x: r.minX, y: r.minY),
                        MKMapPoint(x: r.minX, y: r.minY),
                        MKMapPoint(x: r.minX, y: r.minY),
                        ]
                    let count = pts.count
                    let boundingMapRectOverlay = MKPolygon(points: &pts, count: count)
                    self.mapView.addOverlay(boundingMapRectOverlay, level: .aboveRoads)
                } else {
                    var boundingMapRectChanged = false
                    let newCoordinate = CLLocationCoordinate2D(latitude: movement.geoPoint.latitude, longitude: movement.geoPoint.longitude)
                    var updateRect = self.progress!.addCoordinate(newCoordinate, boundingMapRectChanged: &boundingMapRectChanged)
                    if boundingMapRectChanged {
                        
                    } else if !updateRect.isNull {
                        // There is a non null update rect.
                        // Compute the currently visible map zoom scale
                        let currentZoomScale = MKZoomScale(self.mapView.bounds.size.width / CGFloat(self.mapView.visibleMapRect.size.width))
                        // Find out the line width at this zoom scale and outset the updateRect by that amount
                        let lineWidth = MKRoadWidthAtZoomScale(currentZoomScale)
                        updateRect = updateRect.insetBy(dx: Double(-lineWidth), dy: Double(-lineWidth))
                        // Ask the overlay view to update just the changed area.
                        self.progressPathRenderer?.setNeedsDisplay(updateRect)
                    }
                }
            }
        }
    }

    
    private func recordMovement(at location: CLLocation) {
        let dateString = String(Date().timeIntervalSince1970).components(separatedBy: ".").first!
        print("movements.\(dateString)")
        self.currentTransitRecord?.reference.updateData(["movements.\(dateString)": GeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)])
    }
    
    func drawRouteToDestination() {
        if self.currentPackage != nil && self.currentTransitRecord != nil  {
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: moveLocationManager.location!.coordinate))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: self.currentPackage!.destination.geoPoint.latitude, longitude: self.currentPackage!.destination.geoPoint.longitude)))
            request.requestsAlternateRoutes = false
            
            let directions = MKDirections(request: request)
            
            directions.calculate(completionHandler: {(response, error) in
                
                if error != nil {
                    print("Error getting directions")
                    self.mapView.setUserTrackingMode(.follow, animated: true)
                    self.routeToDestinationDrawn = true
                } else {
                    self.drawMoveRoutesAndStamps(with: response!.routes)
                }
            })
        }
    }
    
    func drawMoveRoutesAndStamps(with routes: [MKRoute]) {
        let pickup = PickupAnnotation(with: self.currentTransitRecord!)
        let recipientCoordinate = CLLocationCoordinate2D(latitude: self.currentPackage!.destination.geoPoint.latitude, longitude: self.currentPackage!.destination.geoPoint.longitude)
        let recipient = RecipientAnnotation(with: recipientCoordinate)
        self.mapView.addAnnotations([
            pickup, recipient
        ])
        for route in routes {
            self.proposedRouteOverlay = route.polyline
            self.mapView.addOverlay(self.proposedRouteOverlay!,
                             level: MKOverlayLevel.aboveRoads)
            print("draw route")
        }
        self.mapView.setUserTrackingMode(.follow, animated: true)
        self.routeToDestinationDrawn = true
    }
}
