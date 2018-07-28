//
//  DeliveryLogisticsCollectionViewCell.swift
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

enum ActionType {
    case Call
    case Tweet
    case More
}

enum LogisticsRowType {
    case Person
    case Time
    case Destination
    case Directions
    case Award
    case Balance
    case PersonCount
    case Distance
}

struct LogisticsRow {
    var circleImageUrl: String?
    var circleText: String?
    var circleSubscript: String?
    var titleText: String!
    var subtitleText: String
    var tint: UIColor
    var actions: [Action]?
    var type: LogisticsRowType
    
    init(circleImageUrl: String?, circleText: String?, circleSubscript: String?, titleText: String, subtitleText: String, tint: UIColor?, actions: [Action]?, type: LogisticsRowType) {
        self.circleImageUrl = circleImageUrl
        self.circleText = circleText
        self.circleSubscript = circleSubscript
        self.titleText = titleText
        self.subtitleText = subtitleText
        self.tint = tint ?? Theme().keyTint
        self.actions = actions
        self.type = type
    }
}

struct Action {
    var type: ActionType
    var dictionary: [String: Any]
    
    init(type: ActionType, dictionary: [String: Any]) {
        self.type = type
        self.dictionary = dictionary
    }
}


class DeliveryLogisticsCollectionViewCell: UICollectionViewCell {
    
    var parentView: UIView!
    var cardView: UIView!
    var mapView: MKMapView!
    var contentStackView: UIStackView!

    var originCoordinate: CLLocationCoordinate2D!
    var currentLocationCoordinate: CLLocationCoordinate2D!
    var destinationCoordinate: CLLocationCoordinate2D!
    var units: [LogisticsRow]!
    var presentingVC: UIViewController!
    
    var transitRecords: [TransitRecord]?
    var progressOverlay: MKPolyline?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupParentView()
        setupCardView()
        setupMapViewContentStackView()
    }
    
    private func setupParentView() {
        parentView = UIView(frame: .zero)
        parentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(parentView)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[parentView(screenWidth)]|", options: .directionLeadingToTrailing, metrics: ["screenWidth": UIScreen.main.bounds.width], views: ["parentView": parentView]) + NSLayoutConstraint.constraints(withVisualFormat: "V:|[parentView]|", options: .alignAllLeading, metrics: nil, views: ["parentView": parentView]))
    }
    
    private func setupCardView() {
        cardView = UIView(frame: .zero)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.clipsToBounds = true
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 8
        cardView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        cardView.layer.borderColor = Theme().keyTint.withAlphaComponent(0.3).cgColor
        cardView.layer.borderWidth = 1
        parentView.addSubview(cardView)
        
        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-18-[cardView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["cardView": cardView]) + NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[cardView]", options: .alignAllLeading, metrics: nil, views: ["cardView": cardView]))
        let bottomConstraint = NSLayoutConstraint(item: cardView, attribute: .bottom, relatedBy: .equal, toItem: parentView, attribute: .bottom, multiplier: 1, constant: -18)
        bottomConstraint.priority = .defaultHigh
        parentView.addConstraint(bottomConstraint)
    }
    
    private func setupMapViewContentStackView() {
        mapView = MKMapView(frame: .zero)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.tintColor = Theme().keyTint
        mapView.mapType = .mutedStandard
        mapView.showsPointsOfInterest = false
        mapView.showsUserLocation = true
        mapView.isZoomEnabled = false
        mapView.isPitchEnabled = false
        mapView.isRotateEnabled = false
        mapView.isScrollEnabled = false
        mapView.layoutMargins = UIEdgeInsets(top: 45, left: 45, bottom: 25, right: 45)
        mapView.delegate = self
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "markerView")
        cardView.addSubview(mapView)
                
        contentStackView = UIStackView(frame: .zero)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.alignment = .leading
        contentStackView.spacing = 18
        contentStackView.distribution = .equalSpacing
        cardView.addSubview(contentStackView)

        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[mapView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["mapView": mapView])
        
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[mapView(200)]-18-[contentStackView]-18-|", options: [.alignAllLeading, .alignAllTrailing], metrics: nil, views: ["mapView": mapView, "contentStackView": contentStackView])
        
        cardView.addConstraints(hConstraints + vConstraints)

    }
    
    func activateMapView() {
        let origin = OriginAnnotation(with: originCoordinate)
        let currentLocation = CurrentLocationAnnotation(with: currentLocationCoordinate)
        let recipient = RecipientAnnotation(with: destinationCoordinate)
        let annotations = [origin, currentLocation, recipient] as! [MKAnnotation]
        layoutIfNeeded()
        
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: currentLocation.coordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: recipient.coordinate))
        request.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: request)
        
        directions.calculate(completionHandler: {(response, error) in
            var boundingRect: MKMapRect?
            if error != nil {
                print("Error getting directions")
            } else {
                print(response!.routes.count)
                for route in response!.routes {
                    self.mapView.add(route.polyline,
                                     level: MKOverlayLevel.aboveRoads)
                    boundingRect = route.polyline.boundingMapRect
                }
            }
            
            LocationManager.shared.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            LocationManager.shared.requestLocation()
            
            let coordinates = [LocationManager.shared.location!.coordinate, currentLocation.coordinate, recipient.coordinate]
            let mapPoints = coordinates.map { MKMapPointForCoordinate($0) }
            let mapRects = mapPoints.map { MKMapRect(origin: $0, size: MKMapSize(width: 1, height: 1)) }
            let fittingRect = mapRects.reduce(MKMapRectNull, MKMapRectUnion)
            
            if boundingRect != nil {
                self.mapView.addAnnotations(annotations)
                self.mapView.setVisibleMapRect(MKMapRectUnion(fittingRect, boundingRect!), edgePadding: .zero, animated: false)
            } else {
                self.mapView.layoutMargins = UIEdgeInsets(top: 45, left: 80, bottom: 100, right: 80)
                self.mapView.showAnnotations([recipient, origin], animated: false)
            }
            
            if self.presentingVC.isMember(of: CreatePackageReviewViewController.self) {
                (self.presentingVC as! CreatePackageReviewViewController).deliveryRouteDrawn = true
            } else {
                (self.presentingVC as! PackageDetailViewController).deliveryRouteDrawn = true
            }

        })
        
    }
    
    func activateMapTransitRecords() {
        if self.presentingVC.isMember(of: PackageDetailViewController.self) {
            let package = (self.presentingVC as! PackageDetailViewController).package
            package?.reference.collection("transit_records").getDocuments(completion: { (querySnapshot, error) in
                guard let snapshot = querySnapshot else {
                    print(error?.localizedDescription)
                    return
                }
                var transitRecordsTemp:[TransitRecord] = []
                for document in snapshot.documents {
                    transitRecordsTemp.append(TransitRecord(dict: document.data(), reference: document.reference))
                }
                self.transitRecords = transitRecordsTemp
//                var boundingRect: MKMapRect?
                var coords:[CLLocationCoordinate2D] = []
                for transitRecord in self.transitRecords! {
                    if transitRecord.pickupGeoPoint != nil {
                        coords.append(CLLocationCoordinate2D(latitude: transitRecord.pickupGeoPoint!.latitude, longitude: transitRecord.pickupGeoPoint!.longitude))
                    }
                    if transitRecord.dropoffGeoPoint != nil {
                        coords.append(CLLocationCoordinate2D(latitude: transitRecord.dropoffGeoPoint!.latitude, longitude: transitRecord.dropoffGeoPoint!.longitude))
                    }
                }
                self.progressOverlay = MKPolyline(coordinates: coords, count: coords.count)
//                boundingRect = self.progressOverlay!.boundingMapRect
                self.mapView.add(self.progressOverlay!, level: .aboveRoads)
                (self.presentingVC as! PackageDetailViewController).fetchedTransitRecords = true
            })
            
        }
    }
    
    func activateStackView() {
        if contentStackView.arrangedSubviews.count != units.count {
            
            for unit in units {
                
                let personContainerView = UIView(frame: .zero)
                personContainerView.translatesAutoresizingMaskIntoConstraints = false
                contentStackView.addArrangedSubview(personContainerView)
                
                let imageView = UIImageView(frame: .zero)
                if unit.type == .Person && unit.circleImageUrl != nil {
                    if !unit.circleImageUrl!.isEmpty {
                        imageView.sd_setImage(with: URL(string: unit.circleImageUrl!)) { (image, error, cacheType, url) in
                            if error != nil {
                                print(error?.localizedDescription)
                            }
                        }
                    } else {
                        imageView.image = UIImage(named: "profile_25pt")
                    }
                } else if unit.type == .Person {
                    imageView.image = UIImage(named: "profile_25pt")
                } else if unit.type == .Time {
                    imageView.image = UIImage(named: "timer_25pt")
                } else if unit.type == .Directions {
                    imageView.image = UIImage(named: "directions_25pt")
                } else {
                    imageView.image = UIImage(named: "profile_25pt")
                }
                imageView.translatesAutoresizingMaskIntoConstraints = false
                imageView.layer.cornerRadius = 24
                imageView.clipsToBounds = true
                imageView.tintColor = unit.tint
                imageView.backgroundColor = unit.tint.withAlphaComponent(0.1)
                imageView.contentMode = .scaleAspectFill
                personContainerView.addSubview(imageView)
                
                let labelsView = UIView(frame: .zero)
                labelsView.translatesAutoresizingMaskIntoConstraints = false
                personContainerView.addSubview(labelsView)
                
                let titleLabel = UILabel(frame: .zero)
                titleLabel.translatesAutoresizingMaskIntoConstraints = false
                titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
                titleLabel.text = unit.titleText
                titleLabel.textColor = Theme().textColor
                titleLabel.numberOfLines = 0
                labelsView.addSubview(titleLabel)
                
                let subtitleLabel = UILabel(frame: .zero)
                subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
                subtitleLabel.font = UIFont.systemFont(ofSize: 11, weight: .medium)
                subtitleLabel.text = unit.subtitleText.uppercased()
                subtitleLabel.textColor = Theme().grayTextColor
                subtitleLabel.numberOfLines = 1
                labelsView.addSubview(subtitleLabel)
                
                let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[titleLabel]|", options: .directionLeadingToTrailing, metrics: nil, views: ["titleLabel": titleLabel, "subtitleLabel": subtitleLabel])
                let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-1-[subtitleLabel]-2-[titleLabel]|", options: [.alignAllLeading, .alignAllTrailing], metrics: nil, views: ["titleLabel": titleLabel, "subtitleLabel": subtitleLabel])
                labelsView.addConstraints(hConstraints + vConstraints)
                
                let buttonsStackView = UIStackView(frame: .zero)
                buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
                buttonsStackView.axis = .horizontal
                buttonsStackView.spacing = 18
                buttonsStackView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
                personContainerView.addSubview(buttonsStackView)
                buttonsStackView.trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor, constant: -18).isActive = true
                
                if unit.actions != nil {
                    for action in unit.actions! {
                        let button = UIButton(frame: .zero)
                        button.translatesAutoresizingMaskIntoConstraints = false
                        button.tintColor = Theme().grayTextColor
                        button.setImage(getImageForActionType(actionType: action.type), for: .normal)
                        button.setBackgroundColor(color: Theme().borderColor, forUIControlState: .highlighted)
                        button.clipsToBounds = true
                        button.layer.cornerRadius = 22
                        buttonsStackView.addArrangedSubview(button)
                        personContainerView.addConstraints([
                            NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 44),
                            NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 44)
                            ])
                    }
                }
                
                personContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView(48)]-4-|", options: .alignAllLeading, metrics: nil, views: ["imageView": imageView]))
                
                personContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[imageView(48)]-8-[labelsView]->=0-[buttonsStackView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["imageView": imageView, "labelsView": labelsView, "buttonsStackView": buttonsStackView]))
                
                personContainerView.addConstraint(NSLayoutConstraint(item: labelsView, attribute: .centerY, relatedBy: .equal, toItem: imageView, attribute: .centerY, multiplier: 1, constant: 0))
                
                personContainerView.addConstraint(NSLayoutConstraint(item: buttonsStackView, attribute: .centerY, relatedBy: .equal, toItem: personContainerView, attribute: .centerY, multiplier: 1, constant: 0))
                
            }
        }
    }
    
    private func getImageForActionType(actionType: ActionType) -> UIImage {
        switch actionType {
        case .Call:
            return UIImage(named: "phone_50pt")!
        case .Tweet:
            return UIImage(named: "twitter_50pt")!
        default:
            return UIImage(named: "more_50pt")!
        }
    }

}

extension DeliveryLogisticsCollectionViewCell: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let userLocation = annotation as? MKUserLocation {
            userLocation.title = ""
            return nil
        }
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: "markerView", for: annotation) as! MKMarkerAnnotationView
        if annotation.isMember(of: RecipientAnnotation.self) {
            view.glyphImage = UIImage(named: "destination_glyph_40pt")
            view.displayPriority = .required
        } else if annotation.isMember(of: CurrentLocationAnnotation.self) {
            view.glyphImage = UIImage(named: "navigation_glyph_40pt")
            view.displayPriority = .required
        } else {
            view.glyphImage = UIImage(named: "origin_glyph_40pt")
        }
        view.markerTintColor = Theme().mapStampTint
        view.titleVisibility = .visible
        view.isEnabled = false
        view.clusteringIdentifier = nil
        return view
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.lineWidth = 3.0
        if overlay.isEqual(self.progressOverlay)  {
            renderer.strokeColor = Theme().keyTint.withAlphaComponent(0.7)
        } else {
            renderer.strokeColor = Theme().routeTint
            renderer.lineDashPattern = [5, 10]
        }
        return renderer
    }
}
