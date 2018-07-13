//
//  CreatePackageCoordinator.swift
//  Movables
//
//  Created by Eddie Chen on 6/11/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import Foundation
import Firebase
import UIKit
import SafariServices

class CreatePackageCoordinator: Coordinator {
    let rootViewController: UIViewController
    let tagSearchVC: CreatePackageTagSearchViewController
    let navigationController: UINavigationController
    var packageDraft: Package?
    var category: PackageCategory?
    var tagResultItem: PackageTagResultItem?
    var recipientResultItem: RecipientResultItem?
    var destinationResultItem: DestinationResultItem?
    var packageCoverPhotoImage: UIImage?
    var packageDueDate: Date?
    var packageHeadline: String?
    var packageDescription: String?
    var userDoc: UserDocument?
    var shouldSaveAsTemplate: Bool?
    var usingTemplate: Bool = false
    var template: PackageTemplate?
    var externalActions: [ExternalAction]?
    var dropoffMessage: String?
    
    init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
        self.tagSearchVC = CreatePackageTagSearchViewController()
        self.navigationController = UINavigationController(rootViewController: self.tagSearchVC)
    }
    
    func start() {
        self.tagSearchVC.createPackageCoordinator = self
        rootViewController.present(self.navigationController, animated: true) {
            print("presented tagSearchVC")
        }
    }
    
    func pushToTemplates() {
        let templatesVC = CreatePackageTemplatesViewController()
        templatesVC.createPackageCoordinator = self
        self.navigationController.pushViewController(templatesVC, animated: true)
    }
    
    func pushToCategory() {
        let categorySetVC = CreatePackageCategorySetViewController()
        categorySetVC.createPackageCoordinator = self
        self.navigationController.pushViewController(categorySetVC, animated: true)
    }
    
    func pushToRecipient() {
        let personSearchVC = CreatePackagePersonSearchViewController()
        personSearchVC.createPackageCoordinator = self
        self.navigationController.pushViewController(personSearchVC, animated: true)
    }
    
    func pushToDestination() {
        let destinationVC = CreatePackageDestinationSearchViewController()
        destinationVC.createPackageCoordinator = self
        self.navigationController.pushViewController(destinationVC, animated: true)
    }
    
    func pushToContent() {
        let contentVC = CreatePackageContentViewController()
        contentVC.createPackageCoordinator = self
        self.navigationController.pushViewController(contentVC, animated: true)
    }
    
    func showSFVC(with url: URL){
        let safariVC = SFSafariViewController(url: url)
        navigationController.present(safariVC, animated: true, completion: nil)
    }
    
    func setContentAndPushToReview(promptTemplate: Bool, coverImageUrl: URL?) {
        if promptTemplate {
            let alertController = UIAlertController(title: String(NSLocalizedString("copy.alert.packageTemplates", comment: "alert title for package templates")), message: String(format: NSLocalizedString("copy.alert.packageTemplateDesc", comment: "alert body label for package templates"), self.tagResultItem!.tag), preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: String(NSLocalizedString("button.createTemplate", comment: "button title for create template")), style: .default, handler: { (action) in
                self.shouldSaveAsTemplate = true
                self.pushToReview(coverImageUrl: coverImageUrl)
            }))
            alertController.addAction(UIAlertAction(title: String(NSLocalizedString("button.dontCreateTemplate", comment: "button title for dont create template")), style: .default, handler: { (action) in
                self.shouldSaveAsTemplate = false
                self.pushToReview(coverImageUrl: coverImageUrl)
            }))
            self.navigationController.present(alertController, animated: true) {
                print("presented template alert")
            }
        } else {
            self.shouldSaveAsTemplate = false
            self.pushToReview(coverImageUrl: coverImageUrl)
        }
        
    }
    
    private func pushToReview(coverImageUrl: URL?) {
        let reviewVC = CreatePackageReviewViewController()
        
        if coverImageUrl != nil {
            reviewVC.coverImageUrl = coverImageUrl!
        } else {
            reviewVC.coverImage = packageCoverPhotoImage
        }
        reviewVC.sender = Person(displayName: Auth.auth().currentUser!.displayName ?? "", photoUrl: Auth.auth().currentUser!.photoURL?.absoluteString ?? "", reference: Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid), twitter_handle: nil, phone: nil)
        reviewVC.recipient = Person(displayName: recipientResultItem?.name ?? "", photoUrl: recipientResultItem?.picUrl ?? "", reference: Firestore.firestore().collection("recipients").document(), twitter_handle: nil, phone: nil)
        reviewVC.packageHeadline = packageHeadline
        reviewVC.packageTagName = tagResultItem?.tag ?? ""
        reviewVC.packageDescription = packageDescription ?? ""
        reviewVC.originCoordinate = LocationManager.shared.location?.coordinate
        reviewVC.destinationCoordinate = destinationResultItem?.placemark.coordinate
        reviewVC.packageDueDate = packageDueDate
        reviewVC.category = category
        reviewVC.createPackageCoordinator = self
        self.navigationController.pushViewController(reviewVC, animated: true)
    }
    
    func savePackageAndDismiss(coverImageUrl: URL?, completion: @escaping (Bool) -> ()) {
        fetchUserDoc(uid: Auth.auth().currentUser!.uid, completion: { (userDoc) in
            if userDoc != nil {
                self.userDoc = userDoc
                // self.userDoc is available
                let alertController = UIAlertController(title: String(NSLocalizedString("copy.alert.packageCreation", comment: "alert title for package creation")), message: String(format: NSLocalizedString("copy.alert.packageCreationDesc", comment: "alert body for packageCreation"), Int(self.userDoc!.privateProfile.timeBankBalance - 100)), preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: String(NSLocalizedString("button.ok", comment: "button title for ok")), style: .default, handler: { (action) in
                    print("confirmed creation")
                    self.constructPackage(coverImageUrl: coverImageUrl, completion: { (success, packageData) in
                        if success {
                            self.preparePackage(with: packageData, completion: { (success, packageData) in
                                if success {
                                    self.savePackageWithTransaction(with: coverImageUrl, packageData: packageData, makeTemplate: self.shouldSaveAsTemplate!, completion: { (success) in
                                        if success {
                                            print("package saved everything saved")
                                            completion(true)
                                        } else {
                                            // something went wrong saving package data
                                            completion(false)
                                            print("something wrong and something didn't get saved :(")
                                        }
                                    })
                                } else {
                                    // something wrong with tag processing
                                    completion(false)
                                }
                            })
                        } else {
                            // something went wrong constructing data
                            completion(false)
                        }
                    })
                }))
                alertController.addAction(UIAlertAction(title: String(NSLocalizedString("button.cancel", comment: "button title for cancel")), style: .cancel, handler: { (action) in
                    print("cancel creation")
                    completion(false)
                }))
                self.navigationController.present(alertController, animated: true, completion: {
                    print("presented bank alert")
                })
            } else {
                completion(false)
            }
        })
        
        // save cover photo first
        
        // process tagResultItem -> PackageTag
        // -- handle the case of templatesCount nil AND packagesCount nil
        // -- -- create tag with placeholder reference
        // -- handle the case of templatesCount not nil AND packagesCount not nil
        // -- -- fetch tag with reference
        
        // check category != nil
        
        // process recipientResultItem -> Person
        
        // save package and package template transaction
        
        // batch -- add package
        
        // transaction
        // -- save package with in_transit_by
        // -- update private_profile.current_package in user document
    }
    
    func constructPackage(coverImageUrl: URL?, completion: @escaping (Bool, [String: Any]) -> ()) {
        var packageData: [String: Any] = [:]
        
        let location = LocationManager.shared.location
        packageData["_geoloc"] = GeoPoint(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        
        packageData["author"] = [
            "name": userDoc!.publicProfile.displayName,
            "pic_url": userDoc!.publicProfile.picUrl ?? "",
            "reference": userDoc!.reference
        ]
    
        let categoriesArray:[PackageCategory] = [category!]
        var categories: [String: Bool] = [:]
        for category in categoriesArray {
            categories.updateValue(true, forKey: getStringForCategory(category: category))
        }
        packageData["categories"] = categories
        
        packageData["count"] = [
            "followers": 0,
            "movers": 0
        ]
        
        packageData["created_date"] = Date()
        
        packageData["description"] = packageDescription!
        
        packageData["destination"] = [
            "address": destinationResultItem!.placemark.postalAddress != nil && !destinationResultItem!.placemark.postalAddress!.street.isEmpty && !destinationResultItem!.placemark.postalAddress!.subAdministrativeArea.isEmpty ? "\(destinationResultItem!.placemark.postalAddress!.street), \(destinationResultItem!.placemark.postalAddress!.subAdministrativeArea)" : "\(destinationResultItem!.placemark.location!.coordinate.longitude), \(destinationResultItem!.placemark.location!.coordinate.latitude)",
            "geo_point": GeoPoint(latitude: destinationResultItem!.placemark.coordinate.latitude, longitude: destinationResultItem!.placemark.coordinate.longitude),
            "name": destinationResultItem!.name ?? ""
        ]
        
        packageData["due_date"] = [
            "start": packageDueDate!,
            "end": packageDueDate!,
        ]
        
        packageData["headline"] = packageHeadline!
        
        packageData["in_transit_by"] = [
            "name": userDoc!.publicProfile.displayName,
            "pic_url": userDoc!.publicProfile.picUrl ?? "",
            "reference": userDoc!.reference
        ]
        
        packageData["origin"] = [
            "address": "",
            "geo_point": GeoPoint(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude),
            "name": "",
        ]
        
        packageData["recipient"] = [
            "name": recipientResultItem!.name,
            "phone": nil,
            "pic_url": recipientResultItem!.picUrl ?? "",
            "twitter_handle": nil,
        ]
        
        packageData["dropoff_message"] = dropoffMessage
        
        packageData["status"] = "transit"
        
        if coverImageUrl != nil {
            packageData["cover_pic_url"] = coverImageUrl?.absoluteString
        }
        
        if usingTemplate {
            packageData["template_by"] = [
                "name": userDoc!.publicProfile.displayName,
                "pic_url": userDoc!.publicProfile.picUrl ?? "",
                "reference": userDoc!.reference
            ]
        }
        
        completion(true, packageData)
    }
    
    private func preparePackage(with packageData: [String: Any], completion: @escaping (Bool, [String: Any]) -> ()) {
        // locate tag
        var packageData = packageData
        let db = Firestore.firestore()
        db.collection("topics").whereField("tag", isEqualTo: self.tagResultItem!.tag).getDocuments { (snapshot, error) in
            if error != nil {
                print(error!)
            } else {
                if snapshot != nil {
                    if (snapshot!.documents.count > 0) {
                        // tag already exists
                        packageData["tag"] = [
                            "name": self.tagResultItem!.tag,
                            "reference": snapshot!.documents.first!.reference,
                        ]
                        print(packageData)
                        completion(true, packageData)
                    } else {
                        var ref: DocumentReference? = nil
                        ref = db.collection("topics").addDocument(data: ["tag": self.tagResultItem!.tag, "count": ["templates": 0, "packages": 0]], completion: { (error) in
                            if error != nil {
                                print(error!)
                            } else {
                                packageData["tag"] = [
                                    "name": self.tagResultItem!.tag,
                                    "reference": ref!,
                                ]
                                print(packageData)
                                completion(true, packageData)
                            }
                        })
                    }
                }
            }
        }
    }



    func cancelPacakgeCreation() {
        self.navigationController.dismiss(animated: true) {
            print("dismissed create package")
        }
    }
    
    func unwind() {
        self.navigationController.popViewController(animated: true)
    }
    
    private func savePackageWithTransaction(with coverImageUrl: URL?, packageData: [String: Any], makeTemplate: Bool, completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        var newPackageRef: DocumentReference?
        var topicTemplateRef: DocumentReference?
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let userReference: DocumentReference = db.collection("users").document(Auth.auth().currentUser!.uid)
            // -- save package with in_transit_by
            // -- update private_profile.current_package in user document
            
            let userDocument: DocumentSnapshot
            do {
                try userDocument = transaction.getDocument(userReference)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            let oldBalance = (userDocument.data()!["private_profile"] as! [String: Any])["time_bank_balance"] as! Int
            let newBalance = oldBalance + 10

            newPackageRef = db.collection("packages").document()
            
            let topicReference = (packageData["tag"] as! [String : Any])["reference"] as! DocumentReference
            let topicDocument: DocumentSnapshot
            do {
                try topicDocument = transaction.getDocument(topicReference)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let oldCountPackages = ((topicDocument.data()! as [String: Any])["count"] as! [String: Int])["packages"] else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve templates count from snapshot \(topicDocument)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            
            let newCountPackages = oldCountPackages + 1
            
            guard let oldCountTemplates = ((topicDocument.data()! as [String: Any])["count"] as! [String: Int])["templates"] else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve templates count from snapshot \(topicDocument)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            
            var newCountTemplates: Int?
            var newCountPackagesUsedTemplate: Int?

            if makeTemplate {
                newCountTemplates = oldCountTemplates + 1
                topicTemplateRef = ((packageData["tag"] as! [String : Any])["reference"] as! DocumentReference).collection("templates").document()
                var packageDataToSave = packageData
                packageDataToSave["count"] = ["packages": 1]
                packageDataToSave["template_by"] = packageData["author"]
                transaction.setData(packageDataToSave, forDocument: topicTemplateRef!)
                if self.externalActions != nil {
                    for action in self.externalActions! {
                        let actionData = [
                            "description": action.description!,
                            "web_link": action.webLink!,
                            "type": getStringForExternalAction(type: action.type!)
                        ]
                        transaction.setData(actionData, forDocument: topicTemplateRef!.collection("external_actions").document())
                    }
                }
                let templateCreationTransaction: [String: Any] = [
                    "date": Date(),
                    "object_reference": topicTemplateRef!,
                    "object_type": getStringForObjectTypeEnum(type: .topic),
                    "object_name": (packageData["tag"] as! [String : Any])["name"] as! String,
                    "type": getStringForActivityTypeEnum(type: .templateCreation),
                    "actor_name": Auth.auth().currentUser!.displayName!,
                    "actor_pic": Auth.auth().currentUser!.photoURL?.absoluteString ?? "",
                    "actor_reference": userReference,
                    "amount": 10
                ]
                transaction.setData(templateCreationTransaction, forDocument: userReference.collection("account_activities").document())
                transaction.updateData(["private_profile.time_bank_balance": newBalance], forDocument: userReference)
            } else {
                newCountTemplates = oldCountTemplates
                var templateDocumentRef: DocumentReference?
                if self.usingTemplate {
                    templateDocumentRef = self.template!.reference
                    let templateDocument: DocumentSnapshot
                    do {
                        try templateDocument = transaction.getDocument(templateDocumentRef!)
                    } catch let fetchError as NSError {
                        errorPointer?.pointee = fetchError
                        return nil
                    }
                    
                    guard let oldCountPackages = ((templateDocument.data()! as [String: Any])["count"] as! [String: Int])["packages"] else {
                        let error = NSError(
                            domain: "AppErrorDomain",
                            code: -1,
                            userInfo: [
                                NSLocalizedDescriptionKey: "Unable to retrieve packages count from snapshot of template \(templateDocument)"
                            ]
                        )
                        errorPointer?.pointee = error
                        return nil
                    }
                    newCountPackagesUsedTemplate = oldCountPackages + 1
                    transaction.updateData(["count.packages": newCountPackagesUsedTemplate!], forDocument: templateDocumentRef!)
                    // transaction update template owner's activity
                    let templateUsageTransaction: [String: Any] = [
                        "date": Date(),
                        "object_reference": templateDocumentRef!,
                        "object_type": getStringForObjectTypeEnum(type: .template),
                        "object_name": packageData["headline"]! as! String,
                        "type": getStringForActivityTypeEnum(type: .templateUsage),
                        "actor_name": Auth.auth().currentUser!.displayName!,
                        "actor_pic": Auth.auth().currentUser!.photoURL?.absoluteString ?? "",
                        "actor_reference": userReference,
                        "amount": 10
                    ]
                    transaction.setData(templateUsageTransaction, forDocument: ((packageData["template_by"] as! [String: Any])["reference"] as! DocumentReference).collection("account_activities").document())
                    transaction.updateData(["private_profile.time_bank_balance": newBalance], forDocument: userReference)
                }

            }
            let packageCreationTransaction: [String: Any] = [
                "date": Date(),
                "object_reference": newPackageRef!,
                "object_type": getStringForObjectTypeEnum(type: .package),
                "object_name": packageData["headline"]! as! String,
                "type": getStringForActivityTypeEnum(type: .packageCreation),
                "actor_name": Auth.auth().currentUser!.displayName!,
                "actor_pic": Auth.auth().currentUser!.photoURL?.absoluteString ?? "",
                "actor_reference": userReference,
                "amount": -100
            ]
            transaction.setData(packageCreationTransaction, forDocument: userReference.collection("account_activities").document())

            if self.externalActions != nil {
                for action in self.externalActions! {
                    let actionData = [
                        "description": action.description!,
                        "web_link": action.webLink!,
                        "type": getStringForExternalAction(type: action.type!)
                    ]
                     transaction.setData(actionData, forDocument: newPackageRef!.collection("external_actions").document())
                }
            }
            transaction.setData(packageData, forDocument: newPackageRef!)
            transaction.updateData(["private_profile.current_package": newPackageRef!, "private_profile.time_bank_balance": self.userDoc!.privateProfile.timeBankBalance - 100], forDocument: userReference)
            transaction.setData(
                [
                    "author_reference": userReference,
                    "pickup": [
                        "geo_point": GeoPoint(latitude: LocationManager.shared.location!.coordinate.latitude, longitude: LocationManager.shared.location!.coordinate.longitude),
                        "date": Date()
                    ],
                    ],
                forDocument: newPackageRef!.collection("transit_records").document(userReference.documentID)
            )
            
            transaction.updateData(
                [
                    "count.packages": newCountPackages,
                    "count.templates": newCountTemplates!,

                ],
                forDocument: topicReference
            )
            return nil
        }) { (object, error) in
            if let error = error {
                print("Error saving transaction package with error: \(error)")
                completion(false)
            } else {
                if coverImageUrl != nil {
                    print("package add succeeded")
                    followPackageWithRef(packageReference: newPackageRef!, userReference: db.collection("users").document(Auth.auth().currentUser!.uid), completion: { (success) in
                        if success {
                            // follow success
                            completion(true)
                        } else {
                            // follow failure
                            completion(false)
                            print("follow failure")
                        }
                    })
                } else {
                    let image = self.packageCoverPhotoImage!
                    let metaData = StorageMetadata()
                    metaData.contentType = "image/jpeg"
                    let coverPicImageReference = Storage.storage().reference().child("images/packages/\(newPackageRef!.documentID)/cover_pic.jpeg")
                    coverPicImageReference.putData(UIImageJPEGRepresentation(image, 0.5)!, metadata: metaData, completion: { (meta, error) in
                        if let error = error {
                            print("error: \(error)")
                        } else {
                            coverPicImageReference.downloadURL(completion: { (url, error) in
                                guard let downloadURL = url else {
                                    // Uh-oh, an error occurred!
                                    print(error!)
                                    completion(false)
                                    return
                                }
                                newPackageRef!.updateData(["cover_pic_url": downloadURL.absoluteString], completion: { (error) in
                                    if let error = error {
                                        print(error)
                                        completion(false)
                                    } else {
                                        if makeTemplate {
                                            topicTemplateRef!.updateData(["cover_pic_url": downloadURL.absoluteString], completion: { (error) in
                                                if let error = error {
                                                    print(error)
                                                    completion(false)
                                                } else {
                                                    print("package add succeeded")
                                                    followPackageWithRef(packageReference: newPackageRef!, userReference: db.collection("users").document(Auth.auth().currentUser!.uid), completion: { (success) in
                                                        if success {
                                                            // follow success
                                                            completion(true)
                                                        } else {
                                                            // follow failure
                                                            completion(false)
                                                            print("follow failure")
                                                        }
                                                    })
                                                }
                                        })} else {
                                            print("package add succeeded")
                                            followPackageWithRef(packageReference: newPackageRef!, userReference: db.collection("users").document(Auth.auth().currentUser!.uid), completion: { (success) in
                                                if success {
                                                    // follow success
                                                    completion(true)
                                                } else {
                                                    // follow failure
                                                    completion(false)
                                                    print("follow failure")
                                                }
                                            })
                                        }
                                    }
                                })
                            })
                        }
                    })
                }
            }
        }
    }

}
