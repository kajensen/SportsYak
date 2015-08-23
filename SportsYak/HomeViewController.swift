//
//  HomeViewController.swift
//  SportsYak
//
//  Created by Kurt Jensen on 8/7/15.
//  Copyright (c) 2015 Arbor Apps. All rights reserved.
//

import UIKit
import Parse

class HomeViewController: HideBarsOnSwipeViewController, UITableViewDataSource, UITableViewDelegate, PostTableViewCellDelegate {

    @IBOutlet var buttonGroupView: ButtonGroupUnderlineView!
    @IBOutlet var tableView: UITableView!
    var postsNearbyN = [PFPost]()
    var postsNearbyH = [PFPost]()
    var postsMySquadsN = [PFPost]()
    var postsMySquadsH = [PFPost]()
    var posts = [PFPost]()
    var postType = PostType.Nearby
    var postSort = PostSort.New
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.loadData(false)
    }
    
    override func viewDidLayoutSubviews() {
        if let button = self.buttonGroupView.buttons.first {
            self.buttonGroupView.tapped(button)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData(forceDownload : Bool) {
        if let user = PFMember.currentUser() {
            var query : PFQuery?
            if (self.postType == PostType.Nearby) {
                if (self.postSort == PostSort.Hot && self.postsNearbyH.count > 0  && !forceDownload) {
                    self.setupPosts(self.postsNearbyH)
                }
                else if (self.postSort == PostSort.New && self.postsNearbyN.count > 0 && !forceDownload) {
                    self.setupPosts(self.postsNearbyN)
                }
                else {
                    var savedSort = self.postSort
                    query = PFPost.queryWithNearby(self.postSort)
                    if (query != nil) {
                        query!.findObjectsInBackgroundWithBlock {
                            (objects: [AnyObject]?, error: NSError?) -> Void in
                            
                            if error == nil {
                                println("Successfully retrieved \(objects!.count) nearby posts.")
                                if let objects = objects as? [PFPost] {
                                    for object in objects {
                                        println(object.objectId)
                                    }
                                    if (savedSort == PostSort.Hot) {
                                        self.postsNearbyH = objects
                                        self.setupPosts(self.postsNearbyH)
                                    }
                                    else {
                                        self.postsNearbyN = objects
                                        self.setupPosts(self.postsNearbyN)
                                    }
                                }
                            } else {
                                println("Error: \(error!) \(error!.userInfo!)")
                            }
                        }
                    }
                }
            }
            else {
                if (self.postSort == PostSort.Hot && self.postsMySquadsH.count > 0 && !forceDownload) {
                    self.setupPosts(self.postsMySquadsH)
                }
                else if (self.postSort == PostSort.New && self.postsMySquadsN.count > 0 && !forceDownload) {
                    self.setupPosts(self.postsMySquadsN)
                }
                else {
                    var savedSort = self.postSort
                    query = PFPost.queryWithMyTeams(self.postSort)
                    if (query != nil) {
                        query!.findObjectsInBackgroundWithBlock {
                            (objects: [AnyObject]?, error: NSError?) -> Void in
                            
                            if error == nil {
                                println("Successfully retrieved \(objects!.count) my squad posts.")
                                if let objects = objects as? [PFPost] {
                                    for object in objects {
                                        println(object.objectId)
                                    }
                                    if (savedSort == PostSort.Hot) {
                                        self.postsMySquadsH = objects
                                        self.setupPosts(self.postsMySquadsH)
                                    }
                                    else {
                                        self.postsMySquadsN = objects
                                        self.setupPosts(self.postsMySquadsN)
                                    }
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
        var fixedWidth = tableView.contentSize.width - 64 //width of cell, 8*3 padding 40 (vote view)
        var standardHeight : CGFloat = 23 //base height of textview
        var textView = UITextView()
        //textView.font = [UIFont fontWithName:@"Myriad Pro" size:13.0f];
        let post = self.posts[indexPath.row]
        textView.text = post.text
        textView.scrollEnabled = false
        var expectedSize = textView.sizeThatFits(CGSizeMake(fixedWidth, CGFloat(MAXFLOAT)))
        var newHeight = expectedSize.height
        if (standardHeight > newHeight) {
            newHeight = standardHeight
        }
        var height = tableView.rowHeight - standardHeight + newHeight
        return height
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell", forIndexPath: indexPath) as! PostTableViewCell
        cell.delegate = self
        let post = self.posts[indexPath.row]
        cell.configureWithPost(post)
        
        return cell
    }
    
    func postTableViewCellSelectButton(cell: PostTableViewCell, actionType: PostActionType) {
        // TODO
    }
    
    func buttonGroupUnderlineViewDidSelectButtonAtIndex(index: Int) {
        self.postType = PostType(rawValue: index) ?? PostType.Nearby
        loadData(false)
    }

    @IBAction func nearby(sender: UIButton) {
        self.buttonGroupView.tapped(sender)
        self.postType = PostType.Nearby
        loadData(false)
    }

    @IBAction func mySquads(sender: UIButton) {
        self.buttonGroupView.tapped(sender)
        self.postType = PostType.MySquads
        loadData(false)
    }
    
    @IBAction func controlChanged(sender: UISegmentedControl) {
        self.postSort = PostSort(rawValue: sender.selectedSegmentIndex) ?? PostSort.New
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
