//
//  MapRouteViewController.swift
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

class MapRouteViewController: UIViewController {

    var mapView: MKMapView!
    var package: Package!

    var floatingButtonsContainerView: UIView!
    var backButtonBaseView: UIView!
    var backButton: UIButton!
    var bottomConstraintFAB: NSLayoutConstraint!
    
    var transitRecords: [TransitRecord]?
    var progressOverlay: MKPolyline?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: false)
        
        setupMapView()
        setupFAB()
        activateMapView()
        activateMapTransitRecords()
    }
    
    private func setupMapView() {
        mapView = MKMapView(frame: .zero)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.layoutMargins = UIEdgeInsets(top: view.safeAreaInsets.top + 30, left: view.safeAreaInsets.left + 30, bottom: view.safeAreaInsets.bottom + 30, right: view.safeAreaInsets.right + 30)
        mapView.tintColor = Theme().keyTint
        mapView.mapType = .mutedStandard
        mapView.showsPointsOfInterest = false
        mapView.showsUserLocation = true
        mapView.showsCompass = false
        mapView.delegate = self
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "markerView")
        
        let compassButton = MKCompassButton(mapView: mapView)
        compassButton.translatesAutoresizingMaskIntoConstraints = false
        compassButton.compassVisibility = .visible
        mapView.addSubview(compassButton)
        
        view.addSubview(mapView)
        
        NSLayoutConstraint.activate([
            compassButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            compassButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
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
    
    func activateMapView() {
        let origin = OriginAnnotation(with: CLLocationCoordinate2D(latitude: self.package.origin.geoPoint.latitude, longitude: self.package.origin.geoPoint.longitude))
        let currentLocation = CurrentLocationAnnotation(with: self.package.currentLocation.coordinate)
        let recipient = RecipientAnnotation(with: CLLocationCoordinate2D(latitude: self.package.destination.geoPoint.latitude, longitude: self.package.destination.geoPoint.longitude))
        let annotations = [origin, currentLocation, recipient] as! [MKAnnotation]
        
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
        })
        
    }
    
    func activateMapTransitRecords() {
        package?.reference.collection("transit_records").getDocuments(completion: { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                print(error!)
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
        })
    }

    @objc private func didTapBackButton(sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension MapRouteViewController: MKMapViewDelegate {
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
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let userLocationView = mapView.view(for: userLocation)
        userLocationView?.canShowCallout = false
        userLocationView?.isEnabled = false
    }
}

