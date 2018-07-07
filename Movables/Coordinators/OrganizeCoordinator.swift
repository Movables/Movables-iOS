//
//  OrganizeCoordinator.swift
//  Movables
//
//  Created by Eddie Chen on 6/6/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class OrganizeCoordinator: Coordinator {
    let rootViewController: UINavigationController
    var organizeVC: OrganizeViewController
    var organizeDetailVC: OrganizeDetailViewController?
    
    override init() {
        organizeVC = OrganizeViewController()
        self.rootViewController = UINavigationController(rootViewController: organizeVC)
        self.rootViewController.tabBarItem = UITabBarItem(title: "Organize", image: UIImage(named: "tab_organize"), tag: 3)
    }
}

extension OrganizeCoordinator: OrganizeViewControllerDelegate {
    
    func showOrganizeDetailVC(for organizeTopic: OrganizeTopic) {
        organizeDetailVC = OrganizeDetailViewController()
        organizeDetailVC?.organizeTopic = organizeTopic
        organizeDetailVC?.delegate = self
        let organizeDetailNC = UINavigationController(rootViewController: organizeDetailVC!)
        self.rootViewController.present(organizeDetailNC, animated: true) {
            print("presented organize detail")
        }
    }
}

extension OrganizeCoordinator: OrganizeDetailViewControllerDelegate {
    func dismissOrganizeDetailVC() {
        organizeDetailVC?.dismiss(animated: true, completion: {
            print("dismissed organize detail vc")
        })
    }
    
    func showPostsVC(for reference: DocumentReference, referenceType: CommunityType) {
        let postsVC = PostsViewController(collectionViewLayout: UICollectionViewFlowLayout())
        postsVC!.reference = reference
        self.organizeDetailVC?.navigationController?.pushViewController(postsVC!, animated: true)
    }
}
