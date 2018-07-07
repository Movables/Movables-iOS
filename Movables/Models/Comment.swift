//
//  Comment.swift
//  Movables
//
//  Created by Eddie Chen on 4/20/18.
//  Copyright © 2018 Movables, Inc. All rights reserved.
//

import Foundation
import Firebase

class Comment {
    var author: [String: Any]!
    var content: [String: Any]!
    var createdDate: Date!

    init(dict: [String: Any], ref: DocumentReference) {
        author = dict["author"] as! [String: Any]
        content = dict["content"] as! [String: Any]
        createdDate = (dict["created_date"] as! Timestamp).dateValue()
    }

}
