//
//  utils.swift
//  Movables
//
//  Created by Eddie Chen on 5/14/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import Foundation
import Firebase

let packageCategoriesStringArray = [
    "animals",
    "arts_culture_humanities",
    "community_development",
    "education",
    "environment",
    "health",
    "human_and_civil_rights",
    "human_services",
    "international",
    "research_and_public_policy",
    "religion"
]

let packageCategoriesEnumArray:[PackageCategory] = [.animals, .arts_culture_humanities, .community_development, .education, .environment, .health, .human_and_civil_rights, .human_services, .international, .research_and_public_policy, .religion]

func getEmojiForCategory(category: PackageCategory) -> String{
    switch category {
    case .animals:
        return "🐶"
    case .arts_culture_humanities:
        return "🎨"
    case .community_development:
        return "🏘"
    case .education:
        return "🎓"
    case .environment:
        return "🌳"
    case .health:
        return "🏥"
    case .human_and_civil_rights:
        return "✊"
    case .human_services:
        return "🛌"
    case .international:
        return "🌍"
    case .research_and_public_policy:
        return "🏛"
    case .religion:
        return "🙏"
    default:
        return "🤗"
    }
}

func getTintForCategory(category: PackageCategory) -> UIColor{
    switch category {
    case .animals:
        return UIColor(red:0.000, green: 0.516, blue: 0.844, alpha: 1.000)
    case .arts_culture_humanities:
        return UIColor(red:0.000, green: 0.717, blue: 0.327, alpha: 1.000)
    case .community_development:
        return UIColor(red:0.578, green: 0.331, blue: 0.116, alpha: 1.000)
    case .education:
        return UIColor(red:0.078, green: 0.800, blue: 0.694, alpha: 1.000)
    case .environment:
        return UIColor(red:0.721, green: 0.766, blue: 0.000, alpha: 1.000)
    case .health:
        return UIColor(red:0.545, green: 0.557, blue: 0.549, alpha: 1.000)
    case .human_and_civil_rights:
        return UIColor(red:0.800, green: 0.031, blue: 0.000, alpha: 1.000)
    case .human_services:
        return UIColor(red:0.313, green: 0.627, blue: 1.000, alpha: 1.000)
    case .international:
        return UIColor(red:0.856, green: 0.389, blue: 0.722, alpha: 1.000)
    case .research_and_public_policy:
        return UIColor(red:0.372, green: 0.730, blue: 0.634, alpha: 1.000)
    case .religion:
        return UIColor(red:0.846, green: 0.435, blue: 0.000, alpha: 1.000)
    default:
        return .white
    }
}



func getTintForPackageStatus(packageStatus: PackageStatus) -> UIColor {
    switch packageStatus {
    case .pending:
        return Theme().affirmativeTint
    case .delivered:
        return Theme().mapStampTint
    case .transit:
        return Theme().staticTint
    default:
        return Theme().borderColor
    }
}

func getReadableStringForCategory(category: PackageCategory) -> String{
    switch category {
    case .animals:
        return String(NSLocalizedString("copy.category.animals", comment: "label text for category animals"))
    case .arts_culture_humanities:
        return String(NSLocalizedString("copy.category.arts_culture_humanities", comment: "label text for category arts, culture and humanities"))
    case .community_development:
        return String(NSLocalizedString("copy.category.community_development", comment: "label text for category community development"))
    case .education:
        return String(NSLocalizedString("copy.category.education", comment: "label text for category education"))
    case .environment:
        return String(NSLocalizedString("copy.category.environment", comment: "label text for category environment"))
    case .health:
        return String(NSLocalizedString("copy.category.health", comment: "label text for category health"))
    case .human_and_civil_rights:
        return String(NSLocalizedString("copy.category.human_and_civil_rights", comment: "label text for category human and civil rights"))
    case .human_services:
        return String(NSLocalizedString("copy.category.human_services", comment: "label text for category human services"))
    case .international:
        return String(NSLocalizedString("copy.category.international", comment: "label text for category international"))
    case .research_and_public_policy:
        return String(NSLocalizedString("copy.category.research_and_public_policy", comment: "label text for category research and public policy"))
    case .religion:
        return String(NSLocalizedString("copy.category.religion", comment: "label text for category religion"))
    default:
        return "Unknown"
    }
}

func getCategoryEnumFromReadable(with readableString: String) -> PackageCategory {
    switch readableString {
    case "Animals":
        return .animals
    case "Arts, Culture, Humanities":
        return .arts_culture_humanities
    case "Community Development":
        return .community_development
    case "Education":
        return .education
    case "Environment":
        return .environment
    case "Health":
        return .health
    case "Human and Civil Rights":
        return .human_and_civil_rights
    case "Human Services":
        return .human_services
    case "International":
        return .international
    case "Research and Public Policy":
        return .research_and_public_policy
    case "Religion":
        return .religion
    default:
        return .unknown
    }
}


func getStringForCategory(category: PackageCategory) -> String{
    switch category {
    case .animals:
        return "animals"
    case .arts_culture_humanities:
        return "arts_culture_humanities"
    case .community_development:
        return "community_development"
    case .education:
        return "education"
    case .environment:
        return "environment"
    case .health:
        return "health"
    case .human_and_civil_rights:
        return "human_and_civil_rights"
    case .human_services:
        return "human_services"
    case .international:
        return "international"
    case .research_and_public_policy:
        return "research_and_public_policy"
    case .religion:
        return "religion"
    default:
        return "unknown"
    }
}


func getCategoryEnum(with string: String) -> PackageCategory {
    switch string {
    case "animals":
        return .animals
    case "arts_culture_humanities":
        return .arts_culture_humanities
    case "community_development":
        return .community_development
    case "education":
        return .education
    case "environment":
        return .environment
    case "health":
        return .health
    case "human_and_civil_rights":
        return .human_and_civil_rights
    case "human_services":
        return .human_services
    case "international":
        return .international
    case "research_and_public_policy":
        return .research_and_public_policy
    case "religion":
        return .religion
    default:
        return .unknown
    }
}

func getStatusEnum(with string: String) -> PackageStatus {
    switch string {
    case "pending":
        return .pending
    case "transit":
        return .transit
    case "delivered":
        return .delivered
    default:
        return .unknown
    }
}

func fetchUserDoc(uid: String, completion: @escaping (UserDocument?) -> ()) {
    Firestore.firestore().collection("users").whereField("public_profile.uid", isEqualTo: uid).limit(to: 1).getDocuments { (querySnapshot, error) in
        if let error = error as NSError? {
            print(error)
            completion(nil)
        } else {
            if let userDocData = querySnapshot?.documents.first?.data() {
                completion(UserDocument(with: userDocData, reference:querySnapshot!.documents.first!.reference))
            } else {
                // show error retrieving user doc
                print("error")
                completion(nil)
            }
        }
    }
}
