//
//  CreateConversationCoordinator.swift
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

class CreateConversationCoordinator: Coordinator {
    
    let rootViewController: UIViewController
    let navigationController: UINavigationController
    let legislativeAreaSelectVC: CreateConversationLegislativeAreaViewController
    
    var topic: Topic!
    
    var type: CommunityType?
    var legislativeArea: (String, String)?
    
    init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
        legislativeAreaSelectVC = CreateConversationLegislativeAreaViewController()
        
        self.navigationController = UINavigationController(rootViewController: self.legislativeAreaSelectVC)
    }
    
    func start() {
        self.legislativeAreaSelectVC.createConversationCoordinator = self
        rootViewController.present(self.navigationController, animated: true) {
            print("presented topicSearchVC")
        }
    }

    func cancelConversationCreation(created: Bool) {
        self.navigationController.dismiss(animated: true) {
            print("dismissed create package")
            if created {
                // dismiss and reload
                if self.rootViewController.isMember(of: SubscribedTopicDetailViewController.self) {
                    (self.rootViewController as! SubscribedTopicDetailViewController).loadMyConversations()
                }
            }
        }
    }
    
//    func showLegislativeAreaSelectVC() {
//        let legislativeAreaSelectVC = CreateConversationLegislativeAreaViewController()
//        legislativeAreaSelectVC.createConversationCoordinator = self
//        self.navigationController.pushViewController(legislativeAreaSelectVC, animated: true)
//    }
    
    func unwind() {
        self.navigationController.popViewController(animated: true)
    }
}
