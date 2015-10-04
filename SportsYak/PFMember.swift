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
    @NSManaged var showNFL: Bool
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
        return teams
    }
    
    func teamIds() -> [String] {
        var teamIds = [String]()
        if (showNFL && nflTeam != nil) {
            if let nflTeamId = nflTeam!.objectId {
                teamIds.append(nflTeamId)
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
            default:
                print("uh oh, no team")
        }
        return nil
    }
    
    func addTeam(team : PFObject?) {
        if let nflTeam = team as? PFNFLTeam {
            self.nflTeam = nflTeam
            self.showNFL = true
        }
    }
    
    func isOn(team : PFObject) -> Bool {
        if (self.nflTeam?.objectId == team.objectId) {
            return self.showNFL
        }
        return false
    }
    
    func turnOffTeam(team : PFObject) {
        if (self.nflTeam?.objectId == team.objectId) {
            self.showNFL = false
        }
    }
    
    func turnOnTeam(team : PFObject) {
        if (self.nflTeam?.objectId == team.objectId) {
            self.showNFL = true
        }
    }

    class func queryWithIncludes() -> PFQuery? {
        let query = PFMember.query()
        if (query != nil) {
            query!.includeKey("nflTeam")
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
