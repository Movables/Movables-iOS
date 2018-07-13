//
//  TextFieldWithBorder.swift
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
