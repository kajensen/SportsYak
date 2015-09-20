//
//  MeViewController.swift
//  SportsYak
//
//  Created by Kurt Jensen on 8/7/15.
//  Copyright (c) 2015 Arbor Apps. All rights reserved.
//

import UIKit
import MapKit
import Parse

enum MeType: Int {
    case Notifications = 0
    case MyStuff
}

class MeViewController: HideBarsOnSwipeViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, PostTableViewCellDelegate {

    @IBOutlet var mapView: MKMapView!
    var notifications = [PFNotification]()
    var posts : [PFPost]?
    var comments : [PFComment]?
    var myStuff = [PFObject]()
    var meType = MeType.Notifications
    var hasShownPulses = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.loadData(false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if (!hasShownPulses) {
            hasShownPulses = true
            let pulseEffect = LFTPulseAnimation(repeatCount: Float.infinity, radius:20, position:self.mapView.center)
            pulseEffect.backgroundColor = Constants.GLOBAL_TINT.CGColor
            let pulseEffect2 = LFTPulseAnimation(repeatCount: Float.infinity, radius:40, position:self.mapView.center)
            pulseEffect2.backgroundColor = Constants.GLOBAL_TINT.CGColor
            let pulseEffect3 = LFTPulseAnimation(repeatCount: Float.infinity, radius:60, position:self.mapView.center)
            pulseEffect3.backgroundColor = Constants.GLOBAL_TINT.CGColor
            self.view.layer.insertSublayer(pulseEffect, above: self.mapView.layer)
            self.view.layer.insertSublayer(pulseEffect2, above: self.mapView.layer)
            self.view.layer.insertSublayer(pulseEffect3, above: self.mapView.layer)
        }
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
                                        for object in objects {
                                            print(object.objectId)
                                        }
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
                                        for object in objects {
                                            print(object.objectId)
                                        }
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
                                        for object in objects {
                                            print(object.objectId)
                                        }
                                        self.posts = objects
                                        self.setupMyStuff()
                                    }
                                } else {
                                    print("Error: \(error!) \(error!.userInfo)")
                                }
                            })
                        }
                        self.tableView.hidden = true
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
            self.tableView.hidden = false
        }
        self.refreshFinished()
    }
    
    /*override func viewDidLayoutSubviews() {
        if let button = self.buttonGroupView.buttons.first {
            self.buttonGroupView.tapped(button)
        }
    }*/
    
    func setupView() {
        if let location = SharedLocationManager.sharedInstance.location {
            let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 2000, 2000)
            self.mapView.setRegion(region, animated: false)
        }
    }

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
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var rows = 0
        if let user = PFMember.currentUser() {
            rows = user.teams().count
        }
        return rows
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TeamCell", forIndexPath: indexPath) as! TeamCollectionViewCell
        if let user = PFMember.currentUser() {
            let team = user.teams()[indexPath.row]
            cell.configureWithTeam(team)
            
            let cvPoint = collectionView.convertPoint(cell.center, toView: self.view)
            let pulseEffect = LFTPulseAnimation(repeatCount: Float.infinity, radius:10, position:cvPoint)
            pulseEffect.backgroundColor = UIColor(hexString: team.colorMainHex).CGColor
            let pulseEffect2 = LFTPulseAnimation(repeatCount: Float.infinity, radius:20, position:cvPoint)
            pulseEffect2.backgroundColor = UIColor(hexString: team.colorMainHex).CGColor
            let pulseEffect3 = LFTPulseAnimation(repeatCount: Float.infinity, radius:40, position:cvPoint)
            pulseEffect3.backgroundColor = UIColor(hexString: team.colorMainHex).CGColor
            self.view.layer.insertSublayer(pulseEffect, below: collectionView.layer)
            self.view.layer.insertSublayer(pulseEffect2, below: collectionView.layer)
            self.view.layer.insertSublayer(pulseEffect3, below: collectionView.layer)
            
            let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(1.5 * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                let cvPoint = collectionView.convertPoint(cell.center, toView: self.view)
                let pulseEffect = LFTPulseAnimation(repeatCount: Float.infinity, radius:10, position:cvPoint)
                pulseEffect.backgroundColor = UIColor(hexString: team.colorSecondaryHex).CGColor
                let pulseEffect2 = LFTPulseAnimation(repeatCount: Float.infinity, radius:20, position:cvPoint)
                pulseEffect2.backgroundColor = UIColor(hexString: team.colorSecondaryHex).CGColor
                let pulseEffect3 = LFTPulseAnimation(repeatCount: Float.infinity, radius:40, position:cvPoint)
                pulseEffect3.backgroundColor = UIColor(hexString: team.colorSecondaryHex).CGColor
                self.view.layer.insertSublayer(pulseEffect, below: collectionView.layer)
                self.view.layer.insertSublayer(pulseEffect2, below: collectionView.layer)
                self.view.layer.insertSublayer(pulseEffect3, below: collectionView.layer)
            })
        }
        
        return cell
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
