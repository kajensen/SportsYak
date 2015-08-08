//
//  PFNFLTeam.swift
//  SportsYak
//
//  Created by Kurt Jensen on 8/7/15.
//  Copyright (c) 2015 Arbor Apps. All rights reserved.
//

import UIKit
import Parse

class PFNFLTeam: PFObject, PFSubclassing {
    
    class func parseClassName() -> String {
        return "NFLTeam"
    }
    
    @NSManaged var name: PFMember!
    @NSManaged var location: PFGeoPoint!
    @NSManaged var locationName: String!

}
