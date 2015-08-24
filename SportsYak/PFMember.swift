//
//  PFMember.swift
//  SportsYak
//
//  Created by Kurt Jensen on 8/7/15.
//  Copyright (c) 2015 Arbor Apps. All rights reserved.
//

import UIKit
import Parse

class PFMember: PFUser, PFSubclassing {
    
    @NSManaged var karma: Int
    @NSManaged var url: String!
    @NSManaged var location: PFGeoPoint!
    @NSManaged var nflTeam: PFNFLTeam!
    @NSManaged var showNFL: Bool
    @NSManaged var mutedUserIds: [String]

    func setup() {
        self.karma = 0
        self.mutedUserIds = [String]()
    }
    
    func teams() -> [PFObject] {
        var teams = [PFObject]()
        if (showNFL && nflTeam != nil) {
            teams.append(nflTeam)
        }
        return teams
    }
    
    func teamIds() -> [String] {
        var teamIds = [String]()
        if (showNFL && nflTeam != nil) {
            if let nflTeamId = nflTeam.objectId {
                teamIds.append(nflTeamId)
            }
        }
        return teamIds
    }

    func teamForType(type : TeamType) -> PFObject? {
        switch type {
            case TeamType.NFL:
                return self.nflTeam
            default:
                println("uh oh, no team")
        }
        return nil
    }
    
    func addTeam(team : PFObject?) {
        if let nflTeam = team as? PFNFLTeam {
            self.nflTeam = nflTeam
            self.showNFL = true
        }
    }
    
    func isOn(team : PFObject?) -> Bool {
        if (self.nflTeam.objectId == team!.objectId) {
            return self.showNFL
        }
        return false
    }
    
    func turnOffTeam(team : PFObject?) {
        if (self.nflTeam.objectId == team!.objectId) {
            self.showNFL = false
        }
    }
    
    func turnOnTeam(team : PFObject?) {
        if (self.nflTeam.objectId == team!.objectId) {
            self.showNFL = true
        }
    }

    class func queryWithIncludes() -> PFQuery? {
        var query = PFMember.query()
        if (query != nil) {
            query!.includeKey("nflTeam")
        }
        return query
    }
}