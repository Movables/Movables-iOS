//
//  PickupAnnotation.swift
//  Movables
//
//  Created by Eddie Chen on 6/9/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit
import MapKit

class PickupAnnotation: NSObject, MKAnnotation {
    let title: String?
    let coordinate: CLLocationCoordinate2D
    let transitRecord: TransitRecord
    
    init(with transitRecord: TransitRecord) {
        self.transitRecord = transitRecord
        self.title = String(NSLocalizedString("annotation.pickup", comment: "title for pickup location annotation view"))
        self.coordinate = CLLocationCoordinate2D(latitude: transitRecord.pickupGeoPoint!.latitude, longitude: transitRecord.pickupGeoPoint!.longitude)
        
        super.init()
    }
}
