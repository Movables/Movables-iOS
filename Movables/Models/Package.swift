//
//  Package.swift
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
import CoreLocation
import Firebase

let ACTIONABLE_DISTANCE = 100.0
let TOO_FAR_DISTANCE = 50000.0

enum ObjectType {
    case template
    case package
    case user
    case topic
    case unknown
}

enum ActivityType {
    case packageDropoff
    case packageDelivery
    case packagePickup
    case packageCreation
    case templateCreation
    case templateUsage
    case unknown
}

enum ActivitySupplementsType {
    case pickup
    case dropoff
    case delivery
    case unknown
}

func getStringForObjectTypeEnum(type: ObjectType) -> String {
    switch type {
    case .package:
        return "package"
    case .user:
        return "user"
    case .topic:
        return "topic"
    case .template:
        return "template"
    default:
        return "unknown"
    }
}

func getEnumForObjectTypeString(string: String) -> ObjectType {
    switch string {
    case "template":
        return .template
    case "package":
        return .package
    case "topic":
        return .topic
    case "user":
        return .user
    default:
        return .unknown
    }
}

func getStringForActivitySupplementsType(type: ActivitySupplementsType) -> String {
    switch type {
    case .delivery:
        return "delivery"
    case .pickup:
        return "pickup"
    case .dropoff:
        return "dropoff"
    default:
        return "unknown"
    }
}

func getEnumForActivitySupplementsTypeString(string: String) -> ActivitySupplementsType {
    switch string {
    case "delivery":
        return .delivery
    case "pickup":
        return .pickup
    case "dropoff":
        return .dropoff
    default:
        return .unknown
    }
}

func getStringForActivityTypeEnum(type: ActivityType) -> String {
    switch type {
    case .packageCreation:
        return "package_creation"
    case .packagePickup:
        return "package_pickup"
    case .packageDropoff:
        return "package_dropoff"
    case .packageDelivery:
        return "package_delivery"
    case .templateCreation:
        return "template_creation"
    case .templateUsage:
        return "template_usage"
    default:
        return "unknown"
    }
}

func getEnumForActivityTypeString(string: String) -> ActivityType {
    switch string {
    case "package_creation":
        return .packageCreation
    case "package_pickup":
        return .packagePickup
    case "package_dropoff":
        return .packageDropoff
    case "package_delivery":
        return .packageDelivery
    case "template_creation":
        return .templateCreation
    case "template_usage":
        return .templateUsage
    default:
        return .unknown
    }
}


enum DropoffError: Error {
    case DropoffLocationNotCloserThanPickupLocation
}

struct TemplateCount: Equatable {
    var packages: Int?
    
    init(dict: [String: Int]) {
        self.packages = dict["packages"]
    }
}

struct PackageTemplate {
    var category: PackageCategory
    var count: TemplateCount?
    var coverImageUrl: String?
    var description: String
    var destination: Location
    var headline: String
    var recipient: Person
    var topic: Topic
    var author: Person?
    var reference: DocumentReference
    var dueDate: Date
    var dropoffMessage: String?
    var externalActions: [ExternalAction]?
    
    init(snapshot: DocumentSnapshot) {
        let dictionary = snapshot.data()!
        
        self.category = getCategoryEnum(with: dictionary["category"] as! String)
        
        if let countDict = dictionary["count"] as? [String: Int] {
            self.count = TemplateCount(dict: countDict)
        } else {
            self.count = nil
        }
        
        self.coverImageUrl = dictionary["cover_pic_url"] as? String
        
        self.description = dictionary["description"] as! String
        
        self.destination = Location(dict: dictionary["destination"] as! [String: Any])
        
        self.headline = dictionary["headline"] as! String
        
        self.recipient = Person(dict: dictionary["recipient"] as! [String: Any])
                
        self.topic = Topic(with: dictionary["topic"] as! [String: Any], reference: (dictionary["topic"] as! [String: Any])["reference"] as! DocumentReference)
        
        if let authorDict = dictionary["author"] as? [String: Any] {
            self.author = Person(dict: authorDict)
        } else {
            self.author = nil
        }
        
        self.reference = snapshot.reference
        
        self.dueDate = (dictionary["due_date"] as! Timestamp).dateValue()
        
        self.dropoffMessage = dictionary["dropoff_message"] as? String
        
        if let externalActions = dictionary["external_actions"] as? [[String: Any]] {
            self.externalActions = []
            for action in externalActions {
                self.externalActions?.append(ExternalAction(dict: action))
            }
        }
    }
}

struct Package: Equatable {
    var sender: Person
    var category: PackageCategory
    var count: PackageCount?
    var coverImageUrl: String?
    var description: String
    var destination: Location
    var headline: String
    var inTransitBy: Person?
    var origin: Location
    var recipient: Person
    var status: PackageStatus
    var topic: Topic
    var contentTemplateBy: Person?
    var transitRecords: [TransitRecord]?
    var externalActions: [ExternalAction]?
    var reference: DocumentReference
    var currentLocation: CLLocation
    var dueDate: Date
    var dropoffMessage: String?
    var followers: [String: Date]?
    
    init(sender: Person, category: PackageCategory, count: PackageCount?, coverImageUrl: String?, description: String, destination: Location, headline: String, inTransitBy: Person?, origin: Location, recipient: Person, status: PackageStatus, topic: Topic, contentTemplateBy: Person?, transitRecords: [TransitRecord]?, reference: DocumentReference, currentLocation: CLLocation, dueDate: Date) {
        self.sender = sender
        self.category = category
        self.count = count
        self.coverImageUrl = coverImageUrl
        self.description = description
        self.destination = destination
        self.headline = headline
        self.inTransitBy = inTransitBy
        self.origin = origin
        self.recipient = recipient
        self.status = status
        self.topic = topic
        self.contentTemplateBy = contentTemplateBy
        self.transitRecords = transitRecords
        self.reference = reference
        self.currentLocation = currentLocation
        self.dueDate = dueDate
    }
    
    init(snapshot: DocumentSnapshot) {
        let dictionary = snapshot.data()!
        let content = dictionary["content"] as! [String: Any]
        let logistics = dictionary["logistics"] as! [String: Any]
        let relations = dictionary["relations"] as! [String: Any]
        
        self.sender = Person(dict: logistics["author"] as! [String: Any])
        self.category = getCategoryEnum(with: content["category"] as! String)
        
        if let countDict = relations["count"] as? [String: Int] {
            self.count = PackageCount(dict: countDict)
        } else {
            self.count = nil
        }
        
        self.coverImageUrl = content["cover_pic_url"] as? String
        
        self.description = content["description"] as! String
        
        self.destination = Location(dict: content["destination"] as! [String: Any])
        
        self.headline = content["headline"] as! String
        
        if let inTransitByDict = logistics["in_transit_by"] as? [String: Any] {
            self.inTransitBy = Person(dict: inTransitByDict)
        } else {
            self.inTransitBy = nil
        }
        
        self.origin = Location(dict: logistics["origin"] as! [String: Any])
        
        self.recipient = Person(dict: content["recipient"] as! [String: Any])
        
        self.status = getStatusEnum(with: logistics["status"] as! String)
        
        self.topic = Topic(with: content["topic"] as! [String : Any], reference: (content["topic"] as! [String: Any])["reference"] as! DocumentReference)
        
        if let templateByDict = dictionary["template_by"] as? [String: Any] {
            self.contentTemplateBy = Person(dict: templateByDict)
        } else {
            self.contentTemplateBy = nil
        }

        self.transitRecords = nil
        
        self.reference = snapshot.reference
        
        let currentLocation = logistics["current_location"] as! GeoPoint
        self.currentLocation = CLLocation(
            latitude: currentLocation.latitude,
            longitude: currentLocation.longitude
        )
        
        self.dueDate = (content["due_date"] as! Timestamp).dateValue()
        self.dropoffMessage = content["dropoff_message"] as? String
        if let externalActions = content["external_actions"] as? [[String: Any]] {
            self.externalActions = []
            for action in externalActions {
                self.externalActions?.append(ExternalAction(dict: action))
            }
        }

        self.followers = [:]
        if let followersDict = relations["followers"] as? [String: TimeInterval] {
            for (key, value) in followersDict {
                self.followers!.updateValue(Date(timeIntervalSince1970: value), forKey: key)
            }
        }
    }
    
    init(hit:[String: Any]) {
        let hitContent = hit["content"] as! [String: Any]
        let hitLogistics = hit["logistics"] as! [String: Any]
        let hitRelations = hit["relations"] as! [String: Any]
        
        self.sender = Person(hitPerson: hitLogistics["author"] as! [String: Any])
        self.category = getCategoryEnum(with: hitContent["category"] as! String)
        
        if let countDict = hitRelations["count"] as? [String: Int] {
            self.count = PackageCount(dict: countDict)
        } else {
            self.count = nil
        }
        
        self.coverImageUrl = hitContent["cover_pic_url"] as? String
        
        self.description = hitContent["description"] as! String
        
        self.destination = Location(hitLocation: hitContent["destination"] as! [String: Any])
        
        self.headline = hitContent["headline"] as! String
        
        if let inTransitByDict = hitLogistics["in_transit_by"] as? [String: Any] {
            self.inTransitBy = Person(hitPerson: inTransitByDict)
        } else {
            self.inTransitBy = nil
        }
        
        self.origin = Location(hitLocation: hitLogistics["origin"] as! [String: Any])
        
        self.recipient = Person(hitPerson: hitContent["recipient"] as! [String: Any])
        
        self.status = getStatusEnum(with: hitLogistics["status"] as! String)
        
        self.topic = Topic(hitTopic: hitContent["topic"] as! [String: Any])
        
        if let hitContentTemplateBy = hitLogistics["content_template_by"] as? [String: Any] {
            self.contentTemplateBy = Person(hitPerson: hitContentTemplateBy)
        } else {
            self.contentTemplateBy = nil
        }
        
        self.transitRecords = nil
        
        self.reference = Firestore.firestore().collection("packages").document(hit["objectID"] as! String)
        
        self.currentLocation = CLLocation(
            latitude: (hit["_geoloc"] as! [String: CLLocationDegrees])["lat"]!,
            longitude: (hit["_geoloc"] as! [String: CLLocationDegrees])["lng"]!
        )
        
        self.dueDate = Date(timeIntervalSince1970: (hitContent["due_date"] as! TimeInterval))
        
        self.dropoffMessage = hitContent["dropoff_message"] as? String
        if let externalActions = hitContent["external_actions"] as? [[String: Any]] {
            self.externalActions = []
            for action in externalActions {
                self.externalActions?.append(ExternalAction(dict: action))
            }
        }
        
        self.followers = [:]
        if let followersDict = hitRelations["followers"] as? [String: TimeInterval] {
            for (key, value) in followersDict {
                self.followers!.updateValue(Date(timeIntervalSince1970: value), forKey: key)
            }
        }
    }
    
    static func == (lhs: Package, rhs: Package) -> Bool {
        
        var coverImageUrlEqual: Bool?
        if lhs.coverImageUrl == nil && rhs.coverImageUrl == nil {
            coverImageUrlEqual = true
        } else if lhs.coverImageUrl == nil || rhs.coverImageUrl == nil {
            coverImageUrlEqual = false
        } else {
            coverImageUrlEqual = lhs.coverImageUrl! == rhs.coverImageUrl!
        }
        
        var inTransitByEqual: Bool?
        if lhs.inTransitBy == nil && rhs.inTransitBy == nil {
            inTransitByEqual = true
        } else if lhs.inTransitBy == nil || rhs.inTransitBy == nil {
            inTransitByEqual = false
        } else {
            inTransitByEqual = lhs.inTransitBy! == rhs.inTransitBy!
        }
        
        var contentTemplateByEqual: Bool?
        if lhs.contentTemplateBy == nil && rhs.contentTemplateBy == nil {
            contentTemplateByEqual = true
        } else if lhs.contentTemplateBy == nil || rhs.contentTemplateBy == nil {
            contentTemplateByEqual = false
        } else {
            contentTemplateByEqual = lhs.contentTemplateBy! == rhs.contentTemplateBy!
        }
        
        return (
            lhs.sender == rhs.sender &&
            lhs.category == rhs.category &&
            coverImageUrlEqual! &&
            lhs.description == rhs.description &&
            lhs.destination == rhs.destination &&
            lhs.headline == rhs.headline &&
            inTransitByEqual! &&
            lhs.origin == rhs.origin &&
            lhs.recipient == rhs.recipient &&
            lhs.status == rhs.status &&
            lhs.topic == rhs.topic &&
            contentTemplateByEqual! &&
            lhs.transitRecords == rhs.transitRecords &&
            lhs.reference == rhs.reference &&
            lhs.currentLocation.coordinate.latitude == rhs.currentLocation.coordinate.latitude &&
            lhs.currentLocation.coordinate.longitude == rhs.currentLocation.coordinate.longitude &&
            lhs.dueDate == rhs.dueDate &&
            lhs.followers == rhs.followers
        )
    }
}

struct Person: Equatable {
    var displayName: String
    var photoUrl: String?
    var reference: DocumentReference?
    var twitter: String?
    var facebook: String?
    var phone: String?
    var isEligibleToReceive: Bool?
    var recipientType: RecipientType?
    
    init(displayName: String, photoUrl: String?, reference: DocumentReference?, twitter: String?, facebook: String?, phone: String?, isEligibleToReceive: Bool?, recipientType: RecipientType?) {
        self.displayName = displayName
        self.photoUrl = photoUrl
        self.reference = reference
        self.twitter = twitter
        self.facebook = facebook
        self.phone = phone
        self.isEligibleToReceive = isEligibleToReceive
        self.recipientType = recipientType
    }
    
    init(dict: [String: Any]) {
        self.displayName = dict["name"] as! String
        self.photoUrl = dict["pic_url"] as? String
        self.reference = dict["reference"] as? DocumentReference
        self.twitter = dict["twitter"] as? String
        self.facebook = dict["facebook"] as? String
        self.phone = dict["phone"] as? String
    }
    
    init(hitPerson: [String: Any]) {
        self.displayName = hitPerson["name"] as! String
        self.photoUrl = hitPerson["pic_url"] as? String
        self.reference = Firestore.firestore().collection("users").document(hitPerson["documentID"] as! String)
        self.twitter = hitPerson["twitter"] as? String
        self.facebook = hitPerson["facebook"] as? String
        self.phone = hitPerson["phone"] as? String
        if let recipientTypeString = hitPerson["recipientType"] as? String {
            self.recipientType = getEnumForRecipientTypeString(recipientTypeString: recipientTypeString)
        }
    }
    
    static func == (lhs: Person, rhs: Person) -> Bool {
        return (
            lhs.displayName == rhs.displayName &&
            lhs.photoUrl == rhs.photoUrl &&
            lhs.reference == rhs.reference &&
            lhs.twitter == rhs.twitter &&
            lhs.facebook == rhs.facebook &&
            lhs.phone == rhs.phone
        )
    }
}

struct PackageCount: Equatable {
    var followers: Int?
    var movers: Int?
    
    init(followers: Int?, movers: Int?) {
        self.followers = followers
        self.movers = movers
    }
    
    init(dict: [String: Int]) {
        self.followers = dict["followers"]
        self.movers = dict["movers"]
    }
    
    static func == (lhs: PackageCount, rhs: PackageCount) -> Bool {
        return (
            lhs.followers == rhs.followers &&
            lhs.movers == rhs.movers
        )
    }
}

struct PackageUpdatesCount {
    var total: Int?
    var progressEvents: Int?
    var postsEvents: Int?
    var unreadProgressEvents: Int?
    var unreadPostsEvents: Int?
    
    init(dict: [String: Int]) {
        self.total = dict["unread_progress_events"]! as Int + dict["unread_posts_events"]! as Int
        self.progressEvents = dict["progress_events"]
        self.postsEvents = dict["posts_events"]
        self.unreadProgressEvents = dict["unread_progress_events"]
        self.unreadPostsEvents = dict["unread_posts_events"]
    }
}

struct Location: Equatable{
    var address: String?
    var geoPoint: GeoPoint
    var name: String?
    
    init(address: String?, geoPoint: GeoPoint, name: String?) {
        self.address = address
        self.geoPoint = geoPoint
        self.name = name
    }
    
    init(dict: [String: Any]) {
        self.address = dict["address"] as? String
        self.geoPoint = dict["geo_point"] as! GeoPoint
        self.name = dict["name"] as? String
    }
    
    init(hitLocation: [String: Any]) {
        self.address = hitLocation["address"] as? String
        self.geoPoint = GeoPoint(latitude: (hitLocation["geo_point"] as! [String: Any])["lat"] as! Double, longitude: (hitLocation["geo_point"] as! [String: Any])["lng"] as! Double)
        self.name = hitLocation["name"] as? String
    }

    
    static func == (lhs: Location, rhs: Location) -> Bool {
        return (
            lhs.address == rhs.address &&
            lhs.geoPoint == rhs.geoPoint &&
            lhs.name == rhs.name
        )
    }
}

struct TransitRecord: Equatable {
    var authorReference: DocumentReference
    var pickupDate: Date?
    var pickupGeoPoint: GeoPoint?
    var dropoffDate: Date?
    var dropoffGeoPoint: GeoPoint?
    var movements: [TransitMovement]?
    var reference: DocumentReference
    
    init(authorReference: DocumentReference, pickupDate: Date?, pickupGeoPoint: GeoPoint?, dropoffDate: Date?, dropoffGeoPoint: GeoPoint, movements: [TransitMovement]?, reference: DocumentReference) {
        self.authorReference = authorReference
        self.pickupDate = pickupDate
        self.pickupGeoPoint = pickupGeoPoint
        self.dropoffDate = dropoffDate
        self.dropoffGeoPoint = dropoffGeoPoint
        self.movements = movements
        self.reference = reference
    }
    
    init(dict:[String: Any], reference: DocumentReference) {
        self.reference = reference
        self.authorReference = dict["author_reference"] as! DocumentReference
        self.pickupDate = ((dict["pickup"] as! [String: Any])[
        "date"] as? Timestamp)?.dateValue()
        self.pickupGeoPoint = (dict["pickup"] as! [String: Any])[
            "geo_point"] as? GeoPoint
        if dict["dropoff"] != nil {
            self.dropoffDate = ((dict["dropoff"] as! [String: Any])[
                "date"] as? Timestamp)?.dateValue()
            self.dropoffGeoPoint = (dict["dropoff"] as! [String: Any])[
                "geo_point"] as? GeoPoint
        }
        self.movements = []
        if let movementsDict = dict["movements"] as? [String: GeoPoint] {
            for (key, value) in movementsDict {
                self.movements!.append(TransitMovement(date: Date(timeIntervalSince1970: TimeInterval(key)!), geoPoint: value))
            }
        }
        
        self.movements = self.movements?.sorted(by: { $0.date < $1.date })
    }
    
    static func ==(lhs: TransitRecord, rhs: TransitRecord) -> Bool {
        return (
            lhs.reference == rhs.reference &&
            lhs.authorReference == rhs.authorReference &&
            lhs.pickupDate == rhs.pickupDate &&
            lhs.pickupGeoPoint == rhs.pickupGeoPoint &&
            lhs.dropoffDate == rhs.dropoffDate &&
            lhs.dropoffGeoPoint == rhs.dropoffGeoPoint &&
            lhs.movements == rhs.movements
        )
    }
}

struct TransitMovement: Equatable {
    var date: Date
    var geoPoint: GeoPoint
    
    init(date: Date, geoPoint: GeoPoint) {
        self.date = date
        self.geoPoint = geoPoint
    }
    
    init(dict: [String: Any]) {
        self.date = (dict["date"] as! Timestamp).dateValue()
        self.geoPoint = dict["geo_point"] as! GeoPoint
    }
    
    static func ==(lhs: TransitMovement, rhs: TransitMovement) -> Bool {
        return lhs.date == rhs.date && lhs.geoPoint == rhs.geoPoint
    }
}

//struct PackageMoved {
//    var movedDate: Date
//    var headline: String
//    var reference: DocumentReference
//    var topic: PackageTopic
//    var coverImageUrl: String?
//    var packageStatus: PackageStatus
//    var packageMovedCount: PackageMovedCount
//    var categories: [PackageCategory]?
//
//    init(dict: [String: Any]) {
//        var categoriesArray:[PackageCategory] = []
//        for (category, _) in dict["categories"] as! [String: Bool] {
//            categoriesArray.append(getCategoryEnum(with: category))
//        }
//        self.categories = categoriesArray
//        self.packageMovedCount = PackageMovedCount(dict: dict["count"] as! [String: Int])
//        self.movedDate = (dict["moved_date"] as! Timestamp).dateValue()
//        self.headline = dict["headline"] as! String
//        self.reference = dict["package_reference"] as! DocumentReference
//        self.topic = PackageTopic(dict: dict["topic"] as! [String: Any])
//        self.coverImageUrl = dict["cover_pic_url"] as? String
//        self.packageStatus = getStatusEnum(with: dict["status"] as! String)
//    }
//}

//struct PackageMovedCount {
//    var unreadTotal: Int
//    
//    init(dict:[String: Any]) {
//        self.unreadTotal = dict["unread_total"] as! Int
//    }
//}


struct PackagePreview {
    var topicName: String
    var headline: String
    var recipientName: String
    var moversCount: Int
    var distanceFrom: CLLocationDistance
    var distanceTotal: CLLocationDistance
    var distanceLeft: CLLocationDistance
    var timeLeft: TimeInterval
    var categories: [PackageCategory]
    var packageStatus: PackageStatus
    var packageDocumentId: String
    var coordinate: CLLocationCoordinate2D
    var destination: Location?
    var destinationCoordinate: CLLocationCoordinate2D
    var originCoordinate: CLLocationCoordinate2D
    
    init(package: Package) {
        let currentLocation = package.currentLocation
        
        let destination = CLLocation(latitude: package.destination.geoPoint.latitude, longitude: package.destination.geoPoint.longitude)
        
        let origin = CLLocation(latitude: package.origin.geoPoint.latitude, longitude: package.origin.geoPoint.longitude)
        
        self.topicName = package.topic.name
        self.headline = package.headline
        self.recipientName = package.recipient.displayName
        self.moversCount = package.count!.movers!
        self.distanceTotal = destination.distance(from: origin)
        self.distanceLeft = destination.distance(from: currentLocation)
        self.distanceFrom =  distanceTotal - distanceLeft
        
        self.timeLeft = package.dueDate.timeIntervalSinceReferenceDate - Date.timeIntervalSinceReferenceDate
        
        self.packageStatus = package.status
        self.packageDocumentId = package.reference.documentID
        self.coordinate = package.currentLocation.coordinate
        self.destinationCoordinate = destination.coordinate
        self.originCoordinate = origin.coordinate
        self.categories = [package.category]
        self.destination = package.destination
    }
    
    init(hit: [String: Any]) {
        
        let currentLocation = CLLocation(
            latitude: (hit["_geoloc"] as! [String: CLLocationDegrees])["lat"]!,
            longitude: (hit["_geoloc"] as! [String: CLLocationDegrees])["lng"]!
        )
        
        let destination =  CLLocation(
            latitude: ((hit["destination"] as! [String: Any])["geo_point"] as! [String: CLLocationDegrees])["_latitude"]!,
            longitude: ((hit["destination"] as! [String: Any])["geo_point"] as! [String: CLLocationDegrees])["_longitude"]!
        )
        
        let origin = CLLocation(
            latitude: (hit["origin"] as! [String: CLLocationDegrees])["lat"]!,
            longitude: (hit["origin"] as! [String: CLLocationDegrees])["lng"]!
        )
        
        let categories = hit["_tags"] as! [String]
        
        self.topicName = hit["topicName"] as! String
        self.headline = hit["headline"] as! String
        self.recipientName = hit["recipientName"] as! String
        self.moversCount = hit["moversCount"] as! Int
        self.distanceTotal = destination.distance(from: origin)
        self.distanceLeft = destination.distance(from: currentLocation)
        self.distanceFrom =  distanceTotal - distanceLeft

        let dueDate = Date(timeIntervalSince1970: hit["dueDate"] as! TimeInterval)
        let diff = dueDate.timeIntervalSinceReferenceDate - Date.timeIntervalSinceReferenceDate
        self.timeLeft = diff > 0 ? TimeInterval(diff) : 0
        self.packageStatus = getStatusEnum(with: hit["status"] as! String)
        self.packageDocumentId = hit["objectID"] as! String
        self.coordinate = CLLocationCoordinate2D(
            latitude: (hit["_geoloc"] as! [String: CLLocationDegrees])["lat"]!,
            longitude: (hit["_geoloc"] as! [String: CLLocationDegrees])["lng"]!
        )
        self.destinationCoordinate = destination.coordinate
        self.originCoordinate = origin.coordinate
        self.categories = []
        for category in categories {
            self.categories.append(getCategoryEnum(with: category))
        }
        self.destination = (hit["destination"] as! [String: Any])["geo_point"] != nil ? Location(hitLocation: hit["destination"] as! [String: Any]) : nil
    }
}

func followPackage(with packageReference: DocumentReference, userReference: DocumentReference, completion: @escaping (Bool) -> ()) {
    Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
        // update package count followers and add user to package followers
        let packageDocument: DocumentSnapshot
        do {
            try packageDocument = transaction.getDocument(packageReference)
        } catch let fetchError as NSError {
            errorPointer?.pointee = fetchError
            return nil
        }
        
        let userDocument: DocumentSnapshot
        do {
            try userDocument = transaction.getDocument(userReference)
        } catch let fetchError as NSError {
            errorPointer?.pointee = fetchError
            return nil
        }
        
        guard let oldCountFollowers = ((packageDocument.data()!["relations"] as! [String: Any])["count"] as! [String: Int])["followers"] else {
            let error = NSError(
                domain: "AppErrorDomain",
                code: -1,
                userInfo: [
                    NSLocalizedDescriptionKey: "Unable to retrieve followers from snapshot \(packageDocument)"
                ]
            )
            errorPointer?.pointee = error
            return nil
        }
        
        let newCountFollowers = oldCountFollowers + 1
        
        transaction.updateData(["relations.count.followers": newCountFollowers, "relations.followers.\(userReference.documentID)": Date()], forDocument: packageReference)
        
        // update user's private profile's packages following dict with packageID: Date
        // update user's public profile's count packages_following
        guard let oldCountPackagesFollowing = (((userDocument.data()! as [String: Any])["public_profile"] as! [String: Any])["count"] as! [String: Int])["packages_following"] else {
            let error = NSError(
                domain: "AppErrorDomain",
                code: -1,
                userInfo: [
                    NSLocalizedDescriptionKey: "Unable to retrieve packages_following from snapshot \(userDocument)"
                ]
            )
            errorPointer?.pointee = error
            return nil
        }
        
        let newCountPackagesFollowing = oldCountPackagesFollowing + 1
        
        transaction.updateData(["public_profile.count.packages_following": newCountPackagesFollowing, "private_profile.packages_following.\(packageReference.documentID)": Date()], forDocument: userReference)
        
        return nil
    }) { (object, error) in
        if let error = error {
            print("Error following package with error: \(error)")
            completion(false)
        } else {
            print("Follow succeeded")
            completion(true)
        }
    }
}

func unfollowPackage(with packageReference: DocumentReference, userReference: DocumentReference, completion: @escaping (Bool) -> ()) {
    Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
        // update package count followers and remove user from package followers
        let packageDocument: DocumentSnapshot
        do {
            try packageDocument = transaction.getDocument(packageReference)
        } catch let fetchError as NSError {
            errorPointer?.pointee = fetchError
            return nil
        }
        
        let userDocument: DocumentSnapshot
        do {
            try userDocument = transaction.getDocument(userReference)
        } catch let fetchError as NSError {
            errorPointer?.pointee = fetchError
            return nil
        }
        
        guard let oldCountFollowers = ((packageDocument.data()!["relations"] as! [String: Any])["count"] as! [String: Int])["followers"] else {
            let error = NSError(
                domain: "AppErrorDomain",
                code: -1,
                userInfo: [
                    NSLocalizedDescriptionKey: "Unable to retrieve followers from snapshot \(packageDocument)"
                ]
            )
            errorPointer?.pointee = error
            return nil
        }
        
        let newCountFollowers = oldCountFollowers - 1
        
        transaction.updateData(["relations.count.followers": newCountFollowers, "relations.followers.\(userReference.documentID)": FieldValue.delete()], forDocument: packageReference)
        
        // remove packageID: Date from user's private profile's packages following dict
        // update user's public profile's count packages_following

        guard let oldCountPackagesFollowing = (((userDocument.data()! as [String: Any])["public_profile"] as! [String: Any])["count"] as! [String: Int])["packages_following"] else {
            let error = NSError(
                domain: "AppErrorDomain",
                code: -1,
                userInfo: [
                    NSLocalizedDescriptionKey: "Unable to retrieve packages_following from snapshot \(userDocument)"
                ]
            )
            errorPointer?.pointee = error
            return nil
        }
        
        let newCountPackagesFollowing = oldCountPackagesFollowing - 1
        
        transaction.updateData(["public_profile.count.packages_following": newCountPackagesFollowing, "private_profile.packages_following.\(packageReference.documentID)": FieldValue.delete()], forDocument: userReference)
        
        return nil
    }) { (object, error) in
        if let error = error {
            print("Error unfollowing package with error: \(error)")
            completion(false)
        } else {
            print("Unfollow succeeded")
            completion(true)
        }
    }
}

func pickupPackage(with packageReference: DocumentReference, userReference: DocumentReference, completion: @escaping (Bool) -> ()) {
    
    // FOLLOW PACKAGE IF NOT ALREADY FOLLOWING
    LocationManager.shared.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    LocationManager.shared.requestLocation()
    
    Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
        let packageDocument: DocumentSnapshot
        do {
            try packageDocument = transaction.getDocument(packageReference)
        } catch let fetchError as NSError {
            errorPointer?.pointee = fetchError
            return nil
        }
        
        let packageContent = (packageDocument.data()!["content"] as! [String: Any])
        let packageLogistics = (packageDocument.data()!["logistics"] as! [String: Any])
        let packageRelations = (packageDocument.data()!["relations"] as! [String: Any])
        
        
        // if user is not following already
        if UserManager.shared.userDocument!.privateProfile.packagesFollowing?[packageReference.documentID] == nil {
            // update packageDocument relations followers
            // update packageDocument relations.count.followers
            // update userDocument public_profile.count.packages_following
            // update userDocument by adding package to private_profile.packages_following as String: TimeInterval

            transaction.updateData(
                [
                    "relations.count.followers": (packageRelations["count"] as! [String: Int])["followers"]! + 1,
                    "relations.followers.\(UserManager.shared.userDocument!.reference.documentID)": Date()
                ],
                forDocument: packageReference
            )
            
            transaction.updateData([
                    "public_profile.count.packages_following": UserManager.shared.userDocument!.publicProfile.count.packagesFollowing + 1,
                    "private_profile.packages_following.\(packageReference.documentID)": Date(),
                    "private_profile.current_package": packageReference
                ],
               forDocument: userReference
            )
        }
        
        // update packageDocument logistics.status to transit
        // update packageDocument logistics.in_transit_by

        let location = GeoPoint(latitude: LocationManager.shared.location!.coordinate.latitude, longitude: LocationManager.shared.location!.coordinate.longitude)
        
        transaction.updateData(
            [
                "logistics.in_transit_by": [
                    "name": UserManager.shared.userDocument!.publicProfile.displayName,
                    "pic_url": UserManager.shared.userDocument!.publicProfile.picUrl ?? "",
                    "reference": userReference,
                ],
                "logistics.status": getStringForStatusEnum(statusEnum: .transit),
                "logistics.current_location": location,
            ],
            forDocument: packageReference
        )
        
        // TRANSIT_RECORD
        // author_reference
        // pickup -- geo_point, date
        
        transaction.setData(
            [
                "author_reference": userReference,
                "pickup": [
                    "geo_point": location,
                    "date": Date()
                ],
                ],
            forDocument: packageReference.collection("transit_records").document(userReference.documentID)
        )
        
        let pickupPublicActivitySupplements: [String: Any] = [
            "recipient": packageContent["recipient"] as! [String: Any],
            "destination": packageContent["destination"] as! [String: Any],
            "pickup_location": location,
        ]

        let pickupPublicActivity: [String: Any] = [
            "date": Date(),
            "type": getStringForActivityTypeEnum(type: .packagePickup),
            "actor_name": Auth.auth().currentUser!.displayName!,
            "actor_pic": Auth.auth().currentUser!.photoURL?.absoluteString ?? "",
            "actor_reference": userReference,
            "object_reference": packageReference,
            "object_type": getStringForObjectTypeEnum(type: .package),
            "object_name": packageContent["headline"] as! String,
            "followers": packageLogistics["followers"] as! [String: TimeInterval],
            "supplements": pickupPublicActivitySupplements,
            "supplements_type": getStringForActivitySupplementsType(type: .pickup)
        ]
        transaction.setData(pickupPublicActivity, forDocument: Firestore.firestore().collection("public_activities").document())
        
        return nil
    }) { (object, error) in
        if let error = error {
            print("Error picking up package with error: \(error)")
            completion(false)
        } else {
            print("Pickup succeeded")
            completion(true)
        }
    }
}

func dropoffPackage(with packageReference: DocumentReference, userReference: DocumentReference, completion: @escaping (Bool, [String: Any]?, UIAlertController?) -> ()) {
    
    LocationManager.shared.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    LocationManager.shared.requestLocation()

    Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
        let userDocument: DocumentSnapshot
        do {
            try userDocument = transaction.getDocument(userReference)
        } catch let fetchError as NSError {
            errorPointer?.pointee = fetchError
            return nil
        }
        
        let packageDocument: DocumentSnapshot
        do {
            try packageDocument = transaction.getDocument(packageReference)
        } catch let fetchError as NSError {
            errorPointer?.pointee = fetchError
            return nil
        }
        
        let transitRecordDocument: DocumentSnapshot
        do {
            try transitRecordDocument = transaction.getDocument(packageReference.collection("transit_records").document(Auth.auth().currentUser!.uid))
        } catch let fetchError as NSError {
            errorPointer?.pointee = fetchError
            return nil
        }
        
        let topicReference = ((((packageDocument["content"] as! [String: Any])["content"] as! [String: Any])["topic"] as! [String: Any])["reference"] as! DocumentReference)
        let topicName = ((((packageDocument["content"] as! [String: Any])["content"] as! [String: Any])["topic"] as! [String: Any])["name"] as! String)

        
        if let subscribedTopics = userDocument["subscripbed_topics"] as? [String: Double] {
            if subscribedTopics[topicReference.documentID] != nil {
                // user already subscribed to the topic
                let subscribedTopicDocument: DocumentSnapshot?
                do {
                try subscribedTopicDocument = transaction.getDocument(userReference.collection("subscribed_topic").document(topicReference.documentID))
                } catch let fetchError as NSError {
                    errorPointer?.pointee = fetchError
                    return nil
                }
                // update packagesMoved and count
                let oldPackagesMovedCount = (subscribedTopicDocument!["count"] as! [String:Int])["packages_moved"]!
                
                transaction.updateData(
                    [
                        "count.packages_moved": oldPackagesMovedCount + 1,
                        "packages_moved.\(packageReference.documentID)": Date()
                    ],
                    forDocument: subscribedTopicDocument!.reference
                )
            } else {
                // user hasn't subscribed to the topic
                transaction.setData(
                    [
                        "name": topicName,
                        "reference": topicReference,
                        "count": [
                            "packages_moved": 1,
                            "local_conversations": 0,
                            "private_conversations": 0,
                        ],
                        "packages_moved.\(packageReference.documentID)": Date(),
                    ],
                    forDocument: userReference.collection("subscribed_topics").document(topicReference.documentID)
                )
            }
        } else {
            // user hasn't subscribed to any topic
            transaction.setData(
                [
                    "name": topicName,
                    "reference": topicReference,
                    "count": [
                        "packages_moved": 1,
                        "local_conversations": 0,
                        "private_conversations": 0,
                    ],
                    "packages_moved.\(packageReference.documentID)": Date(),
                    ],
                forDocument: userReference.collection("subscribed_topics").document(topicReference.documentID)
            )
        }
        
        
        let location = GeoPoint(latitude: LocationManager.shared.location!.coordinate.latitude, longitude: LocationManager.shared.location!.coordinate.longitude)
        let locationCL = CLLocation(latitude: location.latitude, longitude: location.longitude)
        // PACKAGE
        // remove in_transit_by
        // update package status to pending or delivered
        // update package _geoloc/current location
        
        let packageContent = (packageDocument.data()!)["content"] as! [String: Any]
        let packageLogistics = (packageDocument.data()!)["logistics"] as! [String: Any]
        let packageRelations = (packageDocument.data()!)["relations"] as! [String: Any]
        
        let destinationCL = CLLocation(
            latitude: ((packageContent["destination"] as! [String: Any])["geo_point"] as! GeoPoint).latitude,
            longitude: ((packageContent["destination"] as! [String: Any])["geo_point"] as! GeoPoint).longitude
        )
        
        let originCL = CLLocation(
            latitude: ((packageLogistics["origin"] as! [String: Any])["geo_point"] as! GeoPoint).latitude,
            longitude: ((packageLogistics["origin"] as! [String: Any])["geo_point"] as! GeoPoint).longitude
        )
        
        let pickupLocationCL = CLLocation(
            latitude: (packageLogistics["current_location"] as! GeoPoint).latitude,
            longitude: (packageLogistics["current_location"] as! GeoPoint).longitude
        )

        let delivered = locationCL.distance(from: destinationCL) < ACTIONABLE_DISTANCE
        let deliveryBonus: Double = delivered ? 10 : 0
//        let delivered = true
        var creditsEarned: Double?
        var newBalance: Double?
        if destinationCL.distance(from: pickupLocationCL) > destinationCL.distance(from: locationCL) {
            // eligible to dropoff
            guard let oldCountMovers = (packageRelations["count"] as! [String: Int])["movers"] else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve movers from snapshot \(packageDocument)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            let newCountMovers = oldCountMovers + 1

            transaction.updateData([
                "logistics.in_transit_by": FieldValue.delete(),
                "logistics.status": delivered ? "delivered" : "pending",
                "logistics.current_location": location,
                "relations.count.movers": newCountMovers
                ], forDocument: packageReference)
            
            // TRANSIT RECORD
            // dropoff -- geo_point, date
            
            let now = Date()
            
            transaction.updateData(
                [
                    "dropoff.geo_point": location,
                    "dropoff.date": now,
                ],
                forDocument: packageReference.collection("transit_records").document(userReference.documentID)
            )
            
            // add to packages_moved under private_profile as String: TimeInterval
            transaction.updateData(
                ["private_profile.packages_moved.\(packageReference.documentID)": Date()],
                forDocument: userReference
            )

            let distanceMoved = destinationCL.distance(from: pickupLocationCL) - destinationCL.distance(from: locationCL)
            let pickupDate = (((transitRecordDocument.data()!)["pickup"] as! [String: Any])["date"] as! Timestamp).dateValue()
            let timeElapsed = now.timeIntervalSince1970 - pickupDate.timeIntervalSince1970
            
            let averageSpeedKMPH = (distanceMoved / 1000) / (timeElapsed / 60 / 60)
            let speedFactor: Double
            if averageSpeedKMPH < 5 {
                speedFactor = 3
            } else if averageSpeedKMPH < 30 {
                speedFactor = 2
            } else if averageSpeedKMPH < 80 {
                speedFactor = 1
            } else {
                speedFactor = 0.5
            }
            print("average speed kmph: \(averageSpeedKMPH)")
            creditsEarned = (timeElapsed / 60 / 2 + min((distanceMoved / 1000 * speedFactor), 60)).rounded()

            
            let oldBalance = ((userDocument.data()!)["private_profile"] as! [String: Any])["points_balance"] as! Double
            newBalance = oldBalance + deliveryBonus + creditsEarned!
            // USER_DOCUMENT
            // add private_profile.current_package
            
            transaction.updateData([
                "public_profile.count.packages_moved": UserManager.shared.userDocument!.publicProfile.count.packagesMoved + 1,
                "private_profile.current_package": FieldValue.delete(),
                "private_profile.points_balance": newBalance!
                ],
                                   forDocument: userReference
            )
            let dropoffAccountActivity: [String: Any] = [
                "date": Date(),
                "object_reference": packageReference,
                "object_type": getStringForObjectTypeEnum(type: .package),
                "object_name": packageContent["headline"] as! String,
                "type": getStringForActivityTypeEnum(type: .packageDropoff),
                "actor_name": Auth.auth().currentUser!.displayName!,
                "actor_pic": Auth.auth().currentUser!.photoURL?.absoluteString ?? "",
                "actor_reference": userReference,
                "amount": creditsEarned!
            ]
            transaction.setData(dropoffAccountActivity, forDocument: userReference.collection("account_activities").document())
            
            var followers: [String: Date] = packageRelations["followers"] as? [String: Date] ?? [:]
            for entry in followers {
                if entry.value.timeIntervalSince1970 > 0 {
                    followers[entry.key] = Date()
                }
            }
            
            if delivered {
                let deliveryPublicActivitySupplements: [String: Any] = [
                    "recipient": packageContent["recipient"] as! [String: Any],
                    "destination": packageContent["destination"] as! [String: Any],
                    "distance_total": originCL.distance(from: destinationCL),
                    "delivery_date": Date(),
                    "package_created_date": packageLogistics["created_date"] as! Timestamp,
                    "movers_count": (packageRelations["count"] as! [String: Int])["movers"]!
                ]

                let deliveryPublicActivity: [String: Any] = [
                    "date": Date(),
                    "type": getStringForActivityTypeEnum(type: .packageDelivery),
                    "actor_name": Auth.auth().currentUser!.displayName!,
                    "actor_pic": Auth.auth().currentUser!.photoURL?.absoluteString ?? "",
                    "actor_reference": userReference,
                    "object_reference": packageReference,
                    "object_type": getStringForObjectTypeEnum(type: .package),
                    "object_name": packageContent["headline"] as! String,
                    "followers": followers,
                    "supplements": deliveryPublicActivitySupplements,
                    "supplements_type": getStringForActivitySupplementsType(type: .delivery)
                ]
                transaction.setData(deliveryPublicActivity, forDocument: Firestore.firestore().collection("public_activities").document())
                
                let deliveryAccountActivity: [String: Any] = [
                    "date": Date(),
                    "object_reference": packageReference,
                    "object_type": getStringForObjectTypeEnum(type: .package),
                    "object_name": packageContent["headline"] as! String,
                    "type": getStringForActivityTypeEnum(type: .packageDelivery),
                    "actor_name": Auth.auth().currentUser!.displayName!,
                    "actor_pic": Auth.auth().currentUser!.photoURL?.absoluteString ?? "",
                    "actor_reference": userReference,
                    "amount": deliveryBonus
                ]
                transaction.setData(deliveryAccountActivity, forDocument: userReference.collection("account_activities").document())
            } else {
                let dropoffPublicActivitySupplements: [String: Any] = [
                    "recipient": packageContent["recipient"] as! [String: Any],
                    "destination": packageContent["destination"] as! [String: Any],
                    "distance_traveled": distanceMoved,
                    "due_date": (packageContent["due_date"] as! Timestamp),
                    "dropoff_location": location,
                    ]
                
                let dropoffPublicActivity: [String: Any] = [
                    "date": Date(),
                    "type": getStringForActivityTypeEnum(type: .packageDropoff),
                    "actor_name": Auth.auth().currentUser!.displayName!,
                    "actor_pic": Auth.auth().currentUser!.photoURL?.absoluteString ?? "",
                    "actor_reference": userReference,
                    "object_reference": packageReference,
                    "object_type": getStringForObjectTypeEnum(type: .package),
                    "object_name": packageContent["headline"] as! String,
                    "followers": followers,
                    "supplements": dropoffPublicActivitySupplements,
                    "supplements_type": getStringForActivitySupplementsType(type: .dropoff)
                ]
                transaction.setData(dropoffPublicActivity, forDocument: Firestore.firestore().collection("public_activities").document())
            }
            
        } else {
            // ineligible to dropoff
            let error = NSError(
                domain: "AppErrorDomain",
                code: -1,
                userInfo: [
                    NSLocalizedDescriptionKey: "Dropoff attempted at a location further away from destination than pickup location.",
                    "dropoffError": DropoffError.DropoffLocationNotCloserThanPickupLocation
                ]
            )
            errorPointer?.pointee = error
            print("Dropoff attempted at a location further away from destination than pickup location.")
        }
        return [
            "delivered": delivered,
            "credits_earned": creditsEarned,
            "new_balance": newBalance,
            "delivery_bonus": deliveryBonus
        ]
    }) { (object, error) in
        if let error = error {
            print("Error dropping off package with error: \(error)")
            if let dropoffError = (error as NSError).userInfo["dropoffError"] as! DropoffError? {
                print(dropoffError)
                var alertBody: String?
                if dropoffError == .DropoffLocationNotCloserThanPickupLocation {
                    alertBody = String(NSLocalizedString("copy.alert.unableToDropoffDesc", comment: "alert body for unable to dropoff"))
                }
                let alertController = UIAlertController(title: String(NSLocalizedString("copy.alert.unableToDropoff", comment: "alert title for unable to dropoff")), message: alertBody, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: String(NSLocalizedString("button.ok", comment: "button title for ok")), style: .cancel, handler: { (action) in
                    print("tapped ok")
                })
                alertController.addAction(cancelAction)
                completion(false, object as? [String: Any], alertController)
            }
        } else {
            print("Dropoff succeeded")
            completion(true, object as? [String: Any], nil)
        }
    }
}
