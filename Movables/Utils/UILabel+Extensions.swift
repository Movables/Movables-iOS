//
//  UILabel+Extensions.swift
//  Movables
//
//  Created by Eddie Chen on 5/21/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    
    func calculateMaxLines(width: CGFloat) -> Int {
        let maxSize = CGSize(width: width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        let lines = Int(textSize.height/charSize)
        return lines
    }
    
}

