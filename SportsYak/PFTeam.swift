//
//  PFTeam.swift
//  SportsYak
//
//  Created by Kurt Jensen on 8/23/15.
//  Copyright (c) 2015 Arbor Apps. All rights reserved.
//

import UIKit
import Parse

enum TeamType: Int {
    case NFL = 0
    
    case count
    var className : String {
        switch self {
        case .NFL:
            return "NFLTeam"
        default:
            return "NFLTeam"
        }
    }
}

class PFTeam: PFObject {
   
    @NSManaged var name: PFMember!
    @NSManaged var location: PFGeoPoint!
    @NSManaged var locationName: String!
    
}
