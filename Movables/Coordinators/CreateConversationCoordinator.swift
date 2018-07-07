//
//  CreateConversationCoordinator.swift
//  Movables
//
//  Created by Eddie Chen on 7/3/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import Foundation
import UIKit

class CreateConversationCoordinator: Coordinator {
    
    let rootViewController: UIViewController
    let navigationController: UINavigationController
    let typeSelectVC: CreateConversationTypeSelectViewController
    
    var topic: Topic!
    
    var type: CommunityType?
    var legislativeArea: (String, String)?
    
    init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
        self.typeSelectVC = CreateConversationTypeSelectViewController()
        self.navigationController = UINavigationController(rootViewController: self.typeSelectVC)
    }
    
    func start() {
        self.typeSelectVC.createConversationCoordinator = self
        rootViewController.present(self.navigationController, animated: true) {
            print("presented tagSearchVC")
        }
    }

    func cancelConversationCreation(created: Bool) {
        self.navigationController.dismiss(animated: true) {
            print("dismissed create package")
            if created {
                // dismiss and reload
                if self.rootViewController.isMember(of: OrganizeDetailViewController.self) {
                    (self.rootViewController as! OrganizeDetailViewController).loadMyConversations()
                }
            }
        }
    }
    
    func showLegislativeAreaSelectVC() {
        let legislativeAreaSelectVC = CreateConversationLegislativeAreaViewController()
        legislativeAreaSelectVC.createConversationCoordinator = self
        self.navigationController.pushViewController(legislativeAreaSelectVC, animated: true)
    }
    
    func unwind() {
        self.navigationController.popViewController(animated: true)
    }
}
