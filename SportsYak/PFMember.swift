//
//  PFMember.swift
//  SportsYak
//
//  Created by Kurt Jensen on 8/7/15.
//  Copyright (c) 2015 Arbor Apps. All rights reserved.
//

import UIKit
import Parse

class PFMember: PFUser {
    
    @NSManaged var contentKarma: Int
    @NSManaged var voteKarma: Int
    @NSManaged var url: String!
    @NSManaged var location: PFGeoPoint?
    @NSManaged var nflTeam: PFNFLTeam?
    @NSManaged var mlbTeam: PFMLBTeam?
    @NSManaged var nbaTeam: PFNBATeam?
    @NSManaged var showNFL: Bool
    @NSManaged var showMLB: Bool
    @NSManaged var showNBA: Bool
    @NSManaged var mutedUserIds: [String]

    func setup() {
        self.contentKarma = 0
        self.voteKarma = 0
        self.mutedUserIds = [String]()
    }
    
    func addVoteKarma(points : Int) {
        self.voteKarma += points
        NSLog("Updating User VoteKarma to (\(points))")
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.NOTIFICATION_UPDATED_KARMA, object: nil)
    }

    func removeVoteKarma(points : Int) {
        self.voteKarma -= points
        NSLog("Updating User VoteKarma to (\(points))")
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.NOTIFICATION_UPDATED_KARMA, object: nil)
    }
    
    func resetContentKarma(points : Int) {
        self.contentKarma = points
        NSLog("Updating User ContentKarma to (\(points))")
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.NOTIFICATION_UPDATED_KARMA, object: nil)
    }

    func teams() -> [PFTeam] {
        var teams = [PFTeam]()
        if (showNFL && nflTeam != nil) {
            teams.append(nflTeam!)
        }
        if (showMLB && mlbTeam != nil) {
            teams.append(mlbTeam!)
        }
        if (showNBA && nbaTeam != nil) {
            teams.append(nbaTeam!)
        }
        return teams
    }
    
    func teamIds() -> [String] {
        var teamIds = [String]()
        if (showNFL && nflTeam != nil) {
            if let nflTeamId = nflTeam!.objectId {
                teamIds.append(nflTeamId)
            }
        }
        if (showMLB && mlbTeam != nil) {
            if let mlbTeamId = mlbTeam!.objectId {
                teamIds.append(mlbTeamId)
            }
        }
        if (showNBA && nbaTeam != nil) {
            if let showNBAId = nbaTeam!.objectId {
                teamIds.append(showNBAId)
            }
        }
        return teamIds
    }
    
    func hasTeamId(teamId : String) -> Bool {
        for tId in self.teamIds() {
            if (teamId == tId) {
                return true
            }
        }
        return false
    }

    func teamForType(type : TeamType) -> PFTeam? {
        switch type {
        case TeamType.NFL:
            return self.nflTeam
        case TeamType.NBA:
            return self.nbaTeam
        case TeamType.MLB:
            return self.mlbTeam
        default:
            print("uh oh, no team")
        }
        return nil
    }
    
    func addTeam(team : PFObject?) {
        if let nflTeam = team as? PFNFLTeam {
            self.nflTeam = nflTeam
            self.showNFL = true
        } else if let mlbTeam = team as? PFMLBTeam {
            self.mlbTeam = mlbTeam
            self.showMLB = true
        } else if let nbaTeam = team as? PFNBATeam {
            self.nbaTeam = nbaTeam
            self.showNBA = true
        }
    }
    
    func isOn(team : PFObject) -> Bool {
        if (self.nflTeam?.objectId == team.objectId) {
            return self.showNFL
        }
        if (self.nbaTeam?.objectId == team.objectId) {
            return self.showNBA
        }
        if (self.mlbTeam?.objectId == team.objectId) {
            return self.showMLB
        }
        return false
    }
    
    func turnOffTeam(team : PFObject) {
        if (self.nflTeam?.objectId == team.objectId) {
            self.showNFL = false
        }
        if (self.nbaTeam?.objectId == team.objectId) {
            self.showNBA = false
        }
        if (self.mlbTeam?.objectId == team.objectId) {
            self.showMLB = false
        }
    }
    
    func turnOnTeam(team : PFObject) {
        if (self.nflTeam?.objectId == team.objectId) {
            self.showNFL = true
        }
        if (self.nbaTeam?.objectId == team.objectId) {
            self.showNBA = true
        }
        if (self.mlbTeam?.objectId == team.objectId) {
            self.showMLB = true
        }
    }

    class func queryWithIncludes() -> PFQuery? {
        let query = PFMember.query()
        if (query != nil) {
            query!.includeKey("nflTeam")
            query!.includeKey("nbaTeam")
            query!.includeKey("mlbTeam")
        }
        return query
    }
    
    func muteUser(user : PFMember) {
        if (user.objectId != nil) {
            if (self.mutedUserIds.contains(user.objectId!)) {
                self.mutedUserIds.append(user.objectId!);
            }
        }
    }
}
