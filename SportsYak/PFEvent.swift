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
    @NSManaged var mlbTeamOne: PFTeam?
    @NSManaged var mlbTeamTwo: PFTeam?
    @NSManaged var nbaTeamOne: PFTeam?
    @NSManaged var nbaTeamTwo: PFTeam?
    @NSManaged var teamType: Int
    @NSManaged var date: NSDate!
    @NSManaged var votes: Int
    
    func teamOneId() -> String? {
        var teamOneId : String?
        if (TeamType(rawValue: teamType) == .NFL) {
            if (nflTeamOne != nil) {
                teamOneId = nflTeamOne!.objectId
            }
        } else if (TeamType(rawValue: teamType) == .MLB) {
            if (mlbTeamOne != nil) {
                teamOneId = mlbTeamOne!.objectId
            }
        } else if (TeamType(rawValue: teamType) == .NBA) {
            if (nbaTeamOne != nil) {
                teamOneId = nbaTeamOne!.objectId
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
        } else if (TeamType(rawValue: teamType) == .MLB) {
            if (mlbTeamOne != nil) {
                teamTwoId = mlbTeamTwo!.objectId
            }
        } else if (TeamType(rawValue: teamType) == .NBA) {
            if (nbaTeamOne != nil) {
                teamTwoId = nbaTeamTwo!.objectId
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
        } else if (TeamType(rawValue: teamType) == .MLB) {
            if (mlbTeamOne != nil) {
                teamOneId = mlbTeamOne!.name
            }
        } else if (TeamType(rawValue: teamType) == .NBA) {
            if (nbaTeamOne != nil) {
                teamOneId = nbaTeamOne!.name
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
        } else if (TeamType(rawValue: teamType) == .MLB) {
            if (mlbTeamTwo != nil) {
                teamTwoId = mlbTeamTwo!.name
            }
        } else if (TeamType(rawValue: teamType) == .NBA) {
            if (nbaTeamTwo != nil) {
                teamTwoId = nbaTeamTwo!.name
            }
        }
        return teamTwoId
    }
    
}
