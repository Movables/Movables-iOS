//
//  MCCircleWithLabel.swift
//  Movables
//
//  Created by Eddie Chen on 5/15/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit

class MCCircleWithLabel: UIView {

    var circleMask: UIView!
    var circleTextLabel: UILabel!
    var imageView: UIImageView!
    var labelContainer: UIView!
    var labelTextLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        circleMask = UIView(frame: .zero)
        circleMask.translatesAutoresizingMaskIntoConstraints = false
        circleMask.layer.borderWidth = 2
        circleMask.clipsToBounds = true
        circleMask.layer.borderColor = Theme().keyTint.cgColor
        circleMask.layer.cornerRadius = 28
        circleMask.clipsToBounds = true
        addSubview(circleMask)
        
        circleTextLabel = UILabel(frame: .zero)
        circleTextLabel.translatesAutoresizingMaskIntoConstraints = false
        circleTextLabel.textAlignment = .center
        circleTextLabel.textColor = Theme().keyTint
        circleMask.addSubview(circleTextLabel)

        imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        circleMask.addSubview(imageView)

        labelContainer = UIView(frame: .zero)
        labelContainer.translatesAutoresizingMaskIntoConstraints = false
        labelContainer.layer.cornerRadius = 4
        labelContainer.clipsToBounds = true
        labelContainer.backgroundColor = Theme().keyTint
        addSubview(labelContainer)

        labelTextLabel = UILabel(frame: .zero)
        labelTextLabel.translatesAutoresizingMaskIntoConstraints = false
        labelTextLabel.textColor = .white
        labelTextLabel.textAlignment = .center
        labelTextLabel.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        labelContainer.addSubview(labelTextLabel)
        
        NSLayoutConstraint.activate([
            circleMask.heightAnchor.constraint(equalToConstant: 56),
            circleMask.widthAnchor.constraint(equalToConstant: 56),
            circleMask.topAnchor.constraint(equalTo: self.topAnchor),
            circleMask.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            circleTextLabel.centerYAnchor.constraint(equalTo: circleMask.centerYAnchor, constant: -2),
            circleTextLabel.centerXAnchor.constraint(equalTo: circleMask.centerXAnchor),
            imageView.leadingAnchor.constraint(equalTo: circleMask.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: circleMask.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: circleMask.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: circleMask.bottomAnchor),
            labelContainer.topAnchor.constraint(equalTo: circleMask.bottomAnchor, constant: 4),
            labelContainer.centerXAnchor.constraint(equalTo: circleMask.centerXAnchor),
            labelTextLabel.leadingAnchor.constraint(equalTo: labelContainer.leadingAnchor, constant: 4),
            labelTextLabel.trailingAnchor.constraint(equalTo: labelContainer.trailingAnchor, constant: -4),
            labelTextLabel.topAnchor.constraint(equalTo: labelContainer.topAnchor, constant: 2),
            labelTextLabel.bottomAnchor.constraint(equalTo: labelContainer.bottomAnchor, constant: -2),
            labelContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])

    }
    
    convenience init(frame: CGRect, textInCircle: String?, labelText: String, labelTextSubscript:String?, image: UIImage?, color: UIColor, tilt: Tilt) {
        self.init(frame: frame)
        
        circleMask.layer.borderColor = color.cgColor
        circleMask.backgroundColor = image == nil ? .white : .clear

        if let textInCircle = textInCircle {
            let labelTextAttributed = NSMutableAttributedString(string: textInCircle, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 24).bold])
            if let labelTextSubscript = labelTextSubscript {
                labelTextAttributed.append(NSAttributedString(string: labelTextSubscript, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 11).bold]))
            }
            circleTextLabel.attributedText = labelTextAttributed
        }
        
        imageView.image = image
        
        labelContainer.backgroundColor = color
        labelContainer.transform = CGAffineTransform(rotationAngle: getRotateAngle(tilt: tilt))
        
        labelTextLabel.text = labelText
    }
    
    private func getRotateAngle(tilt: Tilt) -> CGFloat {
        switch tilt {
        case .right:
            return CGFloat(2.0 * (.pi/180))
        case .left:
            return CGFloat(-2.0 * (.pi/180))
        default:
            return 0
        }
    }
}
