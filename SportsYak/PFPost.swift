//
//  PFPost.swift
//  SportsYak
//
//  Created by Kurt Jensen on 8/7/15.
//  Copyright (c) 2015 Arbor Apps. All rights reserved.
//

import UIKit
import Parse

enum PostType: Int {
    case Nearby = 0
    case MySquads
    case TeamOne
    case TeamTwo
}

enum PostSort: Int {
    case New = 0
    case Hot
}

let FIVE_HOURS : NSTimeInterval = 18000

class PFPost: PFObject, PFSubclassing {
    
    class func parseClassName() -> String {
        return "Post"
    }
    
    @NSManaged var user: PFMember!
    @NSManaged var location: PFGeoPoint!
    @NSManaged var teamId: String!
    @NSManaged var title: String!
    @NSManaged var text: String!
    @NSManaged var votes: Int
    @NSManaged var upVotes: [String]
    @NSManaged var downVotes: [String]
    @NSManaged var comments: [PFComment]
    
    override init() {
        super.init()
    }
    
    convenience init(team: PFObject?, title : String, text : String) {
        self.init()
        if let user = PFMember.currentUser() {
            self.user = user
        }
        if let location = SharedLocationManager.sharedInstance.location {
            self.location = PFGeoPoint(location: location)
        }
        if team != nil {
            if let teamId = team!.objectId {
                self.teamId = teamId
            }
        }

        self.title = title
        self.text = text
        self.votes = 0
        self.upVotes = [String]()
        self.downVotes = [String]()
        self.comments = [PFComment]()
    }
    
    class func queryWithMyTeams(postSort : PostSort) -> PFQuery? {
        if let user = PFMember.currentUser() {
            let userTeams = user.teamIds()
            if (userTeams.count > 0) {
                println("fetching posts for teams: \(userTeams)")
                var query = PFPost.query()
                //query!.includeKey("comments")
                query!.whereKey("teamId", containedIn: userTeams)
                if (postSort == PostSort.New) {
                    query!.orderByDescending("createdAt")
                }
                else if (postSort == PostSort.Hot) {
                    query!.orderByDescending("votes")
                }
                query!.limit = 100
                query!.whereKey("createdAt", greaterThan: NSDate(timeIntervalSinceNow: -FIVE_HOURS))
                return query
            }
        }
        return nil
    }
    
    class func queryWithNearby(postSort : PostSort) -> PFQuery? {
        if let user = PFMember.currentUser() {
            if let location = user.location {
                println("fetching nearby posts")
                var query = PFPost.query()
                //query!.includeKey("comments")
                query!.whereKey("location", nearGeoPoint: location, withinMiles: 10.0)
                if (postSort == PostSort.New) {
                    query!.orderByDescending("createdAt")
                }
                else if (postSort == PostSort.Hot) {
                    query!.orderByDescending("votes")
                }
                query!.limit = 100
                query!.whereKey("createdAt", greaterThan: NSDate(timeIntervalSinceNow: -FIVE_HOURS))
                return query
            }
        }
        return nil
    }
    
    class func queryWithEvent(event : PFEvent, postType: PostType, postSort : PostSort) -> PFQuery? {
        if let type = TeamType(rawValue: event.teamType) {
            let className = type.className
            println("fetching event posts")
            var teamId : String
            if (postType == PostType.TeamOne) {
                teamId = event.teamOneId
            }
            else {
                teamId = event.teamTwoId
            }
            var query = PFPost.query()
            if (postSort == PostSort.New) {
                query!.orderByDescending("createdAt")
            }
            else if (postSort == PostSort.Hot) {
                query!.orderByDescending("votes")
            }
            query!.limit = 100
            query!.whereKey("createdAt", greaterThan: NSDate(timeIntervalSinceNow: -FIVE_HOURS))
            query!.whereKey("teamId", equalTo: teamId)
            return query
        }

        return nil
    }
    
    func replyString() -> String {
        if (self.comments.count == 0) {
            return ""
        }
        else if (self.comments.count == 1) {
            return "1 reply"
        }
        else {
            return "\(self.comments.count) replies"
        }
    }
    
}
