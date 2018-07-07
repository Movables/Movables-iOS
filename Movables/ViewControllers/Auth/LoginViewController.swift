//
//  LoginViewController.swift
//  Movables
//
//  Created by Eddie Chen on 5/9/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn
import FBSDKLoginKit

protocol LoginViewControllerDelegate {
    func didLoggedIn(with authDataResult: AuthDataResult?)
    func didTapSignupWithEmailButton()
}

class LoginViewController: UIViewController, GIDSignInUIDelegate {
    
    var delegate: LoginViewControllerDelegate?
    
    var emailTextField: TextFieldWithBorder!
    var passwordTextField: TextFieldWithBorder!
    var signInWithEmailButton: UIButton!
    
    var separatorView: UIView!
    
    @IBOutlet weak var signInButton: GIDSignInButton!
    var facebookSignInButton: FacebookButton!
    var signupWithEmailButton: UIButton!
    
    var logoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signInSilently()
        
        emailTextField = TextFieldWithBorder(frame: .zero, type: .email)
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.textField.returnKeyType = .next
        emailTextField.textField.delegate = self
        view.addSubview(emailTextField)
        
        passwordTextField = TextFieldWithBorder(frame: .zero, type: .password)
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.textField.returnKeyType = .done
        passwordTextField.textField.delegate = self
        view.addSubview(passwordTextField)
        
        signInWithEmailButton = UIButton(frame: .zero)
        signInWithEmailButton.translatesAutoresizingMaskIntoConstraints = false
        signInWithEmailButton.layer.cornerRadius = 4
        signInWithEmailButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        signInWithEmailButton.setTitle("Sign in", for: .normal)
        signInWithEmailButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        signInWithEmailButton.setBackgroundColor(color: Theme().grayTextColor, forUIControlState: .normal)
        signInWithEmailButton.setBackgroundColor(color: Theme().grayTextColorHighlight, forUIControlState: .highlighted)
        signInWithEmailButton.setTitleColor(.white, for: .normal)
        signInWithEmailButton.addTarget(self, action: #selector(signInWithEmailButtonTapped(sender:)), for: .touchUpInside)
        signInWithEmailButton.clipsToBounds = true
        view.addSubview(signInWithEmailButton)

        separatorView = UIView(frame: .zero)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = Theme().borderColor
        view.addSubview(separatorView)
        
        facebookSignInButton = FacebookButton(frame: .zero)
        facebookSignInButton.translatesAutoresizingMaskIntoConstraints = false
        facebookSignInButton.delegate = UIApplication.shared.delegate as! AppDelegate
        view.addSubview(facebookSignInButton)
        
        signupWithEmailButton = UIButton(frame: .zero)
        signupWithEmailButton.translatesAutoresizingMaskIntoConstraints = false
        signupWithEmailButton.layer.cornerRadius = 4
        signupWithEmailButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        signupWithEmailButton.setTitle("Signup with Email", for: .normal)
        signupWithEmailButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        signupWithEmailButton.setBackgroundColor(color: Theme().grayTextColor, forUIControlState: .normal)
        signupWithEmailButton.setBackgroundColor(color: Theme().grayTextColorHighlight, forUIControlState: .highlighted)
        signupWithEmailButton.setTitleColor(.white, for: .normal)
        signupWithEmailButton.addTarget(self, action: #selector(signupWithEmailButtonTapped(sender:)), for: .touchUpInside)
        signupWithEmailButton.clipsToBounds = true
        view.addSubview(signupWithEmailButton)

        
        logoImageView = UIImageView(frame: .zero)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode = .scaleAspectFill
        logoImageView.image = UIImage(named: "AppIconVector")
        view.addSubview(logoImageView)
        
        
        NSLayoutConstraint.activate([
            logoImageView.heightAnchor.constraint(equalToConstant: 75),
            logoImageView.widthAnchor.constraint(equalToConstant: 75),
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailTextField.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 80),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 30),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            signInWithEmailButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 50),
            signInWithEmailButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            signInWithEmailButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            signInWithEmailButton.heightAnchor.constraint(equalToConstant: 40),
            separatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            separatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            separatorView.topAnchor.constraint(equalTo: signInWithEmailButton.bottomAnchor, constant: 50),
            facebookSignInButton.bottomAnchor.constraint(equalTo: signInButton.topAnchor, constant: -20),
            facebookSignInButton.heightAnchor.constraint(equalToConstant: 40),
            facebookSignInButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 28),
            facebookSignInButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -28),
            signupWithEmailButton.bottomAnchor.constraint(equalTo: facebookSignInButton.topAnchor, constant: -20),
            signupWithEmailButton.heightAnchor.constraint(equalToConstant: 40),
            signupWithEmailButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 28),
            signupWithEmailButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -28),
        ])

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func signupWithEmailButtonTapped(sender: UIButton) {
        print("singup with email button tapped")
        delegate?.didTapSignupWithEmailButton()
    }
    
    @objc private func signInWithEmailButtonTapped(sender: UIButton) {
        sender.isEnabled = false
        Auth.auth().signIn(withEmail: emailTextField.textField.text!, password: passwordTextField.textField.text!) { (authDataResult, error) in
            if let error = error {
                print(error)
                sender.isEnabled = true
                return
            } else {
                if authDataResult?.user != nil {
                    self.delegate?.didLoggedIn(with: authDataResult)
                }
            }
        }
    }
    
}

extension LoginViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

class FacebookButton: FBSDKLoginButton {
    
    let standardButtonHeight:CGFloat = 40.0
    
    override func updateConstraints() {
        // deactivate height constraints added by the facebook sdk (we'll force our own instrinsic height)
        for contraint in constraints {
            if contraint.firstAttribute == .height, contraint.constant < standardButtonHeight {
                // deactivate this constraint
                contraint.isActive = false
            }
        }
        super.updateConstraints()
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: standardButtonHeight)
    }
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        let logoSize: CGFloat = 24.0
        let centerY = contentRect.midY
        let y: CGFloat = centerY - (logoSize / 2.0)
        return CGRect(x: y, y: y, width: logoSize, height: logoSize)
    }
    
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        if isHidden || bounds.isEmpty {
            return .zero
        }
        
        let imageRect = self.imageRect(forContentRect: contentRect)
        let titleX = imageRect.maxX
        let titleRect = CGRect(x: titleX, y: 0, width: contentRect.width - titleX - titleX, height: contentRect.height)
        return titleRect
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField.textField {
            passwordTextField.textField.becomeFirstResponder()
        } else if textField == passwordTextField.textField {
            textField.resignFirstResponder()
        }
        return false
    }
}





