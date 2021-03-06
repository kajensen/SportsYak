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
    case MLB
    case NBA
    
    case count
    var className : String {
        switch self {
        case .NFL:
            return "NFLTeam"
        case .MLB:
            return "MLBTeam"
        case .NBA:
            return "NBATeam"
        default:
            return ""
        }
    }
    var imageIdentifier : String {
        switch self {
        case .NFL:
            return "Football-100"
        case .MLB:
            return "Baseball-100"
        case .NBA:
            return "Basketball-100"
        default:
            return ""
        }
    }
}

class PFTeam: PFObject {
   
    @NSManaged var name: String!
    @NSManaged var location: PFGeoPoint!
    @NSManaged var locationName: String!
    @NSManaged var teamType: Int
    @NSManaged var colorMainHex: String!
    @NSManaged var colorSecondaryHex: String!
    
}
