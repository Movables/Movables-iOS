//
//  AppDelegate.swift
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

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
import Fabric
import Crashlytics
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, FBSDKLoginButtonDelegate, AuthCoordinatorDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator?
    
    public var algoliaClientId: String?
    public var algoliaAPIKey: String?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        readCredentials()
        
        setupServices(app: application, launchOptions: launchOptions)
                        
        setupAppCoordinator()
        
        IQKeyboardManager.shared.enable = true

        
        return true
    }
    
    private func readCredentials() {
        var myDict: NSDictionary?
        if let path = Bundle.main.path(forResource: "credentials", ofType: "plist") {
            myDict = NSDictionary(contentsOfFile: path)
        }
        if let dict = myDict {
        // Use your dict here
            algoliaClientId = dict["algoliaClientId"] as? String
            algoliaAPIKey = dict["algoliaAPIKey"] as? String
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let facebookDidHandle = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        let googleDidHandle = GIDSignIn.sharedInstance().handle(url, sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: [:])

        return googleDidHandle || facebookDidHandle
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error)
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        Auth.auth().signInAndRetrieveData(with: credential) { (authDataResult, error) in
            if let error = error {
                print(error)
                return
            } else if authDataResult?.additionalUserInfo != nil && authDataResult!.additionalUserInfo!.isNewUser {
                self.createUserProfile(authDataResult: authDataResult!) { (success) in
                    if success {
                        self.appCoordinator?.authCoordinator.showNewUserOnboarding()
                    } else {
                        print("something happened")
                    }
                }
            } else {
                self.appCoordinator?.showMain()
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print(error)
        do {
            try Auth.auth().signOut()
            self.appCoordinator?.showLogin()
        } catch let error{
            print(error)
        }
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        guard let accessToken = FBSDKAccessToken.current() else { return }
        let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
        Auth.auth().signInAndRetrieveData(with: credential) { (authDataResult, error) in
            if let error = error {
                print(error)
                return
            } else if authDataResult?.additionalUserInfo != nil && authDataResult!.additionalUserInfo!.isNewUser {
                self.createUserProfile(authDataResult: authDataResult!) { (success) in
                    if success {
                        self.appCoordinator?.authCoordinator.showNewUserOnboarding()
                    } else {
                        print("something happened")
                    }
                }
            } else {
                self.appCoordinator?.showMain()
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        do {
            try Auth.auth().signOut()
            self.appCoordinator?.showLogin()
        } catch let error{
            print(error)
        }
    }
    
    func coordinatorDidAuthenticate(with authDataResult: AuthDataResult?) {
        print("did log in")
        UserManager.shared.startListening()
        if authDataResult?.additionalUserInfo != nil && authDataResult!.additionalUserInfo!.isNewUser {
            createUserProfile(authDataResult: authDataResult!) { (success) in
                if success {
                    self.appCoordinator?.authCoordinator.showNewUserOnboarding()
                } else {
                    print("something happened")
                }
            }
        } else {
            self.appCoordinator?.showMain()
        }
    }

    private func createUserProfile(authDataResult: AuthDataResult, completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        db.collection("users").document(authDataResult.user.uid).setData(
            [
                "public_profile": [
                    "uid": authDataResult.user.uid,
                    "display_name": authDataResult.user.displayName!,
                    "pic_url": authDataResult.user.photoURL?.absoluteString ?? "",
                    "count": ["packages_following": 0, "packages_moved": 0],
                    "created_date": Date()
                ],
                "private_profile": ["time_bank_balance": 100.0],
            ]
        ) { (error) in
            if let error = error {
                print(error)
                completion(false)
            }
            else {
                completion(true)
            }
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    private func setupServices(app: UIApplication, launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        FirebaseApp.configure()
        
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        FBSDKApplicationDelegate.sharedInstance().application(app, didFinishLaunchingWithOptions: launchOptions)
        
        Fabric.with([Crashlytics.self])
    }

    private func setupAppCoordinator() {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.tintColor = Theme().textColor
        
        appCoordinator = AppCoordinator(with: window!)
        appCoordinator?.start()
        GIDSignIn.sharedInstance().delegate = self
        
        window?.makeKeyAndVisible()
    }
}

