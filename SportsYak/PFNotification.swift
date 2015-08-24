//
//  PFNotification.swift
//  SportsYak
//
//  Created by Kurt Jensen on 8/23/15.
//  Copyright (c) 2015 Arbor Apps. All rights reserved.
//

import UIKit
import Parse

class PFNotification: PFObject, PFSubclassing {
    
    @NSManaged var user: PFMember!
    @NSManaged var post: PFPost?
    @NSManaged var comment: PFComment?
    @NSManaged var message: String!
    
    class func parseClassName() -> String {
        return "Notification"
    }
}
