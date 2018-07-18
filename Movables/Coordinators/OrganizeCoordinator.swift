//
//  OrganizeCoordinator.swift
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
import Firebase

class OrganizeCoordinator: Coordinator {
    let rootViewController: UINavigationController
    var organizeVC: OrganizeViewController
    var subscribedTopicDetailVC: SubscribedTopicDetailViewController?
    
    override init() {
        organizeVC = OrganizeViewController()
        self.rootViewController = UINavigationController(rootViewController: organizeVC)
        self.rootViewController.tabBarItem = UITabBarItem(title: String(NSLocalizedString("tabBar.organize", comment: "Organize tab name")), image: UIImage(named: "tab_organize"), tag: 3)
    }
}

extension OrganizeCoordinator: OrganizeViewControllerDelegate {
    
    func showSubscribedTopicDetailVC(for subscribedTopic: TopicSubscribed) {
        subscribedTopicDetailVC = SubscribedTopicDetailViewController()
        subscribedTopicDetailVC?.subscribedTopic = subscribedTopic
        subscribedTopicDetailVC?.delegate = self
        let subscribedTopicDetailNC = UINavigationController(rootViewController: subscribedTopicDetailVC!)
        self.rootViewController.present(subscribedTopicDetailNC, animated: true) {
            print("presented organize detail")
        }
    }
}

extension OrganizeCoordinator: SubscribedTopicDetailViewControllerDelegate {
    func dismissSubscribedTopicDetailVC() {
        subscribedTopicDetailVC?.dismiss(animated: true, completion: {
            print("dismissed organize detail vc")
        })
    }
    
    func showPostsVC(for reference: DocumentReference, referenceType: CommunityType) {
        let postsVC = PostsViewController(collectionViewLayout: UICollectionViewFlowLayout())
        postsVC!.reference = reference
        self.subscribedTopicDetailVC?.navigationController?.pushViewController(postsVC!, animated: true)
    }
}
