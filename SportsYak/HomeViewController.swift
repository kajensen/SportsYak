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
    var postsNearbyN = [PFPost]()
    var postsNearbyH = [PFPost]()
    var postsMySquadsN = [PFPost]()
    var postsMySquadsH = [PFPost]()
    var posts = [PFPost]()
    var postType = PostType.Nearby
    var postSort = PostSort.New

    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadData(false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func loadData(forceDownload : Bool) {
        if let _ = PFMember.currentUser() {
            if (self.postType == PostType.Nearby) {
                if (self.postSort == PostSort.Hot && self.postsNearbyH.count > 0  && !forceDownload) {
                    self.didLoadPosts(self.postsNearbyH)
                }
                else if (self.postSort == PostSort.New && self.postsNearbyN.count > 0 && !forceDownload) {
                    self.didLoadPosts(self.postsNearbyN)
                }
                else {
                    let savedSort = self.postSort
                    if let query = PFPost.queryWithNearby(self.postSort) {
                        query.findObjectsInBackgroundWithBlock({
                            (objects, error) -> Void in
                            
                            if error == nil {
                                print("Successfully retrieved \(objects!.count) nearby posts.")
                                if let objects = objects as? [PFPost] {
                                    if (savedSort == PostSort.Hot) {
                                        self.postsNearbyH = objects
                                        self.didLoadPosts(self.postsNearbyH)
                                    }
                                    else {
                                        self.postsNearbyN = objects
                                        self.didLoadPosts(self.postsNearbyN)
                                    }
                                }
                            } else {
                                print("Error: \(error!) \(error!.userInfo)")
                            }
                        })
                        //self.tableView.hidden = true
                    }
                }
            }
            else {
                if (self.postSort == PostSort.Hot && self.postsMySquadsH.count > 0 && !forceDownload) {
                    self.didLoadPosts(self.postsMySquadsH)
                }
                else if (self.postSort == PostSort.New && self.postsMySquadsN.count > 0 && !forceDownload) {
                    self.didLoadPosts(self.postsMySquadsN)
                }
                else {
                    let savedSort = self.postSort
                    if let query = PFPost.queryWithMyTeams(self.postSort) {
                        query.findObjectsInBackgroundWithBlock({
                            (objects, error) -> Void in
                            
                            if error == nil {
                                print("Successfully retrieved \(objects!.count) my squad posts.")
                                if let objects = objects as? [PFPost] {
                                    if (savedSort == PostSort.Hot) {
                                        self.postsMySquadsH = objects
                                        self.didLoadPosts(self.postsMySquadsH)
                                    }
                                    else {
                                        self.postsMySquadsN = objects
                                        self.didLoadPosts(self.postsMySquadsN)
                                    }
                                }
                            } else {
                                print("Error: \(error!) \(error!.userInfo)")
                            }
                        })
                        //self.tableView.hidden = true
                    }
                }
            }
        }
    }
    
    func didLoadPosts(posts : [PFPost]) {
        if (self.posts != posts) {
            self.posts = posts
            self.tableView.reloadData()
            //self.tableView.hidden = false
        }
        super.refreshFinished()
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
        let textView = UILabel()
        textView.font = UIFont.systemFontOfSize(12)
        let post = self.posts[indexPath.row]
        textView.text = post.text
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
