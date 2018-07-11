//
//  OriginAnnotation.swift
//  Movables
//
//  Created by Eddie Chen on 5/21/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit
import MapKit

class OriginAnnotation: NSObject, MKAnnotation {
    let title: String?
    let coordinate: CLLocationCoordinate2D
    
    init(with coordinate: CLLocationCoordinate2D) {
        self.title = String(NSLocalizedString("annotation.origin", comment: "label text for origin annotation view"))
        self.coordinate = coordinate
        
        super.init()
    }    
}
