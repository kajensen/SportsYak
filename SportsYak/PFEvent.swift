//
//  PFEvent.swift
//  SportsYak
//
//  Created by Kurt Jensen on 8/7/15.
//  Copyright (c) 2015 Arbor Apps. All rights reserved.
//

import UIKit
import Parse

class PFEvent: PFObject, PFSubclassing {
    
    class func parseClassName() -> String {
        return "Event"
    }
    
    @NSManaged var teamOneId: String!
    @NSManaged var teamTwoId: String!
    @NSManaged var teamType: Int
    @NSManaged var teamOneName: String!
    @NSManaged var teamTwoName: String!
    @NSManaged var date: NSDate!
    @NSManaged var votes: Int
    @NSManaged var live: Bool
    
}