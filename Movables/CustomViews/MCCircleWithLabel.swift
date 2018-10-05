//
//  MCCircleWithLabel.swift
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
            let labelTextAttributed = NSMutableAttributedString(string: textInCircle, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24).bold])
            if let labelTextSubscript = labelTextSubscript {
                labelTextAttributed.append(NSAttributedString(string: labelTextSubscript, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 11).bold]))
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
