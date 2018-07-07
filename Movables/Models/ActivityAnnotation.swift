//
//  ActivityAnnotation.swift
//  Movables
//
//  Created by Chun-Wei Chen on 6/29/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import Foundation
import MapKit

enum AnnotationStyle {
    case marker
    case pin
    case person
}

class ActivityDeliveryAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var person: Person
    
    

    init(with title: String, subtitle: String?, coordinate: CLLocationCoordinate2D, person: Person) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.person = person
    }
}


class ActivityPickupAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?

    init(with title: String, subtitle: String?, coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}

class ActivityDropoffAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(with title: String, subtitle: String?, coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}
