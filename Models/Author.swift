//
//  Author.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/12/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import FirebaseAuth

struct Author: FirebaseConvertible, Equatable {
    
    init?(user: User) {
        self.init(dictionary: user.dictionaryRepresentation)
    }
    
    init?(dictionary: [String: Any]) {
        guard let uid = dictionary[Author.uidKey] as? String,
            let displayName = dictionary[Author.displayNameKey] as? String else { return nil }
        
        self.uid = uid
        self.displayName = displayName
    }
    
    let uid: String
    let displayName: String?
    
    private static let uidKey = "uid"
    private static let displayNameKey = "displayName"
    
    var dictionaryRepresentation: [String: Any] {
        return [Author.uidKey: uid,
                Author.displayNameKey: displayName ?? "No display name"]
    }
}
