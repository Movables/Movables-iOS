//
//  MainCoordinator.swift
//  Movables
//
//  Created by Eddie Chen on 5/9/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import Foundation
import UIKit

protocol MainCoordinatorDelegate {
    func coordinatorDidSignout(coordinator: Coordinator)
    func presentDropoffDialog(with package: Package, response: [String: Any])
    func showTab(index: Int)
}

class MainCoordinator: Coordinator {

    let window: UIWindow
    let tabBarController: UITabBarController
    var delegate: MainCoordinatorDelegate?
    
    let discoverCoordinator: DiscoverCoordinator
    let goCoordinator: GoCoordinator
    let monitorCoordinator: MonitorCoordinator
    let organizeCoordinator: OrganizeCoordinator
    let profileCoordinator: ProfileCoordinator
    
    init(with window: UIWindow) {
        
        self.window = window
        self.tabBarController = UITabBarController()
        self.tabBarController.tabBar.tintColor = Theme().textColor
        
        discoverCoordinator = DiscoverCoordinator()
//        let discoverVC = discoverCoordinator.rootViewController.childViewControllers[0] as! DiscoverViewController
        
        goCoordinator = GoCoordinator()
//        let goVC = goCoordinator.rootViewController.childViewControllers[0] as! GoViewController
        
        monitorCoordinator = MonitorCoordinator()
//        let monitorVC = monitorCoordinator.rootViewController.childViewControllers[0] as! MonitorViewController
        
        organizeCoordinator = OrganizeCoordinator()
        
        profileCoordinator = ProfileCoordinator()
        
        let controllers: [UIViewController] = [
            discoverCoordinator.rootViewController,
            goCoordinator.rootViewController,
            monitorCoordinator.rootViewController,
            organizeCoordinator.rootViewController,
            profileCoordinator.rootViewController
       ]
        tabBarController.viewControllers = controllers
    }
    
    func start() {
        showMainTabController()
    }
    
    func showMainTabController() {
        let monitorVC = self.monitorCoordinator.rootViewController.childViewControllers.first as! MonitorViewController
        monitorVC.mainCoordinatorDelegate = delegate
        monitorVC.mainCoordinator = self
        
        let goVC = self.goCoordinator.rootViewController.childViewControllers.first as! GoViewController
        goVC.mainCoordinatorDelegate = delegate
        goVC.mainCoordinator = self
        
        let profileVC = self.profileCoordinator.rootViewController.childViewControllers.first as! ProfileViewController
        profileVC.mainCoordinatorDelegate = delegate
        profileVC.mainCoordinator = self
        
        let organizeVC = self.organizeCoordinator.rootViewController.childViewControllers.first as! OrganizeViewController
        organizeVC.mainCoordinator = self
        organizeVC.mainCoordinatorDelegate = delegate
        
        window.rootViewController = self.tabBarController
        
        self.discoverCoordinator.discoverVC.delegate = self.discoverCoordinator
        self.monitorCoordinator.monitorVC.delegate = self.monitorCoordinator
        self.goCoordinator.goVC.delegate = self.goCoordinator
        self.organizeCoordinator.organizeVC.delegate = self.organizeCoordinator
        self.profileCoordinator.profileVC.delegate = self.profileCoordinator
        print("presented main tab controller")
    }
}
