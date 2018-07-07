//
//  VisualEffectsFabButton.swift
//  Movables
//
//  Created by Eddie Chen on 5/31/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit

class VisualEffectsFabButton: UIButton {

    var baseView: UIView!
    var visualEffectsView: UIVisualEffectView!
    var button: UIButton!
    var dimension: CGFloat!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, dimension: CGFloat) {
        super.init(frame: frame)
        self.dimension = dimension
        
        baseView = UIView(frame: .zero)
        baseView.translatesAutoresizingMaskIntoConstraints = false
        baseView.layer.shadowColor = UIColor.black.cgColor
        baseView.layer.shadowOffset = CGSize(width: 0, height: 0)
        baseView.layer.shadowOpacity = 0.15
        baseView.layer.shadowRadius = 8
        addSubview(baseView)
        
        let hBaseView = NSLayoutConstraint.constraints(withVisualFormat: "H:|[baseView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["baseView": baseView])
        let vBaseView = NSLayoutConstraint.constraints(withVisualFormat: "V:|[baseView]|", options: [.alignAllLeading, .alignAllTrailing], metrics: nil, views: ["baseView": baseView])
        addConstraints(hBaseView + vBaseView)
        
        visualEffectsView = UIVisualEffectView(effect: nil)
        visualEffectsView.frame = .zero
        visualEffectsView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectsView.layer.cornerRadius = dimension / 2
        visualEffectsView.clipsToBounds = true
        visualEffectsView.backgroundColor = Theme().keyTint
        baseView.addSubview(visualEffectsView)
        
        let hVisualEffectsView = NSLayoutConstraint.constraints(withVisualFormat: "H:|[visualEffectsView]|", options: .directionLeadingToTrailing, metrics: nil, views: ["visualEffectsView": visualEffectsView])
        let vVisualEffectsView = NSLayoutConstraint.constraints(withVisualFormat: "V:|[visualEffectsView]|", options: [.alignAllLeading, .alignAllTrailing], metrics: nil, views: ["visualEffectsView": visualEffectsView])
        baseView.addConstraints(hVisualEffectsView + vVisualEffectsView)
        
        button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = dimension / 2
        button.clipsToBounds = true
        button.tintColor = .white
        visualEffectsView.contentView.addSubview(button)
        
        let hButton = NSLayoutConstraint.constraints(withVisualFormat: "H:|[button(dimension)]|", options: .directionLeadingToTrailing, metrics: ["dimension": dimension], views: ["button": button])
        let vButton = NSLayoutConstraint.constraints(withVisualFormat: "V:|[button(dimension)]|", options: [.alignAllLeading, .alignAllTrailing], metrics: ["dimension": dimension], views: ["button": button])
        visualEffectsView.contentView.addConstraints(hButton + vButton)
    }

}
