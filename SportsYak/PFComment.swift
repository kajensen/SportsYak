//
//  PFComment.swift
//  SportsYak
//
//  Created by Kurt Jensen on 8/7/15.
//  Copyright (c) 2015 Arbor Apps. All rights reserved.
//

import UIKit
import Parse

class PFComment: PFObject, PFSubclassing {
    
    class func parseClassName() -> String {
        return "Comment"
    }
    
    @NSManaged var user: PFMember!
    @NSManaged var location: PFGeoPoint!
    @NSManaged var post: PFPost!
    @NSManaged var text: String!
    @NSManaged var votes: Int
    @NSManaged var upVotes: [String]
    @NSManaged var downVotes: [String]
    @NSManaged var flags: [String]
    
    convenience init(post: PFPost, text : String) {
        self.init()
        if let user = PFMember.currentUser() {
            self.user = user
        }
        if let location = SharedLocationManager.sharedInstance.location {
            self.location = PFGeoPoint(location: location)
        }
        self.post = post
        self.text = text
        self.votes = 0
        self.upVotes = [String]()
        self.downVotes = [String]()
        self.flags = [String]()
    }
    
    func upVote() {
        if let user = PFMember.currentUser() {
            if let userId = user.objectId {
                if contains(self.upVotes, userId) {
                    PFCloud.callFunctionInBackground("removeUpVote", withParameters: ["userObjectId":userId,"commentObjectId":self.objectId!], block: { (object, error) -> Void in
                        if (error == nil) {
                            println("removed upvote for comment \(self.objectId)")
                        }
                    })
                    if let index = find(self.upVotes, userId) {
                        self.upVotes.removeAtIndex(index)
                    }
                    self.votes -= 1
                }
                else {
                    var shouldRemove = contains(self.downVotes, userId)
                    PFCloud.callFunctionInBackground("addUpVote", withParameters: ["userObjectId":userId,"commentObjectId":self.objectId!,"shouldRemove":shouldRemove], block: { (object, error) -> Void in
                        if (error == nil) {
                            println("added upvote for comment \(self.objectId)")
                        }
                    })
                    self.upVotes.append(userId)
                    if (shouldRemove) {
                        if let index = find(self.downVotes, userId) {
                            self.downVotes.removeAtIndex(index)
                        }
                    }
                    var votes = (shouldRemove ? 2 : 1)
                    self.votes += votes
                }
            }
            
            
        }
    }
    
    func downVote() {
        if let user = PFMember.currentUser() {
            if let userId = user.objectId {
                if contains(self.downVotes, userId) {
                    PFCloud.callFunctionInBackground("removeDownVote", withParameters: ["userObjectId":userId,"commentObjectId":self.objectId!], block: { (object, error) -> Void in
                        if (error == nil) {
                            println("removed downvote for comment \(self.objectId)")
                        }
                    })
                    if let index = find(self.downVotes, userId) {
                        self.downVotes.removeAtIndex(index)
                    }
                    self.votes -= 1
                }
                else {
                    var shouldRemove = contains(self.upVotes, userId)
                    PFCloud.callFunctionInBackground("addDownVote", withParameters: ["userObjectId":userId,"commentObjectId":self.objectId!,"shouldRemove":shouldRemove], block: { (object, error) -> Void in
                        if (error == nil) {
                            println("added downvote for comment \(self.objectId)")
                        }
                    })
                    self.downVotes.append(userId)
                    if (shouldRemove) {
                        if let index = find(self.upVotes, userId) {
                            self.upVotes.removeAtIndex(index)
                        }
                    }
                    var votes = (shouldRemove ? 2 : 1)
                    self.votes -= votes
                }
            }
        }
    }
    
    class func queryWithPost(post : PFPost) -> PFQuery? {
        if let query1 = PFComment.query() {
            query1.whereKey("post", equalTo: post)
            if let query2 = PFComment.query() {
                query2.whereKey("objectId", containedIn: post.comments)
                
                let query = PFQuery.orQueryWithSubqueries([query1, query2])
                query.orderByDescending("createdAt")
                return query
            }
        }
        return nil
    }
    
    class func queryForUserComments(user: PFMember) -> PFQuery? {
        var query = PFComment.query()
        query!.limit = 100
        query!.orderByDescending("createdAt")
        query!.whereKey("user", equalTo: user)
        return query
    }

}
