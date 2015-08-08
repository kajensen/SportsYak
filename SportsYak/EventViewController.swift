//
//  EventViewController.swift
//  SportsYak
//
//  Created by Kurt Jensen on 8/7/15.
//  Copyright (c) 2015 Arbor Apps. All rights reserved.
//

import UIKit
import Parse

class EventViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    var event : PFEvent!
    var postsOne = [PFPost]()
    var postsTwo = [PFPost]()
    var posts = [PFPost]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupView()
        self.loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupView() {
        // TODO
    }
    
    func loadData() {
        if let query = PFComment.query() {
            query.whereKey("teamId", equalTo: event.teamOneId)
            query.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    println("Successfully retrieved \(objects!.count) posts.")
                    if let objects = objects as? [PFPost] {
                        for object in objects {
                            println(object.objectId)
                        }
                        self.postsOne = objects
                        self.tableView.reloadData()
                    }
                } else {
                    println("Error: \(error!) \(error!.userInfo!)")
                }
            }
        }
        if let query = PFComment.query() {
            query.whereKey("teamId", equalTo: event.teamTwoId)
            query.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    println("Successfully retrieved \(objects!.count) posts.")
                    if let objects = objects as? [PFPost] {
                        for object in objects {
                            println(object.objectId)
                        }
                        self.postsTwo = objects
                        self.tableView.reloadData()
                    }
                } else {
                    println("Error: \(error!) \(error!.userInfo!)")
                }
            }
        }
    }
    
    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell", forIndexPath: indexPath) as! PostTableViewCell
        let post = posts[indexPath.row]
        cell.configureWithPost(post)
        
        return cell
    }
    
    func postTableViewCellSelectButton(cell: PostTableViewCell, actionType: PostActionType) {
        // TODO
    }
    
    @IBAction func nearby(sender: UIButton) {
    }
    
    @IBAction func mySquads(sender: UIButton) {
    }
    
    @IBAction func controlChanged(sender: UISegmentedControl) {
    }
    
    @IBAction func compose(sender: AnyObject) {
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "ViewComments") {
            if let postViewController = segue.destinationViewController as? PostViewController {
                if let cell = sender as? PostTableViewCell {
                    if let indexPath = self.tableView.indexPathForCell(cell) {
                        let post = self.posts[indexPath.row]
                        postViewController.post = post
                    }
                }
            }
        }
    }

}
