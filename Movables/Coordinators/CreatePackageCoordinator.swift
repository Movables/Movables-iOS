//
//  CreatePackageCoordinator.swift
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
import UIKit
import SafariServices
import CoreLocation

class CreatePackageCoordinator: Coordinator {
    let rootViewController: UIViewController
    let topicSearchVC: CreatePackageTopicSearchViewController
    let navigationController: UINavigationController
    var packageDraft: Package?
    var category: PackageCategory?
    var topicResultItem: PackageTopicResultItem?
    var recipientResultItem: RecipientResultItem?
    var destinationResultItem: DestinationResultItem?
    var packageCoverPhotoImage: UIImage?
    var packageDueDate: Date?
    var packageHeadline: String?
    var packageDescription: String?
    var shouldSaveAsTemplate: Bool?
    var usingTemplate: Bool = false
    var template: PackageTemplate?
    var externalActions: [ExternalAction]?
    var dropoffMessage: String?
    var coverImageUrl: String?
    
    init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
        self.topicSearchVC = CreatePackageTopicSearchViewController()
        self.navigationController = UINavigationController(rootViewController: self.topicSearchVC)
        LocationManager.shared.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    }
    
    func start() {
        self.topicSearchVC.createPackageCoordinator = self
        rootViewController.present(self.navigationController, animated: true) {
            print("presented topicSearchVC")
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
        safariVC.preferredControlTintColor = getTintForCategory(category: category!)
        navigationController.present(safariVC, animated: true, completion: nil)
    }
    
    func setContentAndPushToReview(promptTemplate: Bool, coverImageUrl: URL?) {
        if promptTemplate {
            let alertController = UIAlertController(title: String(NSLocalizedString("copy.alert.packageTemplates", comment: "alert title for package templates")), message: String(format: NSLocalizedString("copy.alert.packageTemplateDesc", comment: "alert body label for package templates"), self.topicResultItem!.name), preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: String(NSLocalizedString("button.createTemplate", comment: "button title for create template")), style: .default, handler: { (action) in
                self.shouldSaveAsTemplate = true
                self.pushToReview(coverImageUrl: coverImageUrl)
            }))
            alertController.addAction(UIAlertAction(title: String(NSLocalizedString("button.dontCreateTemplate", comment: "button title for dont create template")), style: .default, handler: { (action) in
                self.shouldSaveAsTemplate = false
                self.pushToReview(coverImageUrl: coverImageUrl)
            }))
            alertController.addAction(UIAlertAction(title: "button.cancel", style: .cancel, handler: { (action) in
                self.shouldSaveAsTemplate = nil
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
        
        LocationManager.shared.requestLocation()
        
        if coverImageUrl != nil {
            reviewVC.coverImageUrl = coverImageUrl!
        } else {
            reviewVC.coverImage = packageCoverPhotoImage
        }
        reviewVC.sender = Person(displayName: UserManager.shared.userDocument!.publicProfile.displayName, photoUrl: UserManager.shared.userDocument!.publicProfile.picUrl, reference: UserManager.shared.userDocument?.reference, twitter: nil, facebook: nil, phone: nil, isEligibleToReceive: nil, recipientType: nil)
        reviewVC.recipient = Person(displayName: recipientResultItem!.name, photoUrl: recipientResultItem!.picUrl ?? "", reference: Firestore.firestore().collection("recipients").document(recipientResultItem!.documentID), twitter: recipientResultItem!.twitter, facebook: recipientResultItem!.facebook, phone: recipientResultItem!.phone, isEligibleToReceive: recipientResultItem!.type != nil, recipientType: recipientResultItem!.type)
        reviewVC.packageHeadline = packageHeadline
        reviewVC.packageTopicName = topicResultItem?.name ?? ""
        reviewVC.packageDescription = packageDescription ?? ""
        reviewVC.originCoordinate = LocationManager.shared.location?.coordinate
        reviewVC.destinationCoordinate = destinationResultItem?.placemark.coordinate
        reviewVC.packageDueDate = packageDueDate
        reviewVC.category = category
        reviewVC.createPackageCoordinator = self
        self.navigationController.pushViewController(reviewVC, animated: true)
    }
    
    func beginSavingPackage(completion: @escaping (Bool) -> ()) {
        if UserManager.shared.userDocument != nil {
            let alertController = UIAlertController(title: String(NSLocalizedString("copy.alert.packageCreation", comment: "alert title for package creation")), message: String(format: NSLocalizedString("copy.alert.packageCreationDesc", comment: "alert body for packageCreation"), Int(UserManager.shared.userDocument!.privateProfile.pointsBalance - 100)), preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: String(NSLocalizedString("button.ok", comment: "button title for ok")), style: .default, handler: { (action) in
                print("confirmed creation")
                self.savePackage(packageContent: self.createPackageContent(), packageLogistics: self.createPackageLogistics(), packageRelations: self.createPackageRelations(), completion: { success in
                    completion(success)
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
    }
    
    func createPackageContent() -> [String: Any] {
        var packageContent: [String: Any] = [:]
        
        packageContent["category"] = getStringForCategory(category: category!)
        
        packageContent["description"] = packageDescription!
        
        packageContent["destination"] = [
            "address": destinationResultItem!.placemark.postalAddress != nil &&
                !destinationResultItem!.placemark.postalAddress!.street.isEmpty &&
                !destinationResultItem!.placemark.postalAddress!.subAdministrativeArea.isEmpty ?
                    "\(destinationResultItem!.placemark.postalAddress!.street), \(destinationResultItem!.placemark.postalAddress!.subAdministrativeArea)" :
                    "\(destinationResultItem!.placemark.location!.coordinate.longitude), \(destinationResultItem!.placemark.location!.coordinate.latitude)",
            "geo_point": GeoPoint(
                latitude: destinationResultItem!.placemark.coordinate.latitude,
                longitude: destinationResultItem!.placemark.coordinate.longitude),
            "name": destinationResultItem!.name ?? ""
        ]
        
        packageContent["dropoff_message"] = dropoffMessage
        
        packageContent["due_date"] = packageDueDate!
        
        var externalActions:[[String: Any]] = []
        if self.externalActions != nil {
            for action in self.externalActions! {
                let actionData = [
                    "description": action.description!,
                    "web_link": action.webLink!,
                    "type": getStringForExternalAction(type: action.type!)
                ]
                externalActions.append(actionData)
            }
        }
        packageContent["external_actions"] = externalActions

        packageContent["headline"] = packageHeadline!
        
        packageContent["recipient"] = [
            "name": recipientResultItem!.name,
            "phone": recipientResultItem!.phone as Any,
            "pic_url": recipientResultItem!.picUrl ?? "",
            "twitter": recipientResultItem!.twitter as Any,
            "facebook": recipientResultItem!.facebook as Any,
            "reference": Firestore.firestore().collection("recipient").document(recipientResultItem!.documentID),
            "type": getStringForRecipientTypeEnum(recipientTypeEnum: .politician)
        ]
        
        packageContent["topic"] = [
            "name": topicResultItem!.name,
            "reference": Firestore.firestore().collection("topics").document(topicResultItem!.documentID),
        ]
        
        return packageContent
    }
    
    func createPackageLogistics() -> [String: Any] {
        var packageLogistics: [String: Any] = [:]
        
        LocationManager.shared.requestLocation()
        let currentLocation = LocationManager.shared.location
        let currentGeoPoint = GeoPoint(latitude: currentLocation!.coordinate.latitude, longitude: currentLocation!.coordinate.longitude)
        packageLogistics["current_location"] = currentGeoPoint
        
        packageLogistics["created_date"] = Date()
        
        packageLogistics["in_transit_by"] = [
            "name": UserManager.shared.userDocument!.publicProfile.displayName,
            "pic_url": UserManager.shared.userDocument!.publicProfile.picUrl ?? "",
            "reference": UserManager.shared.userDocument!.reference
        ]
        
        packageLogistics["status"] = getStringForStatusEnum(statusEnum: .transit)
        
        packageLogistics["origin"] = [
            "address": "",
            "geo_point": currentGeoPoint,
            "name": "",
        ]
        
        packageLogistics["author"] = [
            "name": UserManager.shared.userDocument!.publicProfile.displayName,
            "pic_url": UserManager.shared.userDocument!.publicProfile.picUrl ?? "",
            "reference": UserManager.shared.userDocument!.reference
        ]
        
        if usingTemplate {
            packageLogistics["content_template_by"] = [
                "name": self.template!.author?.displayName ?? "",
                "pic_url": self.template!.author?.photoUrl ?? "",
                "reference": self.template!.author?.reference as Any
            ]
        }
        
        return packageLogistics
    }
    
    func createPackageRelations() -> [String: Any] {
        var packageRelations: [String: Any] = [:]
        
        packageRelations["count"] = ["followers": 0, "movers": 0]
        packageRelations["followers"] = [ UserManager.shared.userDocument!.reference.documentID: Date().timeIntervalSince1970 ]
        
        return packageRelations
    }
    
    func savePackage(packageContent: [String: Any], packageLogistics: [String: Any], packageRelations: [String: Any], completion: @escaping (Bool) -> ()) {
        
        let packageReference = Firestore.firestore().collection("packages").document()
        
        var topic: [String: Any]?
        var topicReference: DocumentReference?
        
        if topicResultItem!.packagesCount == nil {
            // create new topic
            topicReference = (packageContent["topic"] as! [String: Any])["reference"] as? DocumentReference
            topic = [
                "name": topicResultItem!.name,
                "description": "",
                "count": [
                    "templates": shouldSaveAsTemplate! ? 1 : 0,
                    "packages": 1,
                ],
            ]
        }
        
        var topicTemplateRef: DocumentReference?
        var topicTemplate: [String: Any]?
        if shouldSaveAsTemplate! {
            topicTemplateRef = ((packageContent["topic"] as! [String : Any])["reference"] as! DocumentReference).collection("templates").document()
            topicTemplate = packageContent
            topicTemplate!["author"] = packageLogistics["author"]
            topicTemplate!["count"] = ["packages": 0]
            
            // save topic Template at topicTemplateRef with transaction
        }
        
        if usingTemplate {
            topicTemplateRef = template?.reference
        }
        
        var content = packageContent
        if coverImageUrl != nil {
            content["cover_pic_url"] = coverImageUrl
            if topicTemplate != nil {
                topicTemplate!["cover_pic_url"] = coverImageUrl
            }
            let package = [
                "content": content,
                "logistics": packageLogistics,
                "relations": packageRelations,
                ]
            self.runPackageSaveTransaction(with: package, packageReference: packageReference, topic: topic, topicReference: topicReference, topicTemplate: topicTemplate, topicTemplateReference: topicTemplateRef, completion: { (success) in
                if success {
                    print("save success")
                    completion(true)
                } else {
                    print("save failure")
                    completion(false)
                }
            })
        } else {
            let image = self.packageCoverPhotoImage!
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpeg"
            let coverPicImageReference = Storage.storage().reference().child("images/packages/\(packageReference.documentID)/cover_pic.jpeg")
            coverPicImageReference.putData(UIImageJPEGRepresentation(image, 0.5)!, metadata: metaData, completion: { (meta, error) in
                if let error = error {
                    print("error: \(error)")
                    completion(false)
                } else {
                    coverPicImageReference.downloadURL(completion: { (url, error) in
                        guard let downloadURL = url else {
                            // Uh-oh, an error occurred!
                            print(error!)
                            completion(false)
                            return
                        }
                        content["cover_pic_url"] = downloadURL.absoluteString
                        if topicTemplate != nil {
                            topicTemplate!["cover_pic_url"] = downloadURL.absoluteString
                        }
                        let package = [
                            "content": content,
                            "logistics": packageLogistics,
                            "relations": packageRelations,
                        ]
                        self.runPackageSaveTransaction(with: package, packageReference: packageReference, topic: topic, topicReference: topicReference, topicTemplate: topicTemplate, topicTemplateReference: topicTemplateRef, completion: { (success) in
                            if success {
                                print("save success")
                                completion(true)
                            } else {
                                print("save failure")
                                completion(false)
                            }
                        })
                    })
                }
            })

        }
        
    }
    
    func runPackageSaveTransaction(with package: [String: Any], packageReference: DocumentReference, topic: [String: Any]?, topicReference: DocumentReference?, topicTemplate: [String: Any]?, topicTemplateReference: DocumentReference?, completion: @escaping (Bool) -> ()) {
        
        print("run package save transaction")
        
        let db = Firestore.firestore()
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let authorReference = UserManager.shared.userDocument!.reference
            let authorDocument: DocumentSnapshot?
            do {
                try authorDocument = transaction.getDocument(authorReference)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            let topicDocument: DocumentSnapshot?
            
            // increment packages count on the template
            do {
                try topicDocument = transaction.getDocument(((package["content"] as! [String: Any])["topic"] as! [String: Any])["reference"] as! DocumentReference)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }

            var oldAuthorBalance = (authorDocument!.data()!["private_profile"] as! [String: Any])["points_balance"] as! Int

            let topicTemplateDocument: DocumentSnapshot?
            
            if topicTemplate != nil {
                // if the author is creating a template
                
                // credit author's balance with 10 credits
                oldAuthorBalance = oldAuthorBalance + 10
                
                // record a template creation account activity for author
                let templateCreationAccountActivity: [String: Any] = [
                    "date": Date(),
                    "object_reference": topicTemplateReference!,
                    "object_type": getStringForObjectTypeEnum(type: .topic),
                    "object_name": (topicTemplate!["topic"] as! [String : Any])["name"] as! String,
                    "type": getStringForActivityTypeEnum(type: .templateCreation),
                    "actor_name": UserManager.shared.userDocument!.publicProfile.displayName,
                    "actor_pic": UserManager.shared.userDocument!.publicProfile.picUrl ?? "",
                    "actor_reference": authorReference,
                    "amount": 10
                ]
                transaction.setData(templateCreationAccountActivity, forDocument: authorReference.collection("account_activities").document())
                
                // save topic template
                transaction.setData(topicTemplate!, forDocument: topicTemplateReference!)
            } else {
                do {
                    try topicTemplateDocument = transaction.getDocument(topicTemplateReference!)
                } catch let fetchError as NSError {
                    errorPointer?.pointee = fetchError
                    return nil
                }
                let oldCountPackagesOnTopicTemplate = (topicTemplateDocument?.data()!["count"] as! [String: Int])["packages"]!
                let newCountPackagesOnTopicTemplate = oldCountPackagesOnTopicTemplate + 1
                transaction.updateData(["count.packages": newCountPackagesOnTopicTemplate], forDocument: topicTemplateReference!)
            }

            
            if self.usingTemplate {
                // if the author is using a template
                let templateAuthorReference = ((package["logistics"] as! [String: Any])["content_template_by"] as! [String: Any])["reference"] as! DocumentReference
                let templateAuthorDocument: DocumentSnapshot?
                if templateAuthorReference != authorReference {
                    do {
                        try templateAuthorDocument = transaction.getDocument(templateAuthorReference)
                    } catch let fetchError as NSError {
                        errorPointer?.pointee = fetchError
                        return nil
                    }
                } else {
                    templateAuthorDocument = authorDocument
                }
                let oldTemplateAuthorBalance = (templateAuthorDocument!.data()!["private_profile"] as! [String: Any])["points_balance"] as! Int
                
                // credit template author's balance with 10 credits
                transaction.updateData(["private_profile.points_balance": oldTemplateAuthorBalance + 10], forDocument: templateAuthorReference)
                
                // record a template usage account activity for template author
                let templateUsageTransaction: [String: Any] = [
                    "date": Date(),
                    "object_reference": topicTemplateReference!,
                    "object_type": getStringForObjectTypeEnum(type: .template),
                    "object_name": (package["content"] as! [String: Any])["headline"] as! String,
                    "type": getStringForActivityTypeEnum(type: .templateUsage),
                    "actor_name": UserManager.shared.userDocument!.publicProfile.displayName,
                    "actor_pic": UserManager.shared.userDocument!.publicProfile.picUrl ?? "",
                    "actor_reference": UserManager.shared.userDocument!.reference,
                    "amount": 10
                ]
                transaction.setData(templateUsageTransaction, forDocument: templateAuthorReference.collection("account_activities").document())
                
                let oldTopicPackagesCount = (topicDocument!.data()!["count"] as! [String: Any])["packages"] as! Int
                transaction.updateData(["count.packages": oldTopicPackagesCount + 1], forDocument: topicDocument!.reference)
            }
            
            if topic != nil {
                // if the author is creating a new topic
                // save topic
                transaction.setData(topic!, forDocument: topicReference!)
            }
            
            
            // record packageCreation account activity
            let packageCreationTransaction: [String: Any] = [
                "date": Date(),
                "object_reference": packageReference,
                "object_type": getStringForObjectTypeEnum(type: .package),
                "object_name": (package["content"] as! [String: Any])["headline"]! as! String,
                "type": getStringForActivityTypeEnum(type: .packageCreation),
                "actor_name": UserManager.shared.userDocument!.publicProfile.displayName,
                "actor_pic": UserManager.shared.userDocument!.publicProfile.picUrl ?? "",
                "actor_reference": authorReference,
                "amount": -100
            ]
            transaction.setData(packageCreationTransaction, forDocument: authorReference.collection("account_activities").document())
            
            transaction.setData(
                [
                    "author_reference": authorReference,
                    "pickup": [
                        "geo_point": GeoPoint(latitude: LocationManager.shared.location!.coordinate.latitude, longitude: LocationManager.shared.location!.coordinate.longitude),
                        "date": Date()
                    ],
                ],
                forDocument: packageReference.collection("transit_records").document(authorReference.documentID)
            )
            
            // save package
            transaction.setData(package, forDocument: packageReference)
            
            // update current_package in private_profile of the author
            transaction.updateData(["private_profile.current_package": packageReference, "private_profile.points_balance": oldAuthorBalance - 100], forDocument: authorReference)
            
            return nil
        }) { (object, error) in
            if let error = error {
                print("Error saving transaction package with error: \(error)")
                completion(false)
            } else {
                completion(true)
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

}
