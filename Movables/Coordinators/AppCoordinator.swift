//
//  AppCoordinator.swift
//  Movables
//
//  Created by Eddie Chen on 5/3/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

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
