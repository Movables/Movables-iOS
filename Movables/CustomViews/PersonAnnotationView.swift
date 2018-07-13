//
//  CircleLabelAnnotationView.swift
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
        
        let circleLabel = MCCircleWithLabel(frame: .zero, textInCircle: nil, labelText: String(NSLocalizedString("annotation.pickup", comment: "title for pickup annotation view shown in activities tab")), labelTextSubscript: nil, image: UIImage(named: "ActivityType--packagePickup"), color: Theme().grayTextColor, tilt: .balanced)
        
        circleLabel.imageView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        circleLabel.imageView.tintColor = Theme().grayTextColor
        addSubview(circleLabel)
    }
    
}


