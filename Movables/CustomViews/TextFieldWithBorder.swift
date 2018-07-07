//
//  TextFieldWithBorder.swift
//  Movables
//
//  Created by Eddie Chen on 6/23/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit


enum TextFieldType {
    case email
    case password
    case username
}
class TextFieldWithBorder: UIView {

    fileprivate var borderView: UIView!
    var textField: UITextField!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, type: TextFieldType) {
        super.init(frame: frame)
        textField = UITextField(frame: .zero)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.autocapitalizationType = .none

        if type == .email {
            textField.keyboardType = .emailAddress
            textField.placeholder = "Email"
            textField.autocorrectionType = .no
        } else if type == .password {
            textField.keyboardType = .default
            textField.placeholder = "Password"
            textField.autocorrectionType = .no
            textField.isSecureTextEntry = true
        } else if type == .username {
            textField.placeholder = "Username"
            textField.autocorrectionType = .no
        }
        addSubview(textField)
        
        borderView = UIView(frame: .zero)
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.backgroundColor = Theme().borderColor
        addSubview(borderView)
        
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            textField.topAnchor.constraint(equalTo: self.topAnchor),
            textField.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            borderView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 4),
            borderView.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            borderView.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
            borderView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            borderView.heightAnchor.constraint(equalToConstant: 1),
        ])
        
    }
}
