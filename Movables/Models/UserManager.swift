//
//  UserManager.swift
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
import Firebase

class UserManager {
    static let shared = UserManager()
    var userDocument: UserDocument?
    private var listener: ListenerRegistration?
    
    private init() {
    }
    
    func startListening() {
        listener = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).addSnapshotListener({ (documentSnapshot, error) in
            guard documentSnapshot != nil else {
                print("Error fetching snapshots: \(error?.localizedDescription)")
                return
            }
            self.userDocument = UserDocument(with: documentSnapshot!.data()!, reference: documentSnapshot!.reference)
            // post userDoc update notification
            NotificationCenter.default.post(name: Notification.Name.currentUserDocumentUpdated, object: self, userInfo: ["userDocument": self.userDocument as Any])
        })
    }
    
    func stopListening() {
        listener?.remove()
        userDocument = nil
    }
}
