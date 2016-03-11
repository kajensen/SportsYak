//
//  MeViewController.swift
//  SportsYak
//
//  Created by Kurt Jensen on 8/7/15.
//  Copyright (c) 2015 Arbor Apps. All rights reserved.
//

import UIKit
import Parse

enum MeType: Int {
    case Notifications = 0
    case MyStuff
}

class MeViewController: HideBarsOnSwipeViewController, UITableViewDataSource, UITableViewDelegate, PostTableViewCellDelegate {

    var notifications = [PFNotification]()
    var posts : [PFPost]?
    var comments : [PFComment]?
    var myStuff = [PFObject]()
    var meType = MeType.Notifications
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData(false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    override func loadData(forceDownload: Bool) {
        if let user = PFMember.currentUser() {
            if let _ = user.objectId {
                if (self.meType == MeType.Notifications) {
                    if (self.notifications.count > 0 && !forceDownload) {
                        self.setupData(self.notifications)
                    }
                    else {
                        if let query = PFNotification.query() {
                            query.whereKey("user", equalTo: user)
                            query.includeKey("post")
                            query.includeKey("comment")
                            query.includeKey("comment.post")
                            query.orderByDescending("createdAt")
                            query.findObjectsInBackgroundWithBlock({
                                (objects, error) -> Void in
                                
                                if error == nil {
                                    print("Successfully retrieved \(objects!.count) notifications.")
                                    if let objects = objects as? [PFNotification] {
                                        self.notifications = objects
                                        self.setupData(self.notifications)
                                    }
                                } else {
                                    print("Error: \(error!) \(error!.userInfo)")
                                }
                            })
                        }
                    }
                }
                else {
                    if ((self.posts != nil) && (self.comments != nil) && !forceDownload) {
                        self.setupMyStuff()
                    }
                    else {
                        if let query = PFComment.query() {
                            query.whereKey("user", equalTo: user)
                            query.includeKey("post")
                            query.orderByDescending("createdAt")
                            query.findObjectsInBackgroundWithBlock({
                                (objects, error) -> Void in
                                
                                if error == nil {
                                    print("Successfully retrieved \(objects!.count) comments.")
                                    if let objects = objects as? [PFComment] {
                                        self.comments = objects
                                        self.setupMyStuff()
                                    }
                                } else {
                                    print("Error: \(error!) \(error!.userInfo)")
                                }
                            })
                        }
                        if let query = PFPost.query() {
                            query.whereKey("user", equalTo: user)
                            query.orderByDescending("createdAt")
                            query.findObjectsInBackgroundWithBlock({
                                (objects, error) -> Void in
                                
                                if error == nil {
                                    print("Successfully retrieved \(objects!.count) posts.")
                                    if let objects = objects as? [PFPost] {
                                        self.posts = objects
                                        self.setupMyStuff()
                                    }
                                } else {
                                    print("Error: \(error!) \(error!.userInfo)")
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    
    func setupMyStuff() {
        if ((self.posts != nil) && (self.comments != nil)) {
            var myStuff = self.posts!
            for comment in self.comments! {
                if let post = comment.post {
                    var shouldAdd = true
                    for p in self.posts! {
                        if (p.objectId == post.objectId) {
                            shouldAdd = false
                        }
                    }
                    if (shouldAdd) { //don't add duplicates for multiple comments!
                        myStuff.append(post)
                    }
                }
            }
            let data = myStuff.sort({ (obj1: PFObject, obj2: PFObject) -> Bool in
                return obj1.createdAt!.compare(obj2.createdAt!) == .OrderedAscending
                })
            self.setupData(data)
        }
    }
    
    func setupData(data : [PFObject]) {
        if (self.myStuff != data) {
            self.myStuff = data
            self.tableView.reloadData()
        }
        self.refreshFinished()
    }
    
    /*override func viewDidLayoutSubviews() {
        if let button = self.buttonGroupView.buttons.first {
            self.buttonGroupView.tapped(button)
        }
    }*/

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myStuff.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let _ = self.myStuff[indexPath.row] as? PFNotification {
            return 60
        }
        else if let post = self.myStuff[indexPath.row] as? PFPost {
            return self.heightForCellForPost(post)
        }
        else if let comment = self.myStuff[indexPath.row] as? PFComment {
            return self.heightForCellForPost(comment.post)
        }
        return tableView.rowHeight
    }
    
    func heightForCellForPost(post : PFPost) -> CGFloat {
        let fixedWidth = self.tableView.contentSize.width - 64 //width of cell, 8*3 padding 40 (vote view)
        let standardHeight : CGFloat = 23 //base height of textview
        let textView = UITextView()
        //textView.font = [UIFont fontWithName:@"Myriad Pro" size:13.0f];
        textView.text = post.text
        textView.scrollEnabled = false
        let expectedSize = textView.sizeThatFits(CGSizeMake(fixedWidth, CGFloat(MAXFLOAT)))
        var newHeight = expectedSize.height
        if (standardHeight > newHeight) {
            newHeight = standardHeight
        }
        let height = self.tableView.rowHeight - standardHeight + newHeight
        return height
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let notification = self.myStuff[indexPath.row] as? PFNotification {
            let cell = tableView.dequeueReusableCellWithIdentifier("NotificationCell", forIndexPath: indexPath) as! NotificationTableViewCell
            cell.configureWithNotification(notification)
            
            return cell
        }
        else if let post = self.myStuff[indexPath.row] as? PFPost {
            let cell = tableView.dequeueReusableCellWithIdentifier("PostCell", forIndexPath: indexPath) as! PostTableViewCell
            var readonly = true
            if let user = PFMember.currentUser() {
                readonly = !user.hasTeamId(post.teamId)
            }
            cell.configureWithPost(post, readonly: readonly)
            cell.delegate = self
            
            return cell
        }
        else if let comment = self.myStuff[indexPath.row] as? PFComment {
            let post = comment.post
            let cell = tableView.dequeueReusableCellWithIdentifier("PostCell", forIndexPath: indexPath) as! PostTableViewCell
            var readonly = true
            if let user = PFMember.currentUser() {
                readonly = !user.hasTeamId(post.teamId)
            }
            cell.configureWithPost(post, readonly: readonly)
            cell.delegate = self
            
            return cell
        }
        return UITableViewCell()
    }
    
    
    func postTableViewCellSelectButton(cell: PostTableViewCell, post: PFPost, actionType: PostActionType) {
        if (actionType == PostActionType.UpVote) {
            post.upVote()
            if let indexPath = self.tableView.indexPathForCell(cell) {
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
        }
        else if (actionType == PostActionType.DownVote) {
            post.downVote()
            if let indexPath = self.tableView.indexPathForCell(cell) {
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
        }
    }

    @IBAction func segmentedControlChanged(sender: UISegmentedControl) {
        self.meType = MeType(rawValue: sender.selectedSegmentIndex) ?? MeType.Notifications
        loadData(false)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "ViewComments") {
            if let postViewController = segue.destinationViewController as? PostViewController {
                if let cell = sender as? PostTableViewCell {
                    if let indexPath = self.tableView.indexPathForCell(cell) {
                        if let post = self.myStuff[indexPath.row] as? PFPost {
                            postViewController.post = post
                        }
                        else if let comment = self.myStuff[indexPath.row] as? PFComment {
                            postViewController.post = comment.post
                        }
                    }
                }
            }
        }
        else if (segue.identifier == "ViewNotification") {
            if let postViewController = segue.destinationViewController as? PostViewController {
                if let cell = sender as? NotificationTableViewCell {
                    if let indexPath = self.tableView.indexPathForCell(cell) {
                        if let notification = self.myStuff[indexPath.row] as? PFNotification {
                            if let post = notification.post {
                                postViewController.post = post
                            }
                            else if let comment = notification.comment {
                                postViewController.post = comment.post
                            }
                        }
                    }
                }
            }
        }
    }
}
