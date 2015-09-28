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
    
    @NSManaged var nflTeamOne: PFTeam?
    @NSManaged var nflTeamTwo: PFTeam?
    @NSManaged var teamType: Int
    @NSManaged var date: NSDate!
    @NSManaged var votes: Int
    @NSManaged var isLive: Bool
    
    func teamOneId() -> String? {
        var teamOneId : String?
        if (TeamType(rawValue: teamType) == .NFL) {
            if (nflTeamOne != nil) {
                teamOneId = nflTeamOne!.objectId
            }
        }
        return teamOneId
    }
    
    func teamTwoId() -> String? {
        var teamTwoId : String?
        if (TeamType(rawValue: teamType) == .NFL) {
            if (nflTeamTwo != nil) {
                teamTwoId = nflTeamTwo!.objectId
            }
        }
        return teamTwoId
    }
    
    func teamOneName() -> String? {
        var teamOneId : String?
        if (TeamType(rawValue: teamType) == .NFL) {
            if (nflTeamOne != nil) {
                teamOneId = nflTeamOne!.name
            }
        }
        return teamOneId
    }
    
    func teamTwoName() -> String? {
        var teamTwoId : String?
        if (TeamType(rawValue: teamType) == .NFL) {
            if (nflTeamTwo != nil) {
                teamTwoId = nflTeamTwo!.name
            }
        }
        return teamTwoId
    }
    
}
