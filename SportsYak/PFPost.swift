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

let SIX_DAYS : NSTimeInterval = 518400

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
    @NSManaged var flags: Int

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
        self.flags = 0
    }
    
    func upVote() {
        if let user = PFMember.currentUser() {
            if let userId = user.objectId {
                if self.upVotes.contains(userId) {
                    PFCloud.callFunctionInBackground("removeUpVote", withParameters: ["userObjectId":userId,"postObjectId":self.objectId!], block: { (object, error) -> Void in
                        if (error == nil) {
                            print("removed upvote for post \(self.objectId)")
                        }
                    })
                    if let index = self.upVotes.indexOf(userId) {
                        self.upVotes.removeAtIndex(index)
                    }
                    self.votes -= 1
                }
                else {
                    let shouldRemove = self.downVotes.contains(userId)
                    PFCloud.callFunctionInBackground("addUpVote", withParameters: ["userObjectId":userId,"postObjectId":self.objectId!,"shouldRemove":shouldRemove], block: { (object, error) -> Void in
                        if (error == nil) {
                            print("added upvote for post \(self.objectId)")
                        }
                    })
                    self.upVotes.append(userId)
                    if (shouldRemove) {
                        if let index = self.downVotes.indexOf(userId) {
                            self.downVotes.removeAtIndex(index)
                        }
                    }
                    let votes = (shouldRemove ? 2 : 1)
                    self.votes += votes
                }
            }


        }
    }
    
    func downVote() {
        if let user = PFMember.currentUser() {
            if let userId = user.objectId {
                if self.downVotes.contains(userId) {
                    PFCloud.callFunctionInBackground("removeDownVote", withParameters: ["userObjectId":userId,"postObjectId":self.objectId!], block: { (object, error) -> Void in
                        if (error == nil) {
                            print("removed downvote for post \(self.objectId)")
                        }
                    })
                    if let index = self.downVotes.indexOf(userId) {
                        self.downVotes.removeAtIndex(index)
                    }
                    self.votes -= 1
                }
                else {
                    let shouldRemove = self.upVotes.contains(userId)
                    PFCloud.callFunctionInBackground("addDownVote", withParameters: ["userObjectId":userId,"postObjectId":self.objectId!,"shouldRemove":shouldRemove], block: { (object, error) -> Void in
                        if (error == nil) {
                            print("added downvote for post \(self.objectId)")
                        }
                    })
                    self.downVotes.append(userId)
                    if (shouldRemove) {
                        if let index = self.upVotes.indexOf(userId) {
                            self.upVotes.removeAtIndex(index)
                        }
                    }
                    let votes = (shouldRemove ? 2 : 1)
                    self.votes -= votes
                }
            }            
        }
    }
    
    class func queryWithMyTeams(postSort : PostSort) -> PFQuery? {
        if let user = PFMember.currentUser() {
            let userTeams = user.teamIds()
            if (userTeams.count > 0) {
                print("fetching posts for teams: \(userTeams)")
                let query = PFPost.query()
                //query!.includeKey("comments")
                query!.whereKey("teamId", containedIn: userTeams)
                if (postSort == PostSort.New) {
                    query!.orderByDescending("createdAt")
                }
                else if (postSort == PostSort.Hot) {
                    query!.orderByDescending("votes")
                }
                query!.limit = 100
                //query!.whereKey("createdAt", greaterThan: NSDate(timeIntervalSinceNow: -SIX_DAYS))
                return query
            }
        }
        return nil
    }
    
    class func queryWithNearby(postSort : PostSort) -> PFQuery? {
        if let user = PFMember.currentUser() {
            if let location = user.location {
                print("fetching nearby posts")
                let query = PFPost.query()
                //query!.includeKey("comments")
                query!.whereKey("location", nearGeoPoint: location, withinMiles: 10.0)
                if (postSort == PostSort.New) {
                    query!.orderByDescending("createdAt")
                }
                else if (postSort == PostSort.Hot) {
                    query!.orderByDescending("votes")
                }
                query!.limit = 100
                //query!.whereKey("createdAt", greaterThan: NSDate(timeIntervalSinceNow: -SIX_DAYS))
                return query
            }
        }
        return nil
    }

    class func queryWithEvent(event : PFEvent, postType: PostType, postSort : PostSort) -> PFQuery? {
        if let _ = TeamType(rawValue: event.teamType) {
            print("fetching event posts")
            var teamId : String?
            if (postType == PostType.TeamOne) {
                teamId = event.teamOneId()
            }
            else {
                teamId = event.teamTwoId()
            }
            let query = PFPost.query()
            if (postSort == PostSort.New) {
                query!.orderByDescending("createdAt")
            }
            else if (postSort == PostSort.Hot) {
                query!.orderByDescending("votes")
            }
            query!.limit = 100
            query!.whereKey("createdAt", greaterThan: NSDate(timeIntervalSinceNow: -SIX_DAYS))
            if (teamId != nil) {
                query!.whereKey("teamId", equalTo: teamId!)
                return query
            }
        }

        return nil
    }
    
    class func queryForUserPosts(user: PFMember) -> PFQuery? {
        let query = PFPost.query()
        query!.limit = 100
        query!.orderByDescending("createdAt")
        query!.whereKey("user", equalTo: user)
        return query
    }
    
    func flag(flagType : FlagType) {
        let flag = PFFlag(post: self, comment: nil, flagType: flagType)
        self.flags += 1
        flag.saveInBackground()
    }
    
    func mute() {
        if let user = PFMember.currentUser() {
            if (self.user != nil && self.user.objectId != user.objectId) {
                user.muteUser(self.user);
            }
        }
    }
    
    func shouldShow() -> Bool {
        var shouldShow = true
        if let user = PFMember.currentUser() {
            if (self.user.objectId != nil) {
                if (user.mutedUserIds.contains(self.user.objectId!)) {
                    shouldShow = false
                }
            }
        }
        return shouldShow
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
