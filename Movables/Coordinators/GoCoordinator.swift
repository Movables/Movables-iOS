//
//  GoCoordinator.swift
//  Movables
//
//  Created by Eddie Chen on 5/10/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import Foundation
import UIKit

class GoCoordinator: Coordinator {
    
    let rootViewController: UINavigationController
    var goVC: GoViewController
    var packageDetailVC: PackageDetailViewController?
    
    override init() {
        goVC = GoViewController()
        self.rootViewController = UINavigationController(rootViewController: goVC)
        self.rootViewController.tabBarItem = UITabBarItem(title: String(NSLocalizedString("tabBar.move", comment: "Move tab name")), image: UIImage(named: "tab_move"), tag: 1)
    }
    
    func start() {
    
    }
}

extension GoCoordinator: GoViewControllerDelegate {
    func showPackageDetail(with package: Package) {
        packageDetailVC = PackageDetailViewController()
        packageDetailVC?.headline = package.headline
        packageDetailVC?.tagName = package.tag.name
        packageDetailVC?.packageDocumentId = package.reference.documentID
        packageDetailVC?.delegate = self
        let packageDetailNC = UINavigationController(rootViewController: packageDetailVC!)
        self.rootViewController.present(packageDetailNC, animated: true) {
            print("presented package detail")
        }
    }
}

extension GoCoordinator: PackageDetailViewControllerDelegate {
    func dismissPackageDetailVC() {
        packageDetailVC?.view.endEditing(true)
        packageDetailVC?.dismiss(animated: true, completion: {
            print("package detail dismissed")
        })
    }
    
    func showPostsVC() {
        let postsVC = PostsViewController(collectionViewLayout: UICollectionViewFlowLayout())
        postsVC!.reference = packageDetailVC?.package?.reference
        postsVC!.referenceType = .package
        packageDetailVC?.navigationController?.show(postsVC!, sender: packageDetailVC)
    }
    
    func presentDropoffSummary(with package: Package, response: [String : Any]) {
        let dropoffSummaryVC = DropoffSummaryViewController()
        dropoffSummaryVC.package = package
        dropoffSummaryVC.response = response
        
        packageDetailVC?.navigationController?.pushViewController(dropoffSummaryVC, animated: true)
    }
    
    func showMapRouteVC(for package: Package) {
        let mapRouteVC = MapRouteViewController()
        mapRouteVC.package = package
        packageDetailVC?.navigationController?.show(mapRouteVC, sender: packageDetailVC)
    }

}
