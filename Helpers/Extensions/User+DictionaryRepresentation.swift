//
//  User+DictionaryRepresentation.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/12/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import FirebaseAuth

extension User {
    
    private static let uidKey = "uid"
    private static let displayNameKey = "displayName"
    
    var dictionaryRepresentation: [String: String] {
        return [User.uidKey: uid,
                User.displayNameKey: displayName ?? "No display name"]
    }
}
