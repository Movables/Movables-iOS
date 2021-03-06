//
//  MainCoordinator.swift
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

protocol MainCoordinatorDelegate {
    func coordinatorDidSignout(coordinator: Coordinator)
    func presentDropoffDialog(with package: Package, response: [String: Any])
    func showTab(index: Int)
}

class MainCoordinator: Coordinator {

    let window: UIWindow
    let tabBarController: UITabBarController
    var delegate: MainCoordinatorDelegate?
    
    let exploreCoordinator: ExploreCoordinator
    let moveCoordinator: MoveCoordinator
    let activitiesCoordinator: ActivitiesCoordinator
    let organizeCoordinator: OrganizeCoordinator
    let profileCoordinator: ProfileCoordinator
    
    init(with window: UIWindow) {
        
        self.window = window
        self.tabBarController = UITabBarController()
        self.tabBarController.tabBar.tintColor = Theme().textColor
        
        exploreCoordinator = ExploreCoordinator()
        
        moveCoordinator = MoveCoordinator()
        
        activitiesCoordinator = ActivitiesCoordinator()
        
        organizeCoordinator = OrganizeCoordinator()
        
        profileCoordinator = ProfileCoordinator()
        
        let controllers: [UIViewController] = [
            exploreCoordinator.rootViewController,
            moveCoordinator.rootViewController,
            activitiesCoordinator.rootViewController,
            organizeCoordinator.rootViewController,
            profileCoordinator.rootViewController
       ]
        tabBarController.viewControllers = controllers
    }
    
    func start() {
        showMainTabController()
    }
    
    func showMainTabController() {
        let activitiesVC = self.activitiesCoordinator.rootViewController.children.first as! ActivitiesViewController
        activitiesVC.mainCoordinatorDelegate = delegate
        activitiesVC.mainCoordinator = self
        
        let moveVC = self.moveCoordinator.rootViewController.children.first as! MoveViewController
        moveVC.mainCoordinatorDelegate = delegate
        moveVC.mainCoordinator = self
        
        let profileVC = self.profileCoordinator.rootViewController.children.first as! ProfileViewController
        profileVC.mainCoordinatorDelegate = delegate
        profileVC.mainCoordinator = self
        
        let organizeVC = self.organizeCoordinator.rootViewController.children.first as! OrganizeViewController
        organizeVC.mainCoordinator = self
        organizeVC.mainCoordinatorDelegate = delegate
        
        window.rootViewController = self.tabBarController
        
        self.exploreCoordinator.exploreVC.delegate = self.exploreCoordinator
        self.activitiesCoordinator.activitiesVC.delegate = self.activitiesCoordinator
        self.moveCoordinator.moveVC.delegate = self.moveCoordinator
        self.organizeCoordinator.organizeVC.delegate = self.organizeCoordinator
        self.profileCoordinator.profileVC.delegate = self.profileCoordinator
        print("presented main tab controller")
    }
}
