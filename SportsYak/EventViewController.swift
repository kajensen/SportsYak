//
//  EventViewController.swift
//  SportsYak
//
//  Created by Kurt Jensen on 8/7/15.
//  Copyright (c) 2015 Arbor Apps. All rights reserved.
//

import UIKit
import Parse

class EventViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PostTableViewCellDelegate {
    
    @IBOutlet var buttonGroupView: ButtonGroupUnderlineView!
    @IBOutlet var tableView: UITableView!
    var postsTeamOneN = [PFPost]()
    var postsTeamOneH = [PFPost]()
    var postsTeamTwoN = [PFPost]()
    var postsTeamTwoH = [PFPost]()
    var posts = [PFPost]()
    var postType = PostType.TeamOne
    var postSort = PostSort.New
    var event : PFEvent!
    var hasSetupUnderline = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (event != nil) {
            self.buttonGroupView.buttons.first?.setTitle(event.teamOneName(), forState: UIControlState.Normal)
            self.buttonGroupView.buttons.last?.setTitle(event.teamTwoName(), forState: UIControlState.Normal)
        }
        self.loadData(false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
        
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if (!hasSetupUnderline) {
            hasSetupUnderline = true
            if let button = self.buttonGroupView.buttons.first {
                self.buttonGroupView.tapped(button)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData(forceDownload : Bool) {
        
        if (event != nil) {
            if (self.postType == PostType.TeamOne) {
                if (self.postSort == PostSort.Hot && self.postsTeamOneH.count > 0 && !forceDownload) {
                    self.setupPosts(self.postsTeamOneH)
                }
                else if (self.postSort == PostSort.New && self.postsTeamOneN.count > 0 && !forceDownload) {
                    self.setupPosts(self.postsTeamOneN)
                }
                else {
                    let savedSort = self.postSort
                    if let query = PFPost.queryWithEvent(self.event, postType: self.postType, postSort: self.postSort) {
                        query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                            if error == nil {
                                print("Successfully retrieved \(objects!.count) team one \(self.event.teamOneId) posts.")
                                if let objects = objects as? [PFPost] {
                                    for object in objects {
                                        print(object.objectId)
                                    }
                                    if (savedSort == PostSort.Hot) {
                                        self.postsTeamOneH = objects
                                        self.setupPosts(self.postsTeamOneH)
                                    }
                                    else {
                                        self.postsTeamOneN = objects
                                        self.setupPosts(self.postsTeamOneN)
                                    }
                                }
                            } else {
                                print("Error: \(error!) \(error!.userInfo)")
                            }
                        })
                    }
                }
            }
            else {
                if (self.postSort == PostSort.Hot && self.postsTeamTwoH.count > 0 && !forceDownload) {
                    self.setupPosts(self.postsTeamTwoH)
                }
                else if (self.postSort == PostSort.New && self.postsTeamTwoN.count > 0 && !forceDownload) {
                    self.setupPosts(self.postsTeamTwoN)
                }
                else {
                    let savedSort = self.postSort
                    if let query = PFPost.queryWithEvent(self.event, postType: self.postType, postSort: self.postSort) {
                        query.findObjectsInBackgroundWithBlock({
                            (objects, error) -> Void in
                            
                            if error == nil {
                                print("Successfully retrieved \(objects!.count) team two \(self.event.teamTwoId) posts.")
                                if let objects = objects as? [PFPost] {
                                    for object in objects {
                                        print(object.objectId)
                                    }
                                    if (savedSort == PostSort.Hot) {
                                        self.postsTeamTwoH = objects
                                        self.setupPosts(self.postsTeamTwoH)
                                    }
                                    else {
                                        self.postsTeamTwoN = objects
                                        self.setupPosts(self.postsTeamTwoN)
                                    }
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
    
    func setupPosts(posts : [PFPost]) {
        if (self.posts != posts) {
            self.posts = posts
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let fixedWidth = tableView.contentSize.width - 64 //width of cell, 8*3 padding 40 (vote view)
        let standardHeight : CGFloat = 23 //base height of textview
        let textView = UITextView()
        //textView.font = [UIFont fontWithName:@"Myriad Pro" size:13.0f];
        let post = self.posts[indexPath.row]
        textView.text = post.text
        textView.scrollEnabled = false
        let expectedSize = textView.sizeThatFits(CGSizeMake(fixedWidth, CGFloat(MAXFLOAT)))
        var newHeight = expectedSize.height
        if (standardHeight > newHeight) {
            newHeight = standardHeight
        }
        let height = tableView.rowHeight - standardHeight + newHeight
        return height
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell", forIndexPath: indexPath) as! PostTableViewCell
        cell.delegate = self
        let post = self.posts[indexPath.row]
        var readonly = true
        if let user = PFMember.currentUser() {
            readonly = !user.hasTeamId(post.teamId)
        }
        cell.configureWithPost(post, readonly: readonly)
        
        return cell
    }
    
    func postTableViewCellSelectButton(cell: PostTableViewCell, post: PFPost, actionType: PostActionType) {
        // TODO
    }
    
    @IBAction func controlChanged(sender: UISegmentedControl) {
        self.postSort = PostSort(rawValue: sender.selectedSegmentIndex) ?? PostSort.New
        loadData(false)
    }
    
    @IBAction func teamOne(sender: UIButton) {
        self.buttonGroupView.tapped(sender)
        self.postType = PostType.TeamOne
        loadData(false)
    }
    
    @IBAction func teamTwo(sender: UIButton) {
        self.buttonGroupView.tapped(sender)
        self.postType = PostType.TeamTwo
        loadData(false)
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
