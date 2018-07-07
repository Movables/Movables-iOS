//
//  AuthCoordinator.swift
//  Movables
//
//  Created by Eddie Chen on 5/9/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

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


