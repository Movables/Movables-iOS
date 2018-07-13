//
//  DropoffAnnotation.swift
//  Movables
//
//  Created by Eddie Chen on 6/9/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit
import MapKit

class DropoffAnnotation: NSObject, MKAnnotation {
    let title: String?
    let coordinate: CLLocationCoordinate2D
    let transitRecord: TransitRecord
    
    init(with transitRecord: TransitRecord) {
        self.transitRecord = transitRecord
        self.title = String(NSLocalizedString("annotation.dropoff", comment: "title for dropoff location annotation view"))
        self.coordinate = CLLocationCoordinate2D(latitude: transitRecord.dropoffGeoPoint!.latitude, longitude: transitRecord.dropoffGeoPoint!.longitude)
        super.init()
    }

}
 
