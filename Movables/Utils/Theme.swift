//
//  Theme.swift
//  Movables
//
//  Created by Eddie Chen on 5/21/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import Foundation
import UIKit

struct Theme {
    var keyTint: UIColor
    var keyTintHighlight: UIColor
    var keyTintHighlightDark: UIColor
    var routeTint: UIColor
    var mapStampTint: UIColor
    var mapStampTintHighlight: UIColor
    var grayTextColor: UIColor
    var grayTextColorHighlight: UIColor
    var disabledTextColor: UIColor
    var textColor: UIColor
    var borderColor: UIColor
    var affirmativeTint: UIColor
    var affirmativeTintHighlight: UIColor
    var staticTint: UIColor
    var backgroundShade: UIColor
    
    init() {
        self.keyTint = UIColor(red:0.13, green:0.58, blue:0.95, alpha:1.0)
        self.keyTintHighlight = UIColor(red:0.10, green:0.61, blue:1.00, alpha:1.0)
        self.keyTintHighlightDark = UIColor(red:0.28, green:0.47, blue:0.72, alpha:1.0)
            self.routeTint = UIColor(red: 0.55, green: 0.55, blue: 0.55, alpha: 1)
        self.mapStampTint = UIColor(red:1.00, green:0.24, blue:0.00, alpha:1.0)
        self.mapStampTintHighlight = UIColor(red:1.00, green:0.36, blue:0.00, alpha:1.0)
    
        self.textColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        self.grayTextColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        self.grayTextColorHighlight = UIColor(red:0.30, green:0.30, blue:0.30, alpha:1.0)
        self.disabledTextColor = self.grayTextColor.withAlphaComponent(0.5)
        self.borderColor = UIColor(red:0.94, green:0.94, blue:0.94, alpha:1.0)
        self.affirmativeTint = UIColor(red:0.00, green:0.78, blue:0.33, alpha:1.0)
        self.affirmativeTintHighlight = UIColor(red:0.00, green:0.78, blue:0.48, alpha:1.0)
        self.staticTint = UIColor(red:1.00, green:0.92, blue:0.23, alpha:1.0)
        self.backgroundShade = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1)
    }
}
