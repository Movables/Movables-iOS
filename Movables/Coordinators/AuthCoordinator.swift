//
//  AuthCoordinator.swift
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

import Foundation
import UIKit
import Firebase

enum AuthMethod {
    case login
    case signup
}


protocol AuthCoordinatorDelegate {
    func coordinatorDidAuthenticate(with authDataResult: AuthDataResult?)
}

class AuthCoordinator: Coordinator {
    var delegate: AuthCoordinatorDelegate?
    let window: UIWindow
    fileprivate var navigationController: UINavigationController!
    fileprivate var loginVC: LoginViewController?
    fileprivate var signupVC: SignupViewController?
    
    init(with window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
        window.rootViewController = self.navigationController
        self.loginVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
    }
    
    func start(with method:AuthMethod) {
        if method == .login {
            showLogin()
        } else {
            showSignup()
        }
    }
    
    func showLogin() {
        self.loginVC = LoginViewController()
        self.loginVC!.delegate = self
        navigationController.show(self.loginVC!, sender: self)
    }
    
    func showSignup() {
        self.signupVC = SignupViewController()
        self.signupVC?.delegate = self
        navigationController.show(self.signupVC!, sender: self)
    }
    
    func showNewUserOnboarding() {
        let interestPickerVC = InterestPickerViewController()
        interestPickerVC.authCoordinator = self
        navigationController.pushViewController(interestPickerVC, animated: true)
    }
}

extension AuthCoordinator: LoginViewControllerDelegate {
    func didLoggedIn(with authDataResult: AuthDataResult?) {
        delegate?.coordinatorDidAuthenticate(with: authDataResult)
    }
    
    func didTapSignupWithEmailButton() {
        showSignup()
    }
}

extension AuthCoordinator: SignupViewControllerDelegate {
    func didSignup(with authDataResult: AuthDataResult?) {
        delegate?.coordinatorDidAuthenticate(with: authDataResult)
    }
}


