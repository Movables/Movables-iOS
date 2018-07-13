//
//  ExternalActionEditorView.swift
//  Movables
//
//  Created by Eddie Chen on 6/25/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit
import UITextView_Placeholder

class ExternalActionEditorView: UIView {

    var containerView: UIView!
    var actionTypeButton: UIButton!
    var phantomActionTypeTextField: UITextField!
    var actionTypePicker: UIPickerView!
    var descriptionTextView: UITextViewFixed!
    var linkTextField: UITextField!
    var removeActionButton: UIButton!
    var index: Int!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, index: Int) {
        super.init(frame: frame)
        
        containerView = UIView(frame: .zero)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 8
        containerView.clipsToBounds = true
        addSubview(containerView)
        
        descriptionTextView = UITextViewFixed(frame: .zero)
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.isScrollEnabled = false
        descriptionTextView.placeholder = String(NSLocalizedString("label.description", comment: "label text for description"))
        descriptionTextView.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        descriptionTextView.textContainerInset = .zero
        containerView.addSubview(descriptionTextView)
        
        linkTextField = UITextField(frame: .zero)
        linkTextField.translatesAutoresizingMaskIntoConstraints = false
        linkTextField.placeholder = String(NSLocalizedString("label.linkUrl", comment: "label text for link url"))
        linkTextField.autocapitalizationType = .none
        linkTextField.returnKeyType = .done
        containerView.addSubview(linkTextField)
        
        actionTypeButton = UIButton(frame: .zero)
        actionTypeButton.translatesAutoresizingMaskIntoConstraints = false
        actionTypeButton.setTitle(String(NSLocalizedString("button.selectActionType", comment: "button title for select action type")), for: .normal)
        actionTypeButton.setTitleColor(Theme().keyTint, for: .normal)
        actionTypeButton.setTitleColor(Theme().keyTintHighlightDark, for: .highlighted)
        containerView.addSubview(actionTypeButton)

        phantomActionTypeTextField = UITextField()        
        self.addSubview(phantomActionTypeTextField)

        
        
        removeActionButton = UIButton(frame: .zero)
        removeActionButton.translatesAutoresizingMaskIntoConstraints = false
        removeActionButton.setTitle(String(NSLocalizedString("button.remove", comment: "button title for remove")), for: .normal)
        removeActionButton.setTitleColor(Theme().keyTint, for: .normal)
        removeActionButton.setTitleColor(Theme().keyTintHighlightDark, for: .highlighted)
        containerView.addSubview(removeActionButton)
        
        self.index = index
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: self.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            actionTypeButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 18),
            actionTypeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 18),
            actionTypeButton.heightAnchor.constraint(equalToConstant: 40),
            removeActionButton.heightAnchor.constraint(equalToConstant: 40),
            removeActionButton.topAnchor.constraint(equalTo: actionTypeButton.topAnchor),
            removeActionButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -18),
            descriptionTextView.leadingAnchor.constraint(equalTo: actionTypeButton.leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: removeActionButton.trailingAnchor),
            descriptionTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),
            descriptionTextView.topAnchor.constraint(equalTo: actionTypeButton.bottomAnchor, constant: 18),
            linkTextField.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 20),
            linkTextField.leadingAnchor.constraint(equalTo: descriptionTextView.leadingAnchor),
            linkTextField.trailingAnchor.constraint(equalTo: descriptionTextView.trailingAnchor),
            linkTextField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -30),
        ])
    }
}

@IBDesignable class UITextViewFixed: UITextView {
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    func setup() {
        textContainerInset = UIEdgeInsets.zero
        textContainer.lineFragmentPadding = 0
    }
}

