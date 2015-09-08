//
//  PFFlag.swift
//  SportsYak
//
//  Created by Kurt Jensen on 9/8/15.
//  Copyright (c) 2015 Arbor Apps. All rights reserved.
//

import UIKit
import Parse

enum FlagType: Int {
    case Offensive = 0
    case Personal
    case Spam
    case Other
}

class PFFlag: PFObject, PFSubclassing {
    
    @NSManaged var user: PFMember!
    @NSManaged var post: PFPost?
    @NSManaged var comment: PFComment?
    @NSManaged var flagType: Int
    
    class func parseClassName() -> String {
        return "Flag"
    }
    
    convenience init(post: PFPost?, comment : PFComment?, flagType : FlagType) {
        self.init()
        if let user = PFMember.currentUser() {
            self.user = user
        }
        if (comment != nil) {
            self.comment = comment
        }
        if (post != nil) {
            self.post = post
        }
        self.flagType = flagType.rawValue
    }
    
}