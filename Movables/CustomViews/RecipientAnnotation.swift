//
//  RecipientAnnotation.swift
//  Movables
//
//  Created by Eddie Chen on 5/21/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit
import MapKit

class RecipientAnnotation: NSObject, MKAnnotation {
    let title: String?
    let coordinate: CLLocationCoordinate2D
    
    init(with coordinate: CLLocationCoordinate2D) {
        self.title = String(NSLocalizedString("label.destination", comment: "label text for recipient annotation view"))
        self.coordinate = coordinate
        
        super.init()
    }
    
}
