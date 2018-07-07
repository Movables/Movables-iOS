//
//  MonitorCoordinator.swift
//  Movables
//
//  Created by Eddie Chen on 5/10/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import Foundation
import UIKit
class MonitorCoordinator: Coordinator {
    
    let rootViewController: UINavigationController
    var monitorVC: MonitorViewController
    var packageDetailVC: PackageDetailViewController?
    
    override init() {
        monitorVC = MonitorViewController()
        self.rootViewController = UINavigationController(rootViewController: monitorVC)
        self.rootViewController.tabBarItem = UITabBarItem(title: "Activities", image: UIImage(named: "tab_track"), tag: 2)
    }
    
}

extension MonitorCoordinator: MonitorViewControllerDelegate {
    func showPackageDetail(with packageId: String, and headline: String) {
        packageDetailVC = PackageDetailViewController()
        packageDetailVC?.headline = headline
        packageDetailVC?.tagName = ""
        packageDetailVC?.packageDocumentId = packageId
        packageDetailVC?.delegate = self
        let packageDetailNC = UINavigationController(rootViewController: packageDetailVC!)
        self.rootViewController.present(packageDetailNC, animated: true) {
            print("presented package detail")
        }
    }
}

extension MonitorCoordinator: PackageDetailViewControllerDelegate {
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
