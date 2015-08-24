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

class MeViewController: HideBarsOnSwipeViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var mapView: MKMapView!
    var notifications = [PFNotification]()
    var posts : [PFObject]?
    var comments : [PFObject]?
    var myStuff = [PFObject]()
    var meType = MeType.Notifications
    var hasShownPulses = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.loadData(false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if (!hasShownPulses) {
            hasShownPulses = true
            let pulseEffect = LFTPulseAnimation(repeatCount: Float.infinity, radius:20, position:self.mapView.center)
            let pulseEffect2 = LFTPulseAnimation(repeatCount: Float.infinity, radius:40, position:self.mapView.center)
            let pulseEffect3 = LFTPulseAnimation(repeatCount: Float.infinity, radius:60, position:self.mapView.center)
            self.view.layer.insertSublayer(pulseEffect, above: self.mapView.layer)
            self.view.layer.insertSublayer(pulseEffect2, above: self.mapView.layer)
            self.view.layer.insertSublayer(pulseEffect3, above: self.mapView.layer)
        }
    }
    
    func loadData(forceDownload: Bool) {
        if let user = PFMember.currentUser() {
            if let userId = user.objectId {
                var query : PFQuery?
                if (self.meType == MeType.Notifications) {
                    if (self.notifications.count > 0 && !forceDownload) {
                        self.setupData(self.notifications)
                    }
                    else {
                        if let query = PFNotification.query() {
                            query.findObjectsInBackgroundWithBlock {
                                (objects: [AnyObject]?, error: NSError?) -> Void in
                                
                                if error == nil {
                                    println("Successfully retrieved \(objects!.count) notifications.")
                                    if let objects = objects as? [PFNotification] {
                                        for object in objects {
                                            println(object.objectId)
                                        }
                                        self.notifications = objects
                                        self.setupData(self.notifications)
                                    }
                                } else {
                                    println("Error: \(error!) \(error!.userInfo!)")
                                }
                            }
                        }
                    }
                }
                else {
                    if (self.myStuff.count > 0 && !forceDownload) {
                        self.setupData(self.myStuff)
                    }
                    else {
                        if let query = PFComment.query() {
                            query.whereKey("userId", equalTo: userId)
                            query.orderByDescending("createdAt")
                            query.findObjectsInBackgroundWithBlock {
                                (objects: [AnyObject]?, error: NSError?) -> Void in
                                
                                if error == nil {
                                    println("Successfully retrieved \(objects!.count) comments.")
                                    if let objects = objects as? [PFComment] {
                                        for object in objects {
                                            println(object.objectId)
                                        }
                                        self.comments = objects
                                        self.setupMyStuff()
                                    }
                                } else {
                                    println("Error: \(error!) \(error!.userInfo!)")
                                }
                            }
                        }
                        if let query = PFPost.query() {
                            query.whereKey("userId", equalTo: userId)
                            query.orderByDescending("createdAt")
                            query.findObjectsInBackgroundWithBlock {
                                (objects: [AnyObject]?, error: NSError?) -> Void in
                                
                                if error == nil {
                                    println("Successfully retrieved \(objects!.count) posts.")
                                    if let objects = objects as? [PFPost] {
                                        for object in objects {
                                            println(object.objectId)
                                        }
                                        self.posts = objects
                                        self.setupMyStuff()
                                    }
                                } else {
                                    println("Error: \(error!) \(error!.userInfo!)")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func setupMyStuff() {
        if ((self.posts != nil) && (self.comments != nil)) {
            var myStuff = self.posts!
            myStuff += self.comments!
            self.myStuff = myStuff.sorted { (lhs: PFObject, rhs: PFObject) -> Bool in
                return rhs.createdAt!.compare(lhs.createdAt!) == .OrderedAscending
                }.map { $0 as PFObject }
            self.setupData(self.myStuff)
        }
    }
    
    func setupData(data : [PFObject]) {
        if (self.myStuff != data) {
            self.myStuff = data
            self.tableView.reloadData()
        }
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

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let notification = self.myStuff[indexPath.row] as? PFNotification {
            let cell = tableView.dequeueReusableCellWithIdentifier("notification", forIndexPath: indexPath) as! UITableViewCell
            
            return cell
        }
        else if let post = self.myStuff[indexPath.row] as? PFPost {
            let cell = tableView.dequeueReusableCellWithIdentifier("post", forIndexPath: indexPath) as! UITableViewCell
            
            return cell
        }
        else if let comment = self.myStuff[indexPath.row] as? PFComment {
            let cell = tableView.dequeueReusableCellWithIdentifier("comment", forIndexPath: indexPath) as! UITableViewCell
            
            return cell
        }
        return UITableViewCell()
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
            
            println(cell.teamImageView)
            let cvPoint = collectionView.convertPoint(cell.center, toView: self.view)
            let pulseEffect = LFTPulseAnimation(repeatCount: Float.infinity, radius:10, position:cvPoint)
            let pulseEffect2 = LFTPulseAnimation(repeatCount: Float.infinity, radius:20, position:cvPoint)
            let pulseEffect3 = LFTPulseAnimation(repeatCount: Float.infinity, radius:40, position:cvPoint)
            self.view.layer.insertSublayer(pulseEffect, below: collectionView.layer)
            self.view.layer.insertSublayer(pulseEffect2, below: collectionView.layer)
            self.view.layer.insertSublayer(pulseEffect3, below: collectionView.layer)
        }
        
        return cell
    }

    @IBAction func segmentedControlChanged(sender: UISegmentedControl) {
        self.meType = MeType(rawValue: sender.selectedSegmentIndex) ?? MeType.Notifications
        loadData(false)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
