//
//  PackageAnnotation.swift
//  Movables
//
//  Created by Eddie Chen on 5/14/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit
import MapKit

class PackageAnnotation: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    let packagePreview: PackagePreview?
    let packageFollowing: PackageFollowing?
    
    init(with packagePreview: PackagePreview) {
        self.packagePreview = packagePreview
        self.title = getReadableForStatusEnum(statusEnum: packagePreview.packageStatus)
        self.subtitle = nil
        self.coordinate = packagePreview.coordinate
        self.packageFollowing = nil
    }
    
    init(with packageFollowing: PackageFollowing) {
        self.packageFollowing = packageFollowing
        self.title = getReadableForStatusEnum(statusEnum: packageFollowing.packageStatus)
        self.subtitle = nil
        self.coordinate = packageFollowing.coordinate
        self.packagePreview = nil
    }
    
    init(with title: String?, coordinate: CLLocationCoordinate2D, packagePreview: PackagePreview?) {
        self.title = title
        self.subtitle = nil
        self.coordinate = coordinate
        self.packagePreview = packagePreview
        self.packageFollowing = nil
    }
    
}
