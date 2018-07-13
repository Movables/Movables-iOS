//
//  DiscoverCoordinator.swift
//  Movables
//
//  Created by Eddie Chen on 5/10/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import Foundation
import UIKit

class DiscoverCoordinator: Coordinator {
    
    let rootViewController: UINavigationController
    let discoverVC: DiscoverViewController
    var packageDetailVC: PackageDetailViewController?
    
    override init() {
        discoverVC = DiscoverViewController()
        self.rootViewController = UINavigationController(rootViewController: discoverVC)
        self.rootViewController.tabBarItem = UITabBarItem(title:String(NSLocalizedString("tabBar.explore", comment: "Profile tab name")), image: UIImage(named: "tab_discover"), tag: 0)
    }
}

extension DiscoverCoordinator: DiscoverViewControllerDelegate {    
    func showPackageDetail(with packagePreview: PackagePreview) {
        packageDetailVC = PackageDetailViewController()
        packageDetailVC?.headline = packagePreview.headline
        packageDetailVC?.tagName = packagePreview.tagName
        packageDetailVC?.packageDocumentId = packagePreview.packageDocumentId
        packageDetailVC?.delegate = self
        let packageDetailNC = UINavigationController(rootViewController: packageDetailVC!)
        self.rootViewController.present(packageDetailNC, animated: true) {
            print("presented package detail")
        }
    }
    
}

extension DiscoverCoordinator: PackageDetailViewControllerDelegate {
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
