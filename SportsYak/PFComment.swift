//
//  PFComment.swift
//  SportsYak
//
//  Created by Kurt Jensen on 8/7/15.
//  Copyright (c) 2015 Arbor Apps. All rights reserved.
//

import UIKit
import Parse

class PFComment: PFObject, PFSubclassing {
    
    class func parseClassName() -> String {
        return "Comment"
    }
    
    @NSManaged var user: PFMember!
    @NSManaged var location: PFGeoPoint!
    @NSManaged var post: PFPost!
    @NSManaged var text: String!
    @NSManaged var votes: Int
    @NSManaged var upVotes: [String]
    @NSManaged var downVotes: [String]
    
    convenience init(post: PFPost, text : String) {
        self.init()
        if let user = PFMember.currentUser() {
            self.user = user
        }
        if let location = SharedLocationManager.sharedInstance.location {
            self.location = PFGeoPoint(location: location)
        }
        self.post = post
        self.text = text
        self.votes = 0
        self.upVotes = [String]()
        self.downVotes = [String]()
    }
    
}
