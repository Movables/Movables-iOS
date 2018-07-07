//
//  SignupViewController.swift
//  Movables
//
//  Created by Eddie Chen on 6/23/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit
import Firebase
import CropViewController

protocol SignupViewControllerDelegate {
    func didSignup(with authDataResult: AuthDataResult?)
}

class SignupViewController: UIViewController {

    var delegate: SignupViewControllerDelegate!
    
    var profilePicImage: UIImage?
    var stackView: UIStackView!
    var profileImageView: UIImageView!
    var displayNameTextFieldView: TextFieldWithBorder!
    var emailTextFieldView: TextFieldWithBorder!
    var passwordTextFieldView: TextFieldWithBorder!
    var confirmPasswordTextFieldView: TextFieldWithBorder!
    var submitButton: UIButton!
    
    var picker: UIImagePickerController = UIImagePickerController()
    var cropVC: CropViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        let profileImageViewContainerView = UIView(frame: .zero)
        profileImageViewContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        profileImageView = UIImageView(frame: .zero)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.layer.cornerRadius = 50
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.backgroundColor = Theme().backgroundShade
        profileImageView.image = UIImage(named: "user_black_56pt")
        profileImageView.tintColor = Theme().disabledTextColor
        profileImageViewContainerView.addSubview(profileImageView)
        
        NSLayoutConstraint.activate([
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.topAnchor.constraint(equalTo: profileImageViewContainerView.topAnchor, constant: 50),
            profileImageView.bottomAnchor.constraint(equalTo: profileImageViewContainerView.bottomAnchor),
            profileImageView.centerXAnchor.constraint(equalTo: profileImageViewContainerView.centerXAnchor)
        ])
        
        let addProfilePicTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapAddProfilePic(sender:)))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(addProfilePicTapRecognizer)
        
        displayNameTextFieldView = TextFieldWithBorder(frame: .zero, type: .username)
        displayNameTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        displayNameTextFieldView.textField.returnKeyType = .next
        displayNameTextFieldView.textField.delegate = self
        
        emailTextFieldView = TextFieldWithBorder(frame: .zero, type: .email)
        emailTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        emailTextFieldView.textField.returnKeyType = .next
        emailTextFieldView.textField.delegate = self
        
        passwordTextFieldView = TextFieldWithBorder(frame: .zero, type: .password)
        passwordTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        passwordTextFieldView.textField.returnKeyType = .next
        passwordTextFieldView.textField.delegate = self
        
        confirmPasswordTextFieldView = TextFieldWithBorder(frame: .zero, type: .password)
        confirmPasswordTextFieldView.translatesAutoresizingMaskIntoConstraints =
        false
        confirmPasswordTextFieldView.textField.returnKeyType = .done
        confirmPasswordTextFieldView.textField.placeholder = "Confirm Password"
        confirmPasswordTextFieldView.textField.delegate = self
        
        submitButton = UIButton(frame: .zero)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.isEnabled = false
        submitButton.layer.cornerRadius = 4
        submitButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        submitButton.setTitle("Signup", for: .normal)
        submitButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        submitButton.setBackgroundColor(color: Theme().grayTextColor, forUIControlState: .normal)
        submitButton.setBackgroundColor(color: Theme().grayTextColorHighlight, forUIControlState: .highlighted)
        submitButton.setBackgroundColor(color: Theme().borderColor, forUIControlState: .disabled)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.setTitleColor(Theme().disabledTextColor, for: .disabled)
        submitButton.addTarget(self, action: #selector(didTapSubmitButton(sender:)), for: .touchUpInside)
        submitButton.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            submitButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        stackView = UIStackView(arrangedSubviews: [profileImageViewContainerView, displayNameTextFieldView, emailTextFieldView, passwordTextFieldView, confirmPasswordTextFieldView, submitButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 30
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
        ])
        
        picker.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func didTapSubmitButton(sender: UIButton) {
        print("did tap submit button")
        sender.isEnabled = false
        Auth.auth().createUser(withEmail: self.emailTextFieldView.textField.text!, password: self.passwordTextFieldView.textField.text!) { (authDataResult, error) in
            if let error = error {
                print(error)
                sender.isEnabled = true
                return
            } else {
                let image = self.profilePicImage!
                let metaData = StorageMetadata()
                metaData.contentType = "image/jpeg"
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                let dateString = dateFormatter.string(from: Date())
                let profilePicImageReference = Storage.storage().reference().child("images/profile_pics/\(authDataResult!.user.uid)/\(dateString).jpeg")
                profilePicImageReference.putData(UIImageJPEGRepresentation(image, 0.5)!, metadata: metaData, completion: { (meta, error) in
                    if let error = error {
                        print("error: \(error)")
                    } else {
                        profilePicImageReference.downloadURL(completion: { (url, error) in
                            guard let downloadURL = url else {
                                // Uh-oh, an error occurred!
                                print(error!)
                                return
                            }
                            let profileChangeRequest = authDataResult!.user.createProfileChangeRequest()
                            profileChangeRequest.photoURL = downloadURL
                            profileChangeRequest.displayName = self.displayNameTextFieldView.textField.text!
                            profileChangeRequest.commitChanges(completion: { (error) in
                                if error != nil {
                                    print(error!)
                                } else {
                                    self.delegate.didSignup(with: authDataResult)
                                }
                            })
                        })
                    }
                })
            }
        }
    }
    
    private func checkSubmitState() {
        submitButton.isEnabled = (
            profilePicImage != nil &&
            !displayNameTextFieldView.textField.text!.isEmpty &&
            !emailTextFieldView.textField.text!.isEmpty &&
            !passwordTextFieldView.textField.text!.isEmpty &&
            !confirmPasswordTextFieldView.textField.text!.isEmpty &&
            passwordTextFieldView.textField.text! == confirmPasswordTextFieldView.textField.text!
        )
    }
    
    @objc private func didTapAddProfilePic(sender: UITapGestureRecognizer) {
        print("did tap add profile pic")
        if self.profilePicImage != nil {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: { (action) in
                self.profileImageView.image = UIImage(named: "user_black_56pt")
                self.profilePicImage = nil
                self.checkSubmitState()
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                print("canceled")
                self.checkSubmitState()
            }))
            self.present(alertController, animated: true) {
                print("presented image tap action sheet")
            }
        } else {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
                print("Camera")
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    self.picker.allowsEditing = false
                    self.picker.sourceType = UIImagePickerControllerSourceType.camera
                    self.picker.cameraCaptureMode = .photo
                    self.picker.cameraDevice = .front
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
            alertController.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
                print("Photo Library")
                self.picker.allowsEditing = false
                self.picker.sourceType = .photoLibrary
                self.picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
                self.picker.modalPresentationStyle = .overCurrentContext
                self.present(self.picker, animated: true, completion: nil)
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                print("Cancel")
            }))
            present(alertController, animated: true) {
                print("presented alert controller")
            }
        }
    }

}

extension SignupViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var  chosenImage = UIImage()
        chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        self.cropVC = CropViewController(croppingStyle: .circular, image: chosenImage)
        self.cropVC?.aspectRatioPreset = .presetSquare
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


extension SignupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case self.displayNameTextFieldView.textField :
            self.emailTextFieldView.textField.becomeFirstResponder()
        case self.emailTextFieldView.textField :
            self.passwordTextFieldView.textField.becomeFirstResponder()
        case self.passwordTextFieldView.textField :
            self.confirmPasswordTextFieldView.textField.becomeFirstResponder()
        case self.confirmPasswordTextFieldView.textField :
            textField.resignFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkSubmitState()
    }
}

extension SignupViewController: CropViewControllerDelegate {
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
                self.profileImageView.image = image
                self.profilePicImage = image
                self.checkSubmitState()
            }
        }
    }
}