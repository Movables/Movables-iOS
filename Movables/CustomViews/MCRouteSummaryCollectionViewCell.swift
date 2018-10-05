//
//  MCRouteSummaryCollectionViewCell.swift
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

class MCRouteSummaryCollectionViewCell: UICollectionViewCell {
    
    var parentView: UIView!
    var cardView: UIView!
    var mapView: MKMapView!
    var contentStackView: UIStackView!
    
    var transitRecord: TransitRecord!
    var units: [LogisticsRow]!
    var presentingVC: DropoffSummaryViewController!
    
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
        mapView.showsUserLocation = false
        mapView.isZoomEnabled = false
        mapView.isPitchEnabled = false
        mapView.isRotateEnabled = false
        mapView.isScrollEnabled = false
        mapView.delegate = self
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "originView")
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
        let pickup = PickupAnnotation(with: transitRecord)
        let dropoff = DropoffAnnotation(with: transitRecord)

        let annotations = [pickup, dropoff] as! [MKAnnotation]
        var boundingRect: MKMapRect?
        var coords:[CLLocationCoordinate2D] = []
        for movement in self.transitRecord.movements! {
            coords.append(CLLocationCoordinate2D(latitude: movement.geoPoint.latitude, longitude: movement.geoPoint.longitude))
        }
        coords.append(dropoff.coordinate)
        let polyline = MKPolyline(coordinates: coords, count: coords.count)
        print("number of coords in dropoff summary: \(coords.count)")
        boundingRect = polyline.boundingMapRect
        self.mapView.addOverlay(polyline, level: .aboveRoads)
        
        self.mapView.addAnnotations(annotations)
        self.mapView.setVisibleMapRect(boundingRect!, edgePadding: UIEdgeInsets(top: 45, left: 45, bottom: 25, right: 45), animated: false)
        self.presentingVC.movementRouteDrawn = true

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
                } else if unit.type == .Award {
                    imageView.image = UIImage(named: "award_25pt")
                } else if unit.type == .Balance {
                    imageView.image = UIImage(named: "balance_25pt")
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
                        button.setImage(getImageForActionType(actionType: action.type), for: .normal)
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
    
    
}

extension MCRouteSummaryCollectionViewCell: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let userLocation = annotation as? MKUserLocation {
            userLocation.title = ""
            return nil
        }
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: "originView", for: annotation) as! MKMarkerAnnotationView
        if annotation.isMember(of: DropoffAnnotation.self) {
            view.glyphImage = UIImage(named: "destination_glyph_40pt")
        } else if annotation.isMember(of: PickupAnnotation.self) {
            view.glyphImage = UIImage(named: "navigation_glyph_40pt")
        } else {
            view.glyphImage = UIImage(named: "origin_glyph_40pt")
        }
        view.markerTintColor = Theme().mapStampTint
        view.titleVisibility = .visible
        view.isEnabled = false
        view.clusteringIdentifier = nil
        view.displayPriority = .required
        return view
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = Theme().keyTint.withAlphaComponent(0.7)
        renderer.lineWidth = 3.0
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let userLocationView = mapView.view(for: userLocation)
        userLocationView?.canShowCallout = false
        userLocationView?.isEnabled = false
    }
}

func getImageForActionType(actionType: ActionType) -> UIImage {
    switch actionType {
    case .Call:
        return UIImage(named: "phone_50pt")!
    case .Tweet:
        return UIImage(named: "twitter_50pt")!
    case .Facebook:
        return UIImage(named: "facebook_50pt")!
    default:
        return UIImage(named: "more_50pt")!
    }
}

