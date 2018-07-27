//
//  ActivityTableViewCell.swift
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
import TTTAttributedLabel
import MapKit
import Firebase
import CoreLocation

class ActivityTableViewCell: UITableViewCell {

    var cardView: UIView!
    var userEventView: UserEventView!
    var imageMapView: UIImageView!
    var annotationView: MCCircleWithLabel!
    var firstRow: ActivityRowView!
    var secondRow: ActivityRowView!
    var thirdRow: ActivityRowView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = .clear
        
        setupCardView()
        setupUserEventView()
        setupImageMapView()
        setupAnnotationView()
        setupActivityRows()
    }
    
    private func setupCardView() {
        cardView = UIView(frame: .zero)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.clipsToBounds = true
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 8
//        cardView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        cardView.layer.borderColor = Theme().textColor.withAlphaComponent(0.1).cgColor
        cardView.layer.borderWidth = 1
        contentView.addSubview(cardView)
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-9-[cardView]-9-|", options: .directionLeadingToTrailing, metrics: nil, views: ["cardView": cardView]) + NSLayoutConstraint.constraints(withVisualFormat: "V:|-4-[cardView]-10-|", options: .alignAllLeading, metrics: nil, views: ["cardView": cardView]))
        let bottomConstraint = NSLayoutConstraint(item: cardView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: -18)
        bottomConstraint.priority = .defaultHigh
        contentView.addConstraint(bottomConstraint)
    }
    
    private func setupUserEventView() {
        userEventView = UserEventView(frame: .zero)
        userEventView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(userEventView)
        
        NSLayoutConstraint.activate([
            userEventView.topAnchor.constraint(equalTo: cardView.topAnchor),
            userEventView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            userEventView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
        ])
    }
    
    private func setupImageMapView() {
        imageMapView = UIImageView(frame: .zero)
        imageMapView.translatesAutoresizingMaskIntoConstraints = false
        imageMapView.contentMode = .scaleAspectFill
        imageMapView.backgroundColor = Theme().borderColor
        cardView.addSubview(imageMapView)
        
        NSLayoutConstraint.activate([
            imageMapView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            imageMapView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            imageMapView.topAnchor.constraint(equalTo: userEventView.bottomAnchor),
            imageMapView.heightAnchor.constraint(equalToConstant: 200),
        ])
    }
    
    private func setupAnnotationView() {
        annotationView = MCCircleWithLabel(frame: .zero)
        annotationView.translatesAutoresizingMaskIntoConstraints = false
        imageMapView.addSubview(annotationView)
        
        NSLayoutConstraint.activate([
            annotationView.centerXAnchor.constraint(equalTo: imageMapView.centerXAnchor),
            annotationView.centerYAnchor.constraint(equalTo: imageMapView.centerYAnchor),
            ])
    }
    
    private func setupActivityRows() {
        firstRow = ActivityRowView(frame: .zero)
        firstRow.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(firstRow)
        secondRow = ActivityRowView(frame: .zero)
        secondRow.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(secondRow)
        thirdRow = ActivityRowView(frame: .zero)
        thirdRow.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(thirdRow)
        
        NSLayoutConstraint.activate([
            firstRow.topAnchor.constraint(equalTo: imageMapView.bottomAnchor, constant: 20),
            firstRow.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            firstRow.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            secondRow.topAnchor.constraint(equalTo: firstRow.bottomAnchor, constant: 18),
            secondRow.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            secondRow.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            thirdRow.topAnchor.constraint(equalTo: secondRow.bottomAnchor, constant: 18),
            thirdRow.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            thirdRow.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            thirdRow.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -18),
        ])
    }
    
}

func coordinate(from geoPoint: GeoPoint) -> CLLocationCoordinate2D {
    return CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
}

func string(from geoPoint: GeoPoint) -> String {
    return "\(geoPoint.latitude), \(geoPoint.longitude)"
}
