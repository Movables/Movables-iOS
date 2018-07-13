//
//  CreatePackageContentViewController.swift
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
import UITextView_Placeholder
import CropViewController

class CreatePackageContentViewController: UIViewController {

    let CONTENT_INSET_TOP: CGFloat = UIApplication.shared.keyWindow!.safeAreaInsets.top + 20
    let CONTENT_INSET_BOTTOM: CGFloat = UIApplication.shared.keyWindow!.safeAreaInsets.bottom + 30 + (UIDevice.isIphoneX ? 10 : 28)
    
    var createPackageCoordinator: CreatePackageCoordinator!
    
    var externalActions: [ExternalAction] = []
    
    var scrollView: UIScrollView!
    var instructionLabel: MCPill!
    var contentStackView: UIStackView!
    var headlineTextView: UITextView!
    var descriptionTextView: UITextView!
    var messageTextView: UITextView!
    var externalActionsStackView: UIStackView!
    var addCoverPhotoButton: UIButton!
    var setDueDateButton: UIButton!
    var phantomDueDateTextField: UITextField!
    var dueDateDatePicker: UIDatePicker!
    
    var backButtonBaseView: UIView!
    var backButton: UIButton!
    var nextButtonBaseView: UIView!
    var nextButton: UIButton!
    
    var picker: UIImagePickerController = UIImagePickerController()
    var cropVC: CropViewController?
    var coverPhotoImageView: UIImageView?
    
    var editingPhantomTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Headline
        // Description
        // Cover Photo
        
        setupScrollView()
        populateStackView()
        setupFAB()
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        picker.delegate = self
    }
    
    private func setupScrollView() {
        scrollView = UIScrollView(frame: .zero)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = Theme().backgroundShade
        scrollView.contentInset.top = CONTENT_INSET_TOP
        scrollView.contentInset.bottom = CONTENT_INSET_BOTTOM
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        
        contentStackView = UIStackView()
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.alignment = .center
        contentStackView.spacing = 18
        scrollView.addSubview(contentStackView)
        
        instructionLabel = MCPill(frame: .zero, character: "\(self.navigationController!.childViewControllers.count)", image: nil, body: String(NSLocalizedString("label.packageContents", comment: "label text for package contents")), color: .white)
        instructionLabel.bodyLabel.textColor = Theme().textColor
        instructionLabel.circleMask.backgroundColor = Theme().textColor
        instructionLabel.characterLabel.textColor = .white
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(instructionLabel)
        
        NSLayoutConstraint.activate([
            instructionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            instructionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6),
            scrollView.heightAnchor.constraint(equalTo: view.heightAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 18),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -18),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
        ])
        
        phantomDueDateTextField = UITextField(frame: .zero)
        
        dueDateDatePicker = UIDatePicker()
        dueDateDatePicker.datePickerMode = .dateAndTime
        dueDateDatePicker.minimumDate = Date().add(2.hours)
        dueDateDatePicker.maximumDate = Date().add(1.years)
        phantomDueDateTextField.inputView = dueDateDatePicker
        let toolbar = UIToolbar()
        toolbar.tintColor = Theme().textColor
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: String(NSLocalizedString("button.done", comment: "button title for done")), style: .done, target: self, action: #selector(didTapDoneDatePicker(sender:)))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: String(NSLocalizedString("button.cancel", comment: "button title for cancel")), style: .plain, target: self, action: #selector(didTapCancelDatePicker(sender:)))

        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        phantomDueDateTextField.inputAccessoryView = toolbar
        view.addSubview(phantomDueDateTextField)
    }
    
    private func populateStackView() {
        addCoverPhotoButton = UIButton(frame: .zero)
        addCoverPhotoButton.translatesAutoresizingMaskIntoConstraints = false
        addCoverPhotoButton.layer.cornerRadius = 8
        addCoverPhotoButton.clipsToBounds = true
        addCoverPhotoButton.layer.borderWidth = 1
        addCoverPhotoButton.layer.borderColor = Theme().borderColor.cgColor
        addCoverPhotoButton.setTitle(String(NSLocalizedString("button.addCoverPhoto", comment: "button title for add cover photo")), for: .normal)
        addCoverPhotoButton.setBackgroundColor(color: .white, forUIControlState: .normal)
        addCoverPhotoButton.setBackgroundColor(color: Theme().borderColor, forUIControlState: .highlighted)
        addCoverPhotoButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        addCoverPhotoButton.setTitleColor(Theme().textColor, for: .normal)
        addCoverPhotoButton.addTarget(self, action: #selector(didTapAddCoverPhotoButton(sender:)), for: .touchUpInside)
        contentStackView.addArrangedSubview(addCoverPhotoButton)
        
        setDueDateButton = UIButton(frame: .zero)
        setDueDateButton.translatesAutoresizingMaskIntoConstraints = false
        setDueDateButton.layer.cornerRadius = 8
        setDueDateButton.clipsToBounds = true
        setDueDateButton.layer.borderWidth = 1
        setDueDateButton.layer.borderColor = Theme().borderColor.cgColor
        setDueDateButton.setTitle(String(NSLocalizedString("button.setDueDate", comment: "button title for set due date")), for: .normal)
        setDueDateButton.setBackgroundColor(color: .white, forUIControlState: .normal)
        setDueDateButton.setBackgroundColor(color: Theme().borderColor, forUIControlState: .highlighted)
        setDueDateButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        setDueDateButton.setTitleColor(Theme().textColor, for: .normal)
        setDueDateButton.addTarget(self, action: #selector(didTapSetDueDateButton(sender:)), for: .touchUpInside)
        contentStackView.addArrangedSubview(setDueDateButton)
        
        headlineTextView = UITextView(frame: .zero)
        headlineTextView.translatesAutoresizingMaskIntoConstraints = false
        headlineTextView.delegate = self
        headlineTextView.placeholder = String(NSLocalizedString("label.headline", comment: "label text for headline"))
        headlineTextView.layer.cornerRadius = 8
        headlineTextView.autocapitalizationType = .words
        headlineTextView.clipsToBounds = true
        headlineTextView.layer.borderWidth = 1
        headlineTextView.layer.borderColor = Theme().borderColor.cgColor
        headlineTextView.isScrollEnabled = false
        headlineTextView.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        headlineTextView.textContainerInset = UIEdgeInsets(top: 18, left: 8, bottom: 18, right: 8)
        contentStackView.addArrangedSubview(headlineTextView)
        
        descriptionTextView = UITextView(frame: .zero)
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.delegate = self
        descriptionTextView.placeholder = String(NSLocalizedString("label.description", comment: "label text for description"))
        descriptionTextView.layer.cornerRadius = 8
        descriptionTextView.clipsToBounds = true
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = Theme().borderColor.cgColor
        descriptionTextView.isScrollEnabled = false
        descriptionTextView.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        descriptionTextView.textContainerInset = UIEdgeInsets(top: 18, left: 8, bottom: 18, right: 8)
        contentStackView.addArrangedSubview(descriptionTextView)
        
        messageTextView = UITextView(frame: .zero)
        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        messageTextView.delegate = self
        messageTextView.placeholder = String(NSLocalizedString("label.message", comment: "label text for message"))
        messageTextView.layer.cornerRadius = 8
        messageTextView.clipsToBounds = true
        messageTextView.layer.borderWidth = 1
        messageTextView.layer.borderColor = Theme().borderColor.cgColor
        messageTextView.isScrollEnabled = false
        messageTextView.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        messageTextView.textContainerInset = UIEdgeInsets(top: 18, left: 8, bottom: 18, right: 8)
        contentStackView.addArrangedSubview(messageTextView)
        
        let addExternalActionButton = UIButton(frame: .zero)
        addExternalActionButton.translatesAutoresizingMaskIntoConstraints = false
        addExternalActionButton.layer.cornerRadius = 8
        addExternalActionButton.clipsToBounds = true
        addExternalActionButton.layer.borderWidth = 1
        addExternalActionButton.layer.borderColor = Theme().borderColor.cgColor
        addExternalActionButton.setTitle(String(NSLocalizedString("button.addDropoffAction", comment: "button title for add dropoff action")), for: .normal)
        addExternalActionButton.setBackgroundColor(color: .white, forUIControlState: .normal)
        addExternalActionButton.setBackgroundColor(color: Theme().borderColor, forUIControlState: .highlighted)
        addExternalActionButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        addExternalActionButton.setTitleColor(Theme().textColor, for: .normal)
        addExternalActionButton.addTarget(self, action: #selector(didTapAddExternalActionButton(sender:)), for: .touchUpInside)
        
        externalActionsStackView = UIStackView(frame: .zero)
        externalActionsStackView.addArrangedSubview(addExternalActionButton)
        externalActionsStackView.translatesAutoresizingMaskIntoConstraints = false
        externalActionsStackView.axis = .vertical
        externalActionsStackView.spacing = 18
        contentStackView.addArrangedSubview(externalActionsStackView)
        
        NSLayoutConstraint.activate([
            headlineTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 64),
            headlineTextView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -36),
            descriptionTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 200),
            descriptionTextView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -36),
            messageTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 200),
            messageTextView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -36),
            addExternalActionButton.heightAnchor.constraint(equalToConstant: 50),
            addExternalActionButton.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -36),
            addCoverPhotoButton.heightAnchor.constraint(equalToConstant: 50),
            addCoverPhotoButton.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -36),
            setDueDateButton.heightAnchor.constraint(equalToConstant: 50),
            setDueDateButton.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -36),
        ])
    }
    
    @objc private func didTapAddExternalActionButton(sender: UIButton) {
        print("did tap add external action button")
        // add external action to model
        self.externalActions.append(ExternalAction())
        // add action editor ui item to stackviewcon
        let newExternalActionEditorView = ExternalActionEditorView(frame: .zero, index: self.externalActions.count)
        newExternalActionEditorView.removeActionButton.addTarget(self, action: #selector(didTapRemoveExternalActionButton(sender:)), for: .touchUpInside)
        newExternalActionEditorView.removeActionButton.setTitleColor(getTintForCategory(category: createPackageCoordinator.category!), for: .normal)
        newExternalActionEditorView.removeActionButton.setTitleColor(getTintForCategory(category: createPackageCoordinator.category!).withAlphaComponent(0.85), for: .highlighted)
        newExternalActionEditorView.actionTypeButton.addTarget(self, action: #selector(didTapSelectActionTypeButton(sender:)), for: .touchUpInside)
        newExternalActionEditorView.actionTypeButton.setTitleColor(getTintForCategory(category: createPackageCoordinator.category!), for: .normal)
 newExternalActionEditorView.actionTypeButton.setTitleColor(getTintForCategory(category: createPackageCoordinator.category!).withAlphaComponent(0.85), for: .highlighted)
       
        let actionTypePicker = UIPickerView()
        newExternalActionEditorView.phantomActionTypeTextField.inputView = actionTypePicker
        newExternalActionEditorView.phantomActionTypeTextField.delegate = self
        newExternalActionEditorView.phantomActionTypeTextField.keyboardDistanceFromTextField = 64
        let toolbar = UIToolbar()
        toolbar.tintColor = Theme().textColor
        toolbar.sizeToFit()
        actionTypePicker.dataSource = self
        actionTypePicker.delegate = self
    
        let doneButton = UIBarButtonItem(title: String(NSLocalizedString("button.done", comment: "button title for done")), style: .done, target: self, action: #selector(didTapDoneActionTypePicker(sender:)))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//            let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(didTapCancelActionTypePicker(sender:)))
    
        toolbar.setItems([spaceButton, doneButton], animated: false)
        newExternalActionEditorView.phantomActionTypeTextField.inputAccessoryView = toolbar

        self.externalActionsStackView.insertArrangedSubview(newExternalActionEditorView, at: self.externalActionsStackView.arrangedSubviews.count - 1)
        
        NSLayoutConstraint.activate([
            newExternalActionEditorView.heightAnchor.constraint(greaterThanOrEqualToConstant: 200),
            newExternalActionEditorView.widthAnchor.constraint(equalTo: externalActionsStackView.widthAnchor),
            ])

    }
    
    @objc private func didTapRemoveExternalActionButton(sender: UIButton) {
        let editorView = sender.superview?.superview as! ExternalActionEditorView
        print("remove view indexed :\(editorView.index)")
        self.externalActions.remove(at: editorView.index - 1)
        print("external actions: \(self.externalActions)")
        self.externalActionsStackView.removeArrangedSubview(editorView)
        editorView.removeFromSuperview()
    }
    
    @objc private func didTapSelectActionTypeButton(sender: UIButton) {
        let editorView = sender.superview?.superview as! ExternalActionEditorView
        print("set action type for :\(editorView.index)")
        let externalAction = self.externalActions[editorView.index - 1]
        
       (editorView.phantomActionTypeTextField.inputView as! UIPickerView).selectRow(externalActionsEnumArray.index(of: externalAction.type ?? .act)!, inComponent: 0, animated: false)
        editorView.phantomActionTypeTextField.becomeFirstResponder()
//        editorView.actionTypeButton.setTitle("Set", for: .normal)
    }
    
    @objc private func didTapDoneActionTypePicker(sender: UIBarButtonItem) {
        print("did tap done action type picker")
        let editorView = (self.editingPhantomTextField?.superview as! ExternalActionEditorView)
        let pickerView = self.editingPhantomTextField?.inputView as! UIPickerView
        let selectedType = externalActionsEnumArray[pickerView.selectedRow(inComponent: 0)]
        self.externalActions[editorView.index - 1].type = selectedType
    editorView.actionTypeButton.setTitle(getStringForExternalAction(type: selectedType), for: .normal)

        self.editingPhantomTextField?.resignFirstResponder()
    }
    
    @objc private func didTapAddCoverPhotoButton(sender: UIButton) {
        print("did tap add cover photo button")
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: String(NSLocalizedString("button.camera", comment: "button title for camera")), style: .default, handler: { (action) in
            print("Camera")
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.picker.allowsEditing = false
                self.picker.sourceType = UIImagePickerControllerSourceType.camera
                self.picker.cameraCaptureMode = .photo
                self.picker.modalPresentationStyle = .overCurrentContext
                self.present(self.picker,animated: true,completion: nil)
            } else {
                let alertVC = UIAlertController(
                    title: "No Camera",
                    message: "Sorry, this device has no camera",
                    preferredStyle: .alert)
                let okAction = UIAlertAction(
                    title: "OK",
                    style:.default,
                    handler: nil)
                alertVC.addAction(okAction)
                self.present(
                    alertVC,
                    animated: true,
                    completion: nil)
            }
        }))
        alertController.addAction(UIAlertAction(title: String(NSLocalizedString("button.photoLibrary", comment: "button title for photo library")), style: .default, handler: { (action) in
            print("Photo Library")
            self.picker.allowsEditing = false
            self.picker.sourceType = .photoLibrary
            self.picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
            self.picker.modalPresentationStyle = .overCurrentContext
            self.present(self.picker, animated: true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: String(NSLocalizedString("button.cancel", comment: "button title for cancel")), style: .cancel, handler: { (action) in
            print("Cancel")
        }))
        present(alertController, animated: true) {
            print("presented alert controller")
        }
    }
    
    @objc private func didTapDoneDatePicker(sender: UIBarButtonItem) {
        print("done tapped with date \(dueDateDatePicker.date)")
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        let setDueDateButtonString = String(format: NSLocalizedString("button.dueDate", comment: "button title for due date"), dateFormatter.string(from: dueDateDatePicker.date))
        setDueDateButton.setTitle(setDueDateButtonString, for: .normal)
        nextButton.isEnabled = nextButtonEnabled()
        phantomDueDateTextField.resignFirstResponder()
    }
    
    @objc private func didTapCancelDatePicker(sender: UIBarButtonItem) {
        print("cancel tapped with date \(dueDateDatePicker.date)")
        nextButton.isEnabled = nextButtonEnabled()
        phantomDueDateTextField.resignFirstResponder()
    }
    
    @objc private func didTapSetDueDateButton(sender: UIButton) {
        print("did tap set due date button")
        phantomDueDateTextField.becomeFirstResponder()
    }
    
    private func setupFAB() {
        backButtonBaseView = UIView(frame: .zero)
        backButtonBaseView.translatesAutoresizingMaskIntoConstraints = false
        backButtonBaseView.layer.shadowColor = UIColor.black.cgColor
        backButtonBaseView.layer.shadowOpacity = 0.3
        backButtonBaseView.layer.shadowRadius = 14
        backButtonBaseView.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.addSubview(backButtonBaseView)
        
        backButton = UIButton(frame: .zero)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(named: "round_back_black_50pt"), for: .normal)
        backButton.tintColor = .white
        backButton.setBackgroundColor(color: Theme().grayTextColor, forUIControlState: .normal)
        backButton.setBackgroundColor(color: Theme().grayTextColorHighlight, forUIControlState: .highlighted)
        backButton.contentEdgeInsets = .zero
        backButton.layer.cornerRadius = 25
        backButton.clipsToBounds = true
        backButton.addTarget(self, action: #selector(didTapBackButton(sender:)), for: .touchUpInside)
        backButton.isEnabled = true
        backButtonBaseView.addSubview(backButton)
        
        let backHConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[backButton(50)]|", options: .directionLeadingToTrailing, metrics: nil, views: ["backButton": backButton])
        backButtonBaseView.addConstraints(backHConstraints)
        let backVConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[backButton(50)]|", options: .alignAllTrailing, metrics: nil, views: ["backButton": backButton])
        backButtonBaseView.addConstraints(backVConstraints)
        
        nextButtonBaseView = UIView(frame: .zero)
        nextButtonBaseView.translatesAutoresizingMaskIntoConstraints = false
        nextButtonBaseView.layer.shadowColor = UIColor.black.cgColor
        nextButtonBaseView.layer.shadowOpacity = 0.3
        nextButtonBaseView.layer.shadowRadius = 14
        nextButtonBaseView.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.addSubview(nextButtonBaseView)

        nextButton = UIButton(frame: .zero)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.setImage(UIImage(named: "round_next_black_50pt"), for: .normal)
        nextButton.tintColor = Theme().disabledTextColor
        nextButton.setBackgroundColor(color: Theme().grayTextColor, forUIControlState: .normal)
        nextButton.setBackgroundColor(color: Theme().borderColor, forUIControlState: .disabled)
        nextButton.setBackgroundColor(color: Theme().grayTextColorHighlight, forUIControlState: .highlighted)
        nextButton.contentEdgeInsets = .zero
        nextButton.layer.cornerRadius = 25
        nextButton.clipsToBounds = true
        nextButton.addTarget(self, action: #selector(didTapNextButton(sender:)), for: .touchUpInside)
        nextButton.isEnabled = false
        nextButtonBaseView.addSubview(nextButton)

        let nextHConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[nextButton(50)]|", options: .directionLeadingToTrailing, metrics: nil, views: ["nextButton": nextButton])
        nextButtonBaseView.addConstraints(nextHConstraints)
        let nextVConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[nextButton(50)]|", options: .alignAllTrailing, metrics: nil, views: ["nextButton": nextButton])
        nextButtonBaseView.addConstraints(nextVConstraints)
        
        NSLayoutConstraint.activate([
            backButtonBaseView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 18),
            backButtonBaseView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -(UIDevice.isIphoneX ? 0 : 18)),
            nextButtonBaseView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -18),
            nextButtonBaseView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -(UIDevice.isIphoneX ? 0 : 18)),
        ])
    }



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @objc private func didTapBackButton(sender: UIButton) {
        createPackageCoordinator.unwind()
        print("backed")
    }
    
    private func nextButtonEnabled() -> Bool {
        let enabled = coverPhotoImageView?.image != nil &&
            !headlineTextView.text.isEmpty &&
            !descriptionTextView.text.isEmpty
        self.nextButton.tintColor = enabled ? .white : Theme().disabledTextColor
        return enabled
    }
    
    @objc private func didTapNextButton(sender: UIButton) {
        sender.isEnabled = false
        for view in self.externalActionsStackView.arrangedSubviews {
            if !view.isMember(of: UIButton.self) {
                let editorView = view as! ExternalActionEditorView
                self.externalActions[editorView.index - 1].description = editorView.descriptionTextView.text
                self.externalActions[editorView.index - 1].webLink = editorView.linkTextField.text
            }
        }
        print("actions for review: \(self.externalActions)")
        if externalActionsComplete() {
            prepareContentForReview(withExternalActions: true)
        } else {
            let alertController = UIAlertController(title: String(NSLocalizedString("label.incompleteDropoffActions", comment: "title text for incomplete dropoff actions")), message: String(NSLocalizedString("label.incompleteDropoffActionsDesc", comment: "alert body label for incomplete dropoff actions")), preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: String(NSLocalizedString("button.review", comment: "button title for review")), style: .default, handler: { (action) in
                print("review")
                sender.isEnabled = true
            }))
            alertController.addAction(UIAlertAction(title: String(NSLocalizedString("button.skip", comment: "button title for skip")), style: .default, handler: { (action) in
                print("skip")
                self.prepareContentForReview(withExternalActions: false)
            }))
            self.present(alertController, animated: true) {
                print("presented alert")
            }
        }
    }
    
    private func prepareContentForReview(withExternalActions: Bool) {
        createPackageCoordinator.packageCoverPhotoImage = coverPhotoImageView?.image
        createPackageCoordinator.packageDueDate = dueDateDatePicker.date
        createPackageCoordinator.packageHeadline = headlineTextView.text
        createPackageCoordinator.packageDescription = descriptionTextView.text
        if withExternalActions && externalActionsComplete() {
            createPackageCoordinator.externalActions = self.externalActions
            createPackageCoordinator.dropoffMessage = self.messageTextView.text
        }
        createPackageCoordinator.setContentAndPushToReview(promptTemplate: true, coverImageUrl: nil)
        print("next")
    }
    
    private func externalActionsComplete() -> Bool {
        for action in self.externalActions {
            if action.description == nil ||
                action.description!.isEmpty ||
                action.type == nil ||
                action.webLink == nil ||
                action.webLink!.isEmpty {
                return false
            }
        }
        return true
    }

}

extension CreatePackageContentViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return externalActionsEnumArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return getStringForExternalAction(type: externalActionsEnumArray[row])
    }
}

extension CreatePackageContentViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("selected row \(getStringForExternalAction(type: externalActionsEnumArray[row]))")
        if let editorView = self.editingPhantomTextField?.superview as? ExternalActionEditorView {
            let selectedType = externalActionsEnumArray[row]
            editorView.actionTypeButton.setTitle(getStringForExternalAction(type: selectedType), for: .normal)
            self.externalActions[editorView.index - 1].type = selectedType
        }
    }
}

extension CreatePackageContentViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var  chosenImage = UIImage()
        chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
//        myImageView.contentMode = .scaleAspectFit //3
//        myImageView.image = chosenImage //4
        self.cropVC = CropViewController(croppingStyle: .default, image: chosenImage)
        self.cropVC?.aspectRatioPreset = .preset7x5
        self.cropVC?.aspectRatioLockEnabled = true
        self.cropVC?.rotateButtonsHidden = true
        self.cropVC?.aspectRatioPickerButtonHidden = true
        self.cropVC?.resetAspectRatioEnabled = false
        self.cropVC?.delegate = self
        self.picker.pushViewController(cropVC!, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension CreatePackageContentViewController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        dismiss(animated: true) {
            // insert cropped photo into stackview and update add cover photo button
            print(image)
            if let data = UIImageJPEGRepresentation(image, 0.5) {
                let bcf = ByteCountFormatter()
                bcf.allowedUnits = [.useMB] // optional: restricts the units to MB only
                bcf.countStyle = .file
                let string = bcf.string(fromByteCount: Int64(data.count))
                print("formatted result: \(string)")
                // display image on stackview
                self.coverPhotoImageView = UIImageView(frame: .zero)
                self.coverPhotoImageView?.isUserInteractionEnabled = true
                self.coverPhotoImageView!.translatesAutoresizingMaskIntoConstraints = false
                self.coverPhotoImageView!.contentMode = .scaleAspectFit
                self.coverPhotoImageView!.image = image
                self.coverPhotoImageView!.layer.cornerRadius = 8
                self.coverPhotoImageView!.clipsToBounds = true
                self.contentStackView.removeArrangedSubview(self.addCoverPhotoButton)
                self.addCoverPhotoButton.removeFromSuperview()
                self.contentStackView.insertArrangedSubview(self.coverPhotoImageView!, at: 0)
                
                let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapCoverPhoto(sender:)))
                self.coverPhotoImageView!.addGestureRecognizer(tapRecognizer)
                
                NSLayoutConstraint.activate([
                    self.coverPhotoImageView!.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor, constant: -36),
                    self.coverPhotoImageView!.heightAnchor.constraint(equalTo: self.coverPhotoImageView!.widthAnchor, multiplier: 5/7),
                ])
                self.nextButton.isEnabled = self.nextButtonEnabled()
            }
        }
    }
    
    @objc private func didTapCoverPhoto(sender: UITapGestureRecognizer) {
        let alertController = UIAlertController(title: String(NSLocalizedString("label.coverPhoto", comment: "label text for cover photo")), message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: String(NSLocalizedString("button.remove", comment: "button title for remove")), style: .destructive, handler: { (action) in
            if self.coverPhotoImageView != nil {
                self.contentStackView.removeArrangedSubview(self.coverPhotoImageView!)
                self.coverPhotoImageView!.removeFromSuperview()
                self.contentStackView.insertArrangedSubview(self.addCoverPhotoButton, at: 0)
                self.coverPhotoImageView!.image = nil
                NSLayoutConstraint.activate([
                    self.addCoverPhotoButton.heightAnchor.constraint(equalToConstant: 50),
                    self.addCoverPhotoButton.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor, constant: -36),
                ])
            }
            self.nextButton.isEnabled = self.nextButtonEnabled()
        }))
        alertController.addAction(UIAlertAction(title: String(NSLocalizedString("button.cancel", comment: "button title for cancel")), style: .cancel, handler: { (action) in
            print("canceled")
            self.nextButton.isEnabled = self.nextButtonEnabled()
        }))
        self.present(alertController, animated: true) {
            print("presented image tap action sheet")
        }
    }
}

extension CreatePackageContentViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension CreatePackageContentViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        nextButton.isEnabled = nextButtonEnabled()
    }
}

extension CreatePackageContentViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.editingPhantomTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.editingPhantomTextField = nil
    }
}
