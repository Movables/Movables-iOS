//
//  Structs.swift
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

struct UserDocument {
    var publicProfile: UserPublicProfile
    var privateProfile: UserPrivateProfile
    var reference: DocumentReference
    
    init(with dict:[String: Any], reference: DocumentReference) {
        self.publicProfile = UserPublicProfile(with: dict["public_profile"] as! [String: Any])
        self.privateProfile = UserPrivateProfile(with: dict["private_profile"] as! [String: Any])
        self.reference = reference
    }
}

struct UserPublicProfile {
    var count: UserPublicCount
    var createdDate: Date
    var displayName: String
    var picUrl: String?
    var uid: String
    
    init(with dict:[String: Any]) {
        self.count = UserPublicCount(with: dict["count"] as! [String: Int])
        self.createdDate = (dict["created_date"] as! Timestamp).dateValue()
        self.displayName = dict["display_name"] as! String
        self.picUrl = dict["pic_url"] as? String
        self.uid = dict["uid"] as! String
    }
}

struct UserPublicCount {
    var packagesFollowing: Int
    var packagesMoved: Int
    
    init(with dict:[String: Int]) {
        self.packagesFollowing = dict["packages_following"]!
        self.packagesMoved = dict["packages_moved"]!
    }
}

struct UserPrivateProfile {
    var pointsBalance: CGFloat
    var currentPackage: DocumentReference?
    var interests: [PackageCategory]
    
    init(with dict: [String: Any]) {
        self.pointsBalance = dict["points_balance"] as! CGFloat
        self.currentPackage = dict["current_package"] as? DocumentReference
        self.interests = []
        if let interestDict = dict["interests"] as? [String: Bool] {
            for entry in interestDict {
                if entry.value {
                    self.interests.append(getCategoryEnum(with: entry.key))
                }
            }
        }
    }
}

struct TopicResultItem {
    var name: String
    var objectID: String
    init(with dict:[String: Any]) {
        self.name = dict["name"] as! String
        self.objectID = dict["objectID"] as! String
    }
}

struct Topic {
    var count: TopicCount
    var name: String
    var description: String?
    var reference: DocumentReference
    
    init(with dict: [String: Any], reference: DocumentReference) {
        self.count = TopicCount(with: dict["count"] as! [String: Int])
        self.name = dict["name"] as! String
        self.description = dict["description"] as? String
        self.reference = reference
    }
    
}

struct TopicCount {
    var packages: Int
    var templates: Int
    
    init(with dict: [String: Int]) {
        self.packages = dict["packages"]!
        self.templates = dict["templates"]!
    }
}

struct AccountActivity {
    var actorName: String
    var actorPic: String?
    var actorReference: DocumentReference
    var amount: Int
    var date: Date
    var objectName: String
    var objectReference: DocumentReference
    var objectType: ObjectType
    var type: ActivityType
    
    init(with dict: [String: Any]) {
        self.actorName = dict["actor_name"] as! String
        self.actorPic = dict["actor_pic"] as? String
        self.actorReference = dict["actor_reference"] as! DocumentReference
        self.amount = dict["amount"] as! Int
        self.date = (dict["date"] as! Timestamp).dateValue()
        self.objectName = dict["object_name"] as! String
        self.objectReference = dict["object_reference"] as! DocumentReference
        self.objectType = getEnumForObjectTypeString(string: dict["object_type"] as! String)
        self.type = getEnumForActivityTypeString(string: dict["type"] as! String)
    }
}

func generateLabelTextForAccountActivity(accountActivity: AccountActivity) -> String {
    switch accountActivity.type {
    case .packageCreation:
        return String(format: NSLocalizedString("copy.accountActivity.packageCreation", comment: "label text for package creation account activity"), accountActivity.objectName)
    case .packageDelivery:
        return String(format: NSLocalizedString("copy.accountActivity.packageDelivery", comment: "label text for package delivery account activity"), accountActivity.objectName)
    case .packageDropoff:
        return String(format: NSLocalizedString("copy.accountActivity.packageDropoff", comment: "label text for package dropoff account activity"), accountActivity.objectName)
    case .templateUsage:
        return String(format: NSLocalizedString("copy.accountActivity.templateUsage", comment: "label text for template usage account activity"), accountActivity.objectName)
    case .templateCreation:
        return String(format: NSLocalizedString("copy.accountActivity.templateCreation", comment: "label text for template creation account activity"), accountActivity.objectName)
    default:
        return "unkwown activity"
    }
}

func generateLabelTextForPublicActivity(publicActivity: PublicActivity) -> String {
    switch publicActivity.type {
    case .packagePickup:
        return String(format: NSLocalizedString("copy.publicActivity.packagePickup", comment: "label text for package pickup public activity"), publicActivity.actorName, publicActivity.objectName)
    case .packageDelivery:
        return String(format: NSLocalizedString("copy.publicActivity.packageDelivery", comment: "label text for package delivery public activity"), publicActivity.actorName, publicActivity.objectName)
    case .packageDropoff:
        return String(format: NSLocalizedString("copy.publicActivity.packageDropoff", comment: "label text for package dropoff public activity"), publicActivity.actorName, publicActivity.objectName)
    case .packageCreation:
        return String(format: NSLocalizedString("copy.publicActivity.packageCreation", comment: "label text for package creation public activity"), publicActivity.actorName, publicActivity.objectName)
    default:
        return "unkwown activity"
    }
}


struct PublicActivity {
    var actorName: String
    var actorPic: String?
    var actorReference: DocumentReference
    var date: Date
    var objectName: String
    var objectReference: DocumentReference
    var objectType: ObjectType
    var secondaryObjectName: String?
    var secondaryObjectReference: DocumentReference?
    var secondaryObjectType: ObjectType?
    var type: ActivityType
    var followers: [String: Double]?
    var supplements: [String: Any]?
    var supplementsType: ActivitySupplementsType?
    
    init(with dict: [String: Any]) {
        self.actorName = dict["actor_name"] as! String
        self.actorPic = dict["actor_pic"] as? String
        self.actorReference = dict["actor_reference"] as! DocumentReference
        self.date = (dict["date"] as! Timestamp).dateValue()
        self.objectName = dict["object_name"] as! String
        self.objectReference = dict["object_reference"] as! DocumentReference
        self.objectType = getEnumForObjectTypeString(string: dict["object_type"] as! String)
        self.secondaryObjectName = dict["secondary_object_name"] as? String
        self.secondaryObjectReference = dict["secondary_object_reference"] as? DocumentReference
        self.secondaryObjectType = dict["secondary_object_type"] != nil ? getEnumForObjectTypeString(string: dict["secondary_object_type"] as! String) : nil
        self.type = getEnumForActivityTypeString(string: dict["type"] as! String)
        self.followers = dict["followers"] as? [String: Double]
        if let supplementsTypeString = dict["supplements_type"] as? String {
            self.supplementsType = getEnumForActivitySupplementsTypeString(string: supplementsTypeString)
        }
        self.supplements = dict["supplements"] as? [String:Any]
    }
    
}

enum CommunityType {
    case package
    case location
    case group
}

func getStringForCommunityType(type: CommunityType) -> String {
    switch type {
    case .location:
        return String(NSLocalizedString("label.conversationTypeLocal", comment: "label text for local conversation"))
    case .package:
        return String(NSLocalizedString("label.conversationTypePackage", comment: "label text for package conversation"))
    default:
        return String(NSLocalizedString("label.conversationTypePrivate", comment: "label text for private conversation"))
    }
}

func getDescriptionForCommunityType(type: CommunityType) -> String {
    switch type {
    case .location:
        return String(NSLocalizedString("label.conversationTypeLocalDesc", comment: "label text for conversation type local description"))
    case .package:
        return String(NSLocalizedString("label.conversationTypePackageDesc", comment: "label text for conversation type package description"))
    default:
        return String(NSLocalizedString("label.conversationTypePrivateDesc", comment: "label text for conversation type private description"))
    }
}

struct Community {
    var name: String
    var type: CommunityType
    var reference: DocumentReference
    
    init(name: String, type: CommunityType, reference: DocumentReference) {
        self.name = name
        self.type = type
        self.reference = reference
    }
}


enum SortBy {
    case distance
    case followers
    case movers
    case dueDate
    case unknown
}

let sortByStringArray = ["Distance", "Followers", "Movers", "Due date"]

func getStringForSortEnum(sortEnum: SortBy) -> String {
    switch sortEnum {
    case .distance:
        return "Distance"
    case .followers:
        return "Followers"
    case .movers:
        return "Movers"
    case .dueDate:
        return "Due date"
    default:
        return "Unknown"
    }
}

func getEnumForSortString(sortString: String) -> SortBy {
    switch sortString {
    case "Distance":
        return .distance
    case "Followers":
        return .followers
    case "Movers":
        return .movers
    case "Due date":
        return .dueDate
    default:
        return .unknown
    }
}

let statusStringArray = ["Pending Pickup", "In Transit", "Delivered"]

enum PackageStatus {
    case draft
    case pending
    case transit
    case delivered
    case unknown
}

func getReadableForStatusEnum(statusEnum: PackageStatus) -> String {
    switch statusEnum {
    case .pending:
        return String(NSLocalizedString("button.pending", comment: "button title for pending pickup"))
    case .transit:
        return String(NSLocalizedString("button.inTransit", comment: "button title for in transit"))
    case .delivered:
        return String(NSLocalizedString("button.delivered", comment: "button title for delivered"))
    case .draft:
        return "Draft"
    default:
        return "Unknown"
    }
}

func getStringForStatusEnum(statusEnum: PackageStatus) -> String {
    switch statusEnum {
    case .pending:
        return "pending"
    case .transit:
        return "transit"
    case .delivered:
        return "delivered"
    case .draft:
        return "draft"
    default:
        return "unknown"
    }
}

enum RecipientType {
    case politician
    case politicalParty
    case corporation
    case individual
}

func getStringForRecipientTypeEnum(recipientTypeEnum: RecipientType) -> String {
    switch recipientTypeEnum {
    case .politician:
        return "politician"
    case .politicalParty:
        return "political_party"
    case .corporation:
        return "corporation"
    case .individual:
        return "individual"
    }
}



func getEnumForStatusReadable(readableString: String) -> PackageStatus {
    switch readableString {
    case "Pending Pickup":
        return .pending
    case "In Transit":
        return .transit
    case "Delivered":
        return .delivered
    case "Draft":
        return .draft
    default:
        return .unknown
    }
}
