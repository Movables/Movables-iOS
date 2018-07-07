//
//  CircleLabelAnnotationView.swift
//  Movables
//
//  Created by Eddie Chen on 5/21/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit
import MapKit

class PersonAnnotationView: MKAnnotationView {

    var circleLabel: MCCircleWithLabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(annotation: ActivityDeliveryAnnotation, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        frame = .zero
        translatesAutoresizingMaskIntoConstraints = false
        centerOffset = CGPoint(x: 0, y: -54)
        
        canShowCallout = false
        
        let circleLabel = MCCircleWithLabel(frame: .zero, textInCircle: nil, labelText: annotation.person.displayName, labelTextSubscript: nil, image: UIImage(), color: Theme().keyTint, tilt: .balanced)
        
        circleLabel.imageView.sd_setImage(with: URL(string: annotation.person.photoUrl ?? "")!) { (image, error, cacheType, url) in
            print("set person")
        }
        
        addSubview(circleLabel)
        
    }

}


class DropoffActivityAnnotationView: MKAnnotationView {
    
    var circleLabel: MCCircleWithLabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(annotation: ActivityDropoffAnnotation, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        frame = .zero
        translatesAutoresizingMaskIntoConstraints = false
        centerOffset = CGPoint(x: 0, y: -54)
        
        canShowCallout = false
        
        let circleLabel = MCCircleWithLabel(frame: .zero, textInCircle: nil, labelText: "Dropoff", labelTextSubscript: nil, image: UIImage(named: "ActivityType--packageDropoff"), color: Theme().grayTextColor, tilt: .balanced)
        
        circleLabel.imageView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        circleLabel.imageView.tintColor = Theme().grayTextColor
        addSubview(circleLabel)
        
        NSLayoutConstraint.activate([
            circleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            circleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            circleLabel.topAnchor.constraint(equalTo: self.topAnchor),
            circleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
    
}

class PickupActivityAnnotationView: MKAnnotationView {
    
    var circleLabel: MCCircleWithLabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(annotation: ActivityPickupAnnotation, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        frame = .zero
        translatesAutoresizingMaskIntoConstraints = false
        centerOffset = CGPoint(x: 0, y: -54)
        canShowCallout = false
        
        let circleLabel = MCCircleWithLabel(frame: .zero, textInCircle: nil, labelText: "Pickup", labelTextSubscript: nil, image: UIImage(named: "ActivityType--packagePickup"), color: Theme().grayTextColor, tilt: .balanced)
        
        circleLabel.imageView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        circleLabel.imageView.tintColor = Theme().grayTextColor
        addSubview(circleLabel)
    }
    
}


