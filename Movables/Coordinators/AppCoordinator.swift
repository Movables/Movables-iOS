//
//  AppCoordinator.swift
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
import Firebase
import GoogleSignIn

class AppCoordinator: Coordinator {
    fileprivate var isLoggedIn = false
    fileprivate let window:UIWindow
    fileprivate var childCoordinators = [Coordinator]()
    fileprivate var mainCoordinator: MainCoordinator!
    var authCoordinator: AuthCoordinator!
    
    init(with window: UIWindow) {
        self.window = window
    }
    
    func start() {
        if Auth.auth().currentUser != nil {
            showMain()
        } else {
            showLogin()
        }
    }
    
    func showMain() {
        mainCoordinator = MainCoordinator(with: self.window)
        mainCoordinator.delegate = self
        mainCoordinator.start()
        childCoordinators.removeAll()
        childCoordinators.append(mainCoordinator)
    }
    
    func showLogin() {
        authCoordinator = AuthCoordinator(with: self.window)
        authCoordinator.delegate = UIApplication.shared.delegate as! AppDelegate
        authCoordinator.start(with: .login)
    }
    
    //we need a better way to find coordinators
    fileprivate func removeCoordinator(coordinator:Coordinator) {
        
        var idx:Int?
        for (index,value) in childCoordinators.enumerated() {
            if value === coordinator {
                idx = index
                break
            }
        }
        
        if let index = idx {
            childCoordinators.remove(at: index)
        }
        
    }
}

extension AppCoordinator: MainCoordinatorDelegate {
    
    func coordinatorDidSignout(coordinator: Coordinator) {
        print("go delegate method")
        removeCoordinator(coordinator: coordinator)
        self.window.rootViewController = UIViewController()
        showLogin()
    }
    
    func presentDropoffDialog(with package: Package, response: [String: Any]) {
        let dropoffSummaryVC = DropoffSummaryViewController()
        dropoffSummaryVC.package = package
        dropoffSummaryVC.response = response
        self.window.rootViewController?.present(UINavigationController(rootViewController: dropoffSummaryVC), animated: true, completion: {
            print("presented dialog with delivered \(response["delivered"] as! Bool)")
        })
    }
    
    func showTab(index: Int) {
        mainCoordinator.tabBarController.selectedIndex = index
    }
}
