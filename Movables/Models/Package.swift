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
    var categories: [PackageCategory]
    var count: TemplateCount?
    var coverImageUrl: String?
    var description: String
    var destination: Location
    var headline: String
    var recipient: Person
    var status: PackageStatus
    var tag: PackageTag
    var templateBy: Person?
    var reference: DocumentReference
    var dueDate: PackageDueDate?
    var dropoffMessage: String?
    var externalActions: [ExternalAction]?
    
    init(snapshot: DocumentSnapshot) {
        let dictionary = snapshot.data()!
        
        var categoriesArray:[PackageCategory] = []
        for (category, _) in dictionary["categories"] as! [String: Bool] {
            categoriesArray.append(getCategoryEnum(with: category))
        }
        self.categories = categoriesArray
        
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
        
        self.status = getStatusEnum(with: dictionary["status"] as! String)
        
        self.tag = PackageTag(dict: dictionary["tag"] as! [String: Any])
        
        if let templateByDict = dictionary["template_by"] as? [String: Any] {
            self.templateBy = Person(dict: templateByDict)
        } else {
            self.templateBy = nil
        }
        
        self.reference = snapshot.reference
        
        self.dueDate = PackageDueDate(dict: dictionary["due_date"] as! [String : Timestamp?])
        
        self.dropoffMessage = dictionary["dropoff_message"] as? String
    }
}

struct Package: Equatable {
    var sender: Person
    var categories: [PackageCategory]
    var count: PackageCount?
    var coverImageUrl: String?
    var description: String
    var destination: Location
    var headline: String
    var inTransitBy: Person?
    var origin: Location
    var recipient: Person
    var status: PackageStatus
    var tag: PackageTag
    var templateBy: Person?
    var transitRecords: [TransitRecord]?
    var externalActions: [ExternalAction]?
    var reference: DocumentReference
    var currentLocation: CLLocation
    var dueDate: PackageDueDate?
    var dropoffMessage: String?
    var followers: [String: Double]?
    
    init(sender: Person, categories: [PackageCategory], count: PackageCount?, coverImageUrl: String?, description: String, destination: Location, headline: String, inTransitBy: Person?, origin: Location, recipient: Person, status: PackageStatus, tag: PackageTag, templateBy: Person?, transitRecords: [TransitRecord]?, reference: DocumentReference, currentLocation: CLLocation, dueDate: PackageDueDate) {
        self.sender = sender
        self.categories = categories
        self.count = count
        self.coverImageUrl = coverImageUrl
        self.description = description
        self.destination = destination
        self.headline = headline
        self.inTransitBy = inTransitBy
        self.origin = origin
        self.recipient = recipient
        self.status = status
        self.tag = tag
        self.templateBy = templateBy
        self.transitRecords = transitRecords
        self.reference = reference
        self.currentLocation = currentLocation
        self.dueDate = dueDate
    }
    
    init(snapshot: DocumentSnapshot) {
        let dictionary = snapshot.data()!
        self.sender = Person(dict: dictionary["author"] as! [String: Any])
        
        var categoriesArray:[PackageCategory] = []
        for (category, _) in dictionary["categories"] as! [String: Bool] {
            categoriesArray.append(getCategoryEnum(with: category))
        }
        self.categories = categoriesArray
        
        if let countDict = dictionary["count"] as? [String: Int] {
            self.count = PackageCount(dict: countDict)
        } else {
            self.count = nil
        }
        
        self.coverImageUrl = dictionary["cover_pic_url"] as? String
        
        self.description = dictionary["description"] as! String
        
        self.destination = Location(dict: dictionary["destination"] as! [String: Any])
        
        self.headline = dictionary["headline"] as! String
        
        if let inTransitByDict = dictionary["in_transit_by"] as? [String: Any] {
            self.inTransitBy = Person(dict: inTransitByDict)
        } else {
            self.inTransitBy = nil
        }
        
        self.origin = Location(dict: dictionary["origin"] as! [String: Any])
        
        self.recipient = Person(dict: dictionary["recipient"] as! [String: Any])
        
        self.status = getStatusEnum(with: dictionary["status"] as! String)
        
        self.tag = PackageTag(dict: dictionary["tag"] as! [String: Any])
        
        if let templateByDict = dictionary["template_by"] as? [String: Any] {
            self.templateBy = Person(dict: templateByDict)
        } else {
            self.templateBy = nil
        }

        self.transitRecords = nil
        
        self.reference = snapshot.reference
        
        let currentLocation = dictionary["_geoloc"] as! GeoPoint
        self.currentLocation = CLLocation(
            latitude: currentLocation.latitude,
            longitude: currentLocation.longitude
        )
        
        self.dueDate = PackageDueDate(dict: dictionary["due_date"] as! [String : Timestamp?])
        self.dropoffMessage = dictionary["dropoff_message"] as? String
        self.externalActions = nil
        self.followers = dictionary["followers"] as? [String: Double]
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
        
        var templateByEqual: Bool?
        if lhs.templateBy == nil && rhs.templateBy == nil {
            templateByEqual = true
        } else if lhs.templateBy == nil || rhs.templateBy == nil {
            templateByEqual = false
        } else {
            templateByEqual = lhs.templateBy! == rhs.templateBy!
        }
        
        var dueDateEqual: Bool?
        if lhs.dueDate == nil && rhs.dueDate == nil {
            dueDateEqual = true
        } else if lhs.dueDate == nil || rhs.dueDate == nil {
            dueDateEqual = false
        } else {
            dueDateEqual = lhs.dueDate! == rhs.dueDate!
        }

        return (
            lhs.sender == rhs.sender &&
            lhs.categories == rhs.categories &&
            coverImageUrlEqual! &&
            lhs.description == rhs.description &&
            lhs.destination == rhs.destination &&
            lhs.headline == rhs.headline &&
            inTransitByEqual! &&
            lhs.origin == rhs.origin &&
            lhs.recipient == rhs.recipient &&
            lhs.status == rhs.status &&
            lhs.tag == rhs.tag &&
            templateByEqual! &&
            lhs.transitRecords == rhs.transitRecords &&
            lhs.reference == rhs.reference &&
            lhs.currentLocation.coordinate.latitude == rhs.currentLocation.coordinate.latitude &&
            lhs.currentLocation.coordinate.longitude == rhs.currentLocation.coordinate.longitude &&
            dueDateEqual!
        )
    }
}

struct PackageDueDate {
    var start: Date?
    var end: Date?
    
    init(dict: [String: Timestamp?]) {
        self.start = (dict["start"] as? Timestamp)?.dateValue()
        self.end = (dict["end"] as? Timestamp)?.dateValue()
    }
    
    static func ==(lhs: PackageDueDate, rhs: PackageDueDate) -> Bool {
        return lhs.start == rhs.start && lhs.end == rhs.end
    }
}

struct Person: Equatable {
    var displayName: String
    var photoUrl: String?
    var reference: DocumentReference?
    var twitter_handle: String?
    var phone: String?
    
    init(displayName: String, photoUrl: String?, reference: DocumentReference?, twitter_handle: String?, phone: String?) {
        self.displayName = displayName
        self.photoUrl = photoUrl
        self.reference = reference
        self.twitter_handle = twitter_handle
        self.phone = phone
    }
    
    init(dict: [String: Any]) {
        self.displayName = dict["name"] as! String
        self.photoUrl = dict["pic_url"] as? String
        self.reference = dict["reference"] as? DocumentReference
        self.twitter_handle = dict["twitter_handle"] as? String
        self.phone = dict["phone"] as? String
    }
    
    static func == (lhs: Person, rhs: Person) -> Bool {
        return (
            lhs.displayName == rhs.displayName &&
            lhs.photoUrl == rhs.photoUrl &&
            lhs.reference == rhs.reference &&
            lhs.twitter_handle == rhs.twitter_handle &&
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
    
    init(algoliaDict: [String: Any]) {
        self.address = algoliaDict["address"] as? String
        self.geoPoint = GeoPoint(latitude: (algoliaDict["geo_point"] as! [String: Any])["_latitude"] as! Double, longitude: (algoliaDict["geo_point"] as! [String: Any])["_longitude"] as! Double)
        self.name = algoliaDict["name"] as? String
    }

    
    static func == (lhs: Location, rhs: Location) -> Bool {
        return (
            lhs.address == rhs.address &&
            lhs.geoPoint == rhs.geoPoint &&
            lhs.name == rhs.name
        )
    }
}

struct PackageTag: Equatable {
    var name: String
    var reference: DocumentReference
    
    init(name: String, reference: DocumentReference) {
        self.name = name
        self.reference = reference
    }
    
    init(dict: [String: Any]) {
        self.name = dict["name"] as! String
        self.reference = dict["reference"] as! DocumentReference
    }
    
    static func ==(lhs: PackageTag, rhs: PackageTag) -> Bool{
        return lhs.name == rhs.name && lhs.reference == rhs.reference
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
        self.movements = nil
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

struct PackageFollowing {
    var packageCount: PackageCount
    var packageUpdatesCount: PackageUpdatesCount
    var followedDate: Date
    var headline: String
    var reference: DocumentReference
    var tag: PackageTag
    var coverImageUrl: String?
    var packageStatus: PackageStatus
    var coordinate: CLLocationCoordinate2D
    
    init(dict: [String: Any]) {
        self.packageCount = PackageCount(dict: dict["count"] as! [String: Int])
        self.packageUpdatesCount = PackageUpdatesCount(dict: dict["updatesCount"] as! [String: Int])
        self.followedDate = (dict["followed_date"] as! Timestamp).dateValue()
        self.headline = dict["headline"] as! String
        self.reference = dict["package_reference"] as! DocumentReference
        self.tag = PackageTag(dict: dict["tag"] as! [String: Any])
        self.coverImageUrl = dict["cover_pic_url"] as? String
        self.packageStatus = getStatusEnum(with: dict["status"] as! String)
        let geoPoint = dict["_geoloc"] as! GeoPoint
        self.coordinate = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
    }
}

struct PackageMoved {
    var movedDate: Date
    var headline: String
    var reference: DocumentReference
    var tag: PackageTag
    var coverImageUrl: String?
    var packageStatus: PackageStatus
    var packageMovedCount: PackageMovedCount
    var categories: [PackageCategory]?
    
    init(dict: [String: Any]) {
        var categoriesArray:[PackageCategory] = []
        for (category, _) in dict["categories"] as! [String: Bool] {
            categoriesArray.append(getCategoryEnum(with: category))
        }
        self.categories = categoriesArray
        self.packageMovedCount = PackageMovedCount(dict: dict["count"] as! [String: Int])
        self.movedDate = (dict["moved_date"] as! Timestamp).dateValue()
        self.headline = dict["headline"] as! String
        self.reference = dict["package_reference"] as! DocumentReference
        self.tag = PackageTag(dict: dict["tag"] as! [String: Any])
        self.coverImageUrl = dict["cover_pic_url"] as? String
        self.packageStatus = getStatusEnum(with: dict["status"] as! String)
    }
}

struct PackageMovedCount {
    var unreadTotal: Int
    
    init(dict:[String: Any]) {
        self.unreadTotal = dict["unread_total"] as! Int
    }
}


struct PackagePreview {
    var tagName: String
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
        
        self.tagName = package.tag.name
        self.headline = package.headline
        self.recipientName = package.recipient.displayName
        self.moversCount = package.count!.movers!
        self.distanceTotal = destination.distance(from: origin)
        self.distanceLeft = destination.distance(from: currentLocation)
        self.distanceFrom =  distanceTotal - distanceLeft
        
        if let dueDate = package.dueDate?.end {
            self.timeLeft = dueDate.timeIntervalSinceReferenceDate - Date.timeIntervalSinceReferenceDate
        } else {
            self.timeLeft = 0
        }
        self.packageStatus = package.status
        self.packageDocumentId = package.reference.documentID
        self.coordinate = package.currentLocation.coordinate
        self.destinationCoordinate = destination.coordinate
        self.originCoordinate = origin.coordinate
        self.categories = package.categories
        self.destination = package.destination
    }
    
    init(hit: [String: Any]) {
        
        let currentLocation = CLLocation(
            latitude: (hit["_geoloc"] as! [String: CLLocationDegrees])["lat"]!,
            longitude: (hit["_geoloc"] as! [String: CLLocationDegrees])["lng"]!
        )
        
        let destination = (hit["destination"] as! [String: Any])["geo_point"] == nil ? CLLocation(
            latitude: (hit["destination"] as! [String: CLLocationDegrees])["lat"]!,
            longitude: (hit["destination"] as! [String: CLLocationDegrees])["lng"]!
            ) : CLLocation(
            latitude: ((hit["destination"] as! [String: Any])["geo_point"] as! [String: CLLocationDegrees])["_latitude"]!,
            longitude: ((hit["destination"] as! [String: Any])["geo_point"] as! [String: CLLocationDegrees])["_longitude"]!
        )
        
        let origin = CLLocation(
            latitude: (hit["origin"] as! [String: CLLocationDegrees])["lat"]!,
            longitude: (hit["origin"] as! [String: CLLocationDegrees])["lng"]!
        )
        
        let categories = hit["_tags"] as! [String]
        
        self.tagName = hit["tagName"] as! String
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
        self.destination = (hit["destination"] as! [String: Any])["geo_point"] != nil ? Location(algoliaDict: hit["destination"] as! [String: Any]) : nil
    }
}

func followPackageWithRef(packageReference: DocumentReference, userReference: DocumentReference, completion: @escaping (Bool) -> ()) {
    Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
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
        
        guard let oldCountFollowers = ((packageDocument.data()! as [String: Any])["count"] as! [String: Int])["followers"] else {
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
        transaction.updateData(["count.followers": newCountFollowers, "followers.\(userReference.documentID)": Date().timeIntervalSince1970], forDocument: packageReference)
        
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
        transaction.updateData(["public_profile.count.packages_following": newCountPackagesFollowing], forDocument: userReference)
        
        guard let tag = packageDocument.data()?["tag"] as? [String: Any] else {
            let error = NSError(
                domain: "AppErrorDomain",
                code: -1,
                userInfo: [
                    NSLocalizedDescriptionKey: "Unable to retrieve tag from snapshot \(packageDocument)"
                ]
            )
            errorPointer?.pointee = error
            return nil
        }
        
        guard let headline = packageDocument.data()?["headline"] as? String else {
            let error = NSError(
                domain: "AppErrorDomain",
                code: -1,
                userInfo: [
                    NSLocalizedDescriptionKey: "Unable to retrieve headline from snapshot \(packageDocument)"
                ]
            )
            errorPointer?.pointee = error
            return nil
        }
        
        guard let coverPicUrl = packageDocument.data()?["cover_pic_url"] as? String else {
            let error = NSError(
                domain: "AppErrorDomain",
                code: -1,
                userInfo: [
                    NSLocalizedDescriptionKey: "Unable to retrieve cover_pic_url from snapshot \(packageDocument)"
                ]
            )
            errorPointer?.pointee = error
            return nil
        }
        
        guard let countMovers = ((packageDocument.data()! as [String: Any])["count"] as! [String: Int])["movers"] else {
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
        
        guard let status = packageDocument.data()?["status"] as? String else {
            let error = NSError(
                domain: "AppErrorDomain",
                code: -1,
                userInfo: [
                    NSLocalizedDescriptionKey: "Unable to retrieve status from snapshot \(packageDocument)"
                ]
            )
            errorPointer?.pointee = error
            return nil
        }
        
        guard let geoloc = packageDocument.data()?["_geoloc"] as? GeoPoint else {
            let error = NSError(
                domain: "AppErrorDomain",
                code: -1,
                userInfo: [
                    NSLocalizedDescriptionKey: "Unable to retrieve _geoloc from snapshot \(packageDocument)"
                ]
            )
            errorPointer?.pointee = error
            return nil
        }
        
        transaction.setData(
            [
                "package_reference": packageReference,
                "tag": tag,
                "headline": headline,
                "cover_pic_url": coverPicUrl,
                "followed_date": Timestamp(date: Date()),
                "count": [
                    "followers": newCountFollowers,
                    "movers": countMovers
                ],
                "updatesCount": [
                    "progress_events": 0,
                    "unread_progress_events": 0,
                    "posts_events": 0,
                    "unread_posts_events": 0
                ],
                "status": status,
                "_geoloc": geoloc,
                ],
            forDocument: userReference.collection("packages_following").document(packageReference.documentID)
        )
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

func unfollowPackageWithRef(packageReference: DocumentReference, userReference: DocumentReference, completion: @escaping (Bool) -> ()) {
    Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
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
        
        guard let oldCountFollowers = ((packageDocument.data()! as [String: Any])["count"] as! [String: Int])["followers"] else {
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
        let newCountFollowers = oldCountFollowers + -1
        transaction.updateData(["count.followers": newCountFollowers, "followers.\(userReference.documentID)": 0], forDocument: packageReference)
        
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
        let newCountPackagesFollowing = oldCountPackagesFollowing + -1
        transaction.updateData(["public_profile.count.packages_following": newCountPackagesFollowing], forDocument: userReference)
        
        transaction.deleteDocument(userReference.collection("packages_following").document(packageReference.documentID))
        
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

func pickupPackageWithRef(packageReference: DocumentReference, userReference: DocumentReference, completion: @escaping (Bool) -> ()) {
    
    // FOLLOW PACKAGE IF NOT ALREADY FOLLOWING
    
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
        
        let packageFollowingDocument: DocumentSnapshot?
        do {
            try packageFollowingDocument = transaction.getDocument(userReference.collection("packages_following").document(packageReference.documentID))
        } catch _ as NSError {
//            errorPointer?.pointee = fetchError
            packageFollowingDocument = nil
        }
        
        if packageFollowingDocument == nil {
            // follow
            do {
            try internalFollow(with: transaction, packageDocument: packageDocument, packageReference: packageReference, userReference: userReference, userDocument: userDocument, errorPointer: errorPointer)
            } catch {
                return nil
            }
        } else {
            transaction.updateData([:], forDocument: userReference.collection("packages_following").document(packageReference.documentID))
        }
        
        
        // PACKAGE
        // add in_transit_by to package
        // update package status to transit
        // update package _geoloc/current location
        
        guard let name = ((userDocument.data()! as [String: Any])["public_profile"] as! [String: Any])["display_name"] as? String else {
            let error = NSError(
                domain: "AppErrorDomain",
                code: -1,
                userInfo: [
                    NSLocalizedDescriptionKey: "Unable to retrieve display_name from snapshot \(userDocument)"
                ]
            )
            errorPointer?.pointee = error
            return nil
        }
        
        guard let picUrl = ((userDocument.data()! as [String: Any])["public_profile"] as! [String: Any])["pic_url"] as? String else {
            let error = NSError(
                domain: "AppErrorDomain",
                code: -1,
                userInfo: [
                    NSLocalizedDescriptionKey: "Unable to retrieve pic_url from snapshot \(userDocument)"
                ]
            )
            errorPointer?.pointee = error
            return nil
        }
        
        let location = GeoPoint(latitude: LocationManager.shared.location!.coordinate.latitude, longitude: LocationManager.shared.location!.coordinate.longitude)
        
        transaction.updateData(
            [
                "in_transit_by": [
                    "name": name,
                    "pic_url": picUrl,
                    "reference": userReference
                ],
                "status": "transit",
                "_geoloc": location
            ],
            forDocument: packageReference
        )
        
        // USER_DOCUMENT
        // add private_profile.current_package
        
        transaction.updateData([
            "private_profile.current_package": packageReference
            ],
                               forDocument: userReference
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
        
        // Add package to packages_moved
//        guard let tag = packageDocument.data()?["tag"] as? [String: Any] else {
//            let error = NSError(
//                domain: "AppErrorDomain",
//                code: -1,
//                userInfo: [
//                    NSLocalizedDescriptionKey: "Unable to retrieve tag from snapshot \(packageDocument)"
//                ]
//            )
//            errorPointer?.pointee = error
//            return nil
//        }
        
//        guard let headline = packageDocument.data()?["headline"] as? String else {
//            let error = NSError(
//                domain: "AppErrorDomain",
//                code: -1,
//                userInfo: [
//                    NSLocalizedDescriptionKey: "Unable to retrieve headline from snapshot \(packageDocument)"
//                ]
//            )
//            errorPointer?.pointee = error
//            return nil
//        }
//
//        guard let coverPicUrl = packageDocument.data()?["cover_pic_url"] as? String else {
//            let error = NSError(
//                domain: "AppErrorDomain",
//                code: -1,
//                userInfo: [
//                    NSLocalizedDescriptionKey: "Unable to retrieve cover_pic_url from snapshot \(packageDocument)"
//                ]
//            )
//            errorPointer?.pointee = error
//            return nil
//        }
        
//        guard let countFollowers = ((packageDocument.data()! as [String: Any])["count"] as! [String: Int])["followers"] else {
//            let error = NSError(
//                domain: "AppErrorDomain",
//                code: -1,
//                userInfo: [
//                    NSLocalizedDescriptionKey: "Unable to retrieve followers from snapshot \(packageDocument)"
//                ]
//            )
//            errorPointer?.pointee = error
//            return nil
//        }
//        
//        guard let countMovers = ((packageDocument.data()! as [String: Any])["count"] as! [String: Int])["movers"] else {
//            let error = NSError(
//                domain: "AppErrorDomain",
//                code: -1,
//                userInfo: [
//                    NSLocalizedDescriptionKey: "Unable to retrieve movers from snapshot \(packageDocument)"
//                ]
//            )
//            errorPointer?.pointee = error
//            return nil
//        }
//
//
//        guard let status = packageDocument.data()?["status"] as? String else {
//            let error = NSError(
//                domain: "AppErrorDomain",
//                code: -1,
//                userInfo: [
//                    NSLocalizedDescriptionKey: "Unable to retrieve status from snapshot \(packageDocument)"
//                ]
//            )
//            errorPointer?.pointee = error
//            return nil
//        }
//
//        guard let geoloc = packageDocument.data()?["_geoloc"] as? GeoPoint else {
//            let error = NSError(
//                domain: "AppErrorDomain",
//                code: -1,
//                userInfo: [
//                    NSLocalizedDescriptionKey: "Unable to retrieve _geoloc from snapshot \(packageDocument)"
//                ]
//            )
//            errorPointer?.pointee = error
//            return nil
//        }
        
        var followers: [String: Double] = packageDocument["followers"] as? [String: Double] ?? [:]
        
        for entry in followers {
            if entry.value > 0 {
                followers[entry.key] = Date().timeIntervalSince1970
            }
        }
        
        let pickupPublicActivitySupplements: [String: Any] = [
            "recipient": packageDocument.data()?["recipient"] as! [String: Any],
            "destination": packageDocument.data()?["destination"] as! [String: Any],
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
            "object_name": packageDocument.data()?["headline"] as! String,
            "followers": followers,
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

func dropoffPackageWithRef(packageReference: DocumentReference, userReference: DocumentReference, completion: @escaping (Bool, [String: Any]?, UIAlertController?) -> ()) {
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
        
        
        let location = GeoPoint(latitude: LocationManager.shared.location!.coordinate.latitude, longitude: LocationManager.shared.location!.coordinate.longitude)
        let locationCL = CLLocation(latitude: location.latitude, longitude: location.longitude)
        // PACKAGE
        // remove in_transit_by
        // update package status to pending or delivered
        // update package _geoloc/current location
        
        let destinationCL = CLLocation(
            latitude: (((packageDocument.data()!)["destination"] as! [String: Any])["geo_point"] as! GeoPoint).latitude,
            longitude: (((packageDocument.data()!)["destination"] as! [String: Any])["geo_point"] as! GeoPoint).longitude)
        
        let originCL = CLLocation(
            latitude: (((packageDocument.data()!)["origin"] as! [String: Any])["geo_point"] as! GeoPoint).latitude,
            longitude: (((packageDocument.data()!)["origin"] as! [String: Any])["geo_point"] as! GeoPoint).longitude)

        
        let pickupLocationCL = CLLocation(
            latitude: ((packageDocument.data()!)["_geoloc"] as! GeoPoint).latitude,
            longitude: ((packageDocument.data()!)["_geoloc"] as! GeoPoint).longitude)
        
        let delivered = locationCL.distance(from: destinationCL) < ACTIONABLE_DISTANCE
        let deliveryBonus: Double = delivered ? 10 : 0
//        let delivered = true
        var creditsEarned: Double?
        var newBalance: Double?
        if destinationCL.distance(from: pickupLocationCL) > destinationCL.distance(from: locationCL) {
            // eligible to dropoff
            guard let oldCountMovers = ((packageDocument.data()! as [String: Any])["count"] as! [String: Int])["movers"] else {
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
                "in_transit_by": FieldValue.delete(),
                "status": delivered ? "delivered" : "pending",
                "_geoloc": location,
                "count.movers": newCountMovers
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
            
            transaction.setData(
                [
                    "package_reference": packageReference,
                    "tag": (packageDocument.data()?["tag"] as! [String : Any]),
                    "categories": (packageDocument.data()?["categories"] as! [String : Any]),
                    "headline": packageDocument.data()?["headline"] as! String,
                    "cover_pic_url": packageDocument.data()?["cover_pic_url"] as! String,
                    "moved_date": Timestamp(date: Date()),
                    "count": [
                        "unread_total": 0,
                    ],
                    "status": packageDocument.data()?["status"] as! String,
                ],
                forDocument: userReference.collection("packages_moved").document(packageReference.documentID)
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

            
            let oldBalance = ((userDocument.data()!)["private_profile"] as! [String: Any])["time_bank_balance"] as! Double
            newBalance = oldBalance + deliveryBonus + creditsEarned!
            // USER_DOCUMENT
            // add private_profile.current_package
            
            transaction.updateData([
                "private_profile.current_package": FieldValue.delete(),
                "private_profile.time_bank_balance": newBalance!
                ],
                                   forDocument: userReference
            )
            let dropoffAccountActivity: [String: Any] = [
                "date": Date(),
                "object_reference": packageReference,
                "object_type": getStringForObjectTypeEnum(type: .package),
                "object_name": packageDocument.data()?["headline"] as! String,
                "type": getStringForActivityTypeEnum(type: .packageDropoff),
                "actor_name": Auth.auth().currentUser!.displayName!,
                "actor_pic": Auth.auth().currentUser!.photoURL?.absoluteString ?? "",
                "actor_reference": userReference,
                "amount": creditsEarned!
            ]
            transaction.setData(dropoffAccountActivity, forDocument: userReference.collection("account_activities").document())
            
            var followers: [String: Double] = packageDocument["followers"] as? [String: Double] ?? [:]
            for entry in followers {
                if entry.value > 0 {
                    followers[entry.key] = Date().timeIntervalSince1970
                }
            }
            
            if delivered {
                let deliveryPublicActivitySupplements: [String: Any] = [
                    "recipient": packageDocument.data()?["recipient"] as! [String: Any],
                    "destination": packageDocument.data()?["destination"] as! [String: Any],
                    "distance_total": originCL.distance(from: destinationCL),
                    "delivery_date": Date(),
                    "package_created_date": packageDocument.data()?["created_date"] as! Timestamp,
                    "movers_count": (packageDocument.data()?["count"] as! [String: Int])["movers"]!
                ]

                let deliveryPublicActivity: [String: Any] = [
                    "date": Date(),
                    "type": getStringForActivityTypeEnum(type: .packageDelivery),
                    "actor_name": Auth.auth().currentUser!.displayName!,
                    "actor_pic": Auth.auth().currentUser!.photoURL?.absoluteString ?? "",
                    "actor_reference": userReference,
                    "object_reference": packageReference,
                    "object_type": getStringForObjectTypeEnum(type: .package),
                    "object_name": packageDocument.data()?["headline"] as! String,
                    "followers": followers,
                    "supplements": deliveryPublicActivitySupplements,
                    "supplements_type": getStringForActivitySupplementsType(type: .delivery)
                ]
                transaction.setData(deliveryPublicActivity, forDocument: Firestore.firestore().collection("public_activities").document())
                
                let deliveryAccountActivity: [String: Any] = [
                    "date": Date(),
                    "object_reference": packageReference,
                    "object_type": getStringForObjectTypeEnum(type: .package),
                    "object_name": packageDocument.data()?["headline"] as! String,
                    "type": getStringForActivityTypeEnum(type: .packageDelivery),
                    "actor_name": Auth.auth().currentUser!.displayName!,
                    "actor_pic": Auth.auth().currentUser!.photoURL?.absoluteString ?? "",
                    "actor_reference": userReference,
                    "amount": deliveryBonus
                ]
                transaction.setData(deliveryAccountActivity, forDocument: userReference.collection("account_activities").document())
            } else {
                let dropoffPublicActivitySupplements: [String: Any] = [
                    "recipient": packageDocument.data()?["recipient"] as! [String: Any],
                    "destination": packageDocument.data()?["destination"] as! [String: Any],
                    "distance_traveled": distanceMoved,
                    "due_date": (packageDocument.data()?["due_date"] as! [String: Timestamp])["end"]!,
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
                    "object_name": packageDocument.data()?["headline"] as! String,
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

func internalFollow(with transaction: Transaction, packageDocument: DocumentSnapshot, packageReference: DocumentReference, userReference: DocumentReference, userDocument: DocumentSnapshot, errorPointer: NSErrorPointer) throws {
    guard let oldCountFollowers = (packageDocument.data()!["count"] as! [String: Int])["followers"] else {
        let error = NSError(
            domain: "AppErrorDomain",
            code: -1,
            userInfo: [
                NSLocalizedDescriptionKey: "Unable to retrieve followers from snapshot \(packageDocument)"
            ]
        )
        errorPointer?.pointee = error
        print(error)
        throw error
    }
    let newCountFollowers = oldCountFollowers + 1
    transaction.updateData(["count.followers": newCountFollowers, "followers.\(userReference.documentID)": Date().timeIntervalSince1970], forDocument: packageReference)
    
    guard let oldCountPackagesFollowing = (((userDocument.data()! as [String: Any])["public_profile"] as! [String: Any])["count"] as! [String: Int])["packages_following"] else {
        let error = NSError(
            domain: "AppErrorDomain",
            code: -1,
            userInfo: [
                NSLocalizedDescriptionKey: "Unable to retrieve packages_following from snapshot \(userDocument)"
            ]
        )
        errorPointer?.pointee = error
        print(error)
        throw error
    }
    let newCountPackagesFollowing = oldCountPackagesFollowing + 1
    transaction.updateData(["public_profile.count.packages_following": newCountPackagesFollowing], forDocument: userReference)
    
    guard let tag = packageDocument.data()?["tag"] as? [String: Any] else {
        let error = NSError(
            domain: "AppErrorDomain",
            code: -1,
            userInfo: [
                NSLocalizedDescriptionKey: "Unable to retrieve tag from snapshot \(packageDocument)"
            ]
        )
        errorPointer?.pointee = error
        print(error)
        throw error
    }
    
    guard let headline = packageDocument.data()?["headline"] as? String else {
        let error = NSError(
            domain: "AppErrorDomain",
            code: -1,
            userInfo: [
                NSLocalizedDescriptionKey: "Unable to retrieve headline from snapshot \(packageDocument)"
            ]
        )
        errorPointer?.pointee = error
        print(error)
        throw error
    }
    
    guard let coverPicUrl = packageDocument.data()?["cover_pic_url"] as? String else {
        let error = NSError(
            domain: "AppErrorDomain",
            code: -1,
            userInfo: [
                NSLocalizedDescriptionKey: "Unable to retrieve cover_pic_url from snapshot \(packageDocument)"
            ]
        )
        errorPointer?.pointee = error
        print(error)
        throw error
    }
    
    guard let countMovers = ((packageDocument.data()! as [String: Any])["count"] as! [String: Int])["movers"] else {
        let error = NSError(
            domain: "AppErrorDomain",
            code: -1,
            userInfo: [
                NSLocalizedDescriptionKey: "Unable to retrieve movers from snapshot \(packageDocument)"
            ]
        )
        errorPointer?.pointee = error
        print(error)
        throw error
    }
    
    guard let status = packageDocument.data()?["status"] as? String else {
        let error = NSError(
            domain: "AppErrorDomain",
            code: -1,
            userInfo: [
                NSLocalizedDescriptionKey: "Unable to retrieve status from snapshot \(packageDocument)"
            ]
        )
        errorPointer?.pointee = error
        print(error)
        throw error
    }
    
    guard let geoloc = packageDocument.data()?["_geoloc"] as? GeoPoint else {
        let error = NSError(
            domain: "AppErrorDomain",
            code: -1,
            userInfo: [
                NSLocalizedDescriptionKey: "Unable to retrieve _geoloc from snapshot \(packageDocument)"
            ]
        )
        errorPointer?.pointee = error
        print(error)
        throw error
    }
    
    transaction.setData(
        [
            "package_reference": packageReference,
            "tag": tag,
            "headline": headline,
            "cover_pic_url": coverPicUrl,
            "followed_date": Timestamp(date: Date()),
            "count": [
                "followers": newCountFollowers,
                "movers": countMovers
            ],
            "updatesCount": [
                "progress_events": 0,
                "unread_progress_events": 0,
                "posts_events": 0,
                "unread_posts_events": 0
            ],
            "status": status,
            "_geoloc": geoloc,
            ],
        forDocument: userReference.collection("packages_following").document(packageReference.documentID)
    )
}
