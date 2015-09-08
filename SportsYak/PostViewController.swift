//
//  PostViewController.swift
//  SportsYak
//
//  Created by Kurt Jensen on 8/7/15.
//  Copyright (c) 2015 Arbor Apps. All rights reserved.
//

import UIKit
import Parse

class PostViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, CommentTableViewCellDelegate {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var textView: UITextView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var replyLabel: UILabel!
    @IBOutlet var voteLabel: UILabel!

    @IBOutlet var sendButton: UIButton?
    @IBOutlet var commentTextView: UIPlaceHolderTextView!
    var comments = [PFComment]()
    var post : PFPost!
    
    @IBOutlet var upVoteButton: UIButton!
    @IBOutlet var downVoteButton: UIButton!
    
    @IBOutlet var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    var readonly = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupReadOnly()
        self.setupView()
        self.loadData()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification : NSNotification) {
        let userInfo = notification.userInfo as! [String:AnyObject]
        if let keyboardFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            if let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue {
                UIView.animateWithDuration(NSTimeInterval(duration), animations: { () -> Void in
                    self.bottomConstraint.constant = keyboardFrame.height
                    //println("\(self.mainView.frame)")
                    //println("\(self.titleView.frame)")
                })
            }
        }
    }
    
    func keyboardWillHide(notification : NSNotification) {
        let userInfo = notification.userInfo as! [String:AnyObject]
        if let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue {
            UIView.animateWithDuration(duration, animations: { () -> Void in
                self.bottomConstraint.constant = 0
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupReadOnly() {
        if let user = PFMember.currentUser() {
            let teams = user.teamIds()
            for team in teams {
                if team == self.post.teamId {
                    self.readonly = false
                }
            }
        }
    }
    
    func setupView() {
        if post.shouldShow() {
            self.titleLabel.text = post.title
            self.textView.text = post.text
        }
        else {
            self.titleLabel.text = "[post muted]"
            self.textView.text = "you have previously muted this user"
        }
        self.timeLabel.text = post.createdAt?.timeAgoSimple
        self.replyLabel.text = post.replyString()
        self.commentTextView?.text = ""
        self.commentTextView?.placeholder = "Talk back"
        self.commentTextView?.editable = !readonly
        
        self.navigationItem.rightBarButtonItem?.enabled = !readonly

        self.setupVotes()
    }
    
    func setupVotes() {
        self.voteLabel.text = "\(post.upVotes.count - post.downVotes.count)"

        if let user = PFMember.currentUser() {
            if let userId = user.objectId {
                self.upVoteButton.selected = false
                self.downVoteButton.selected = false
                if contains(self.post.upVotes, userId) {
                    self.upVoteButton.selected = true
                }
                else if contains(post.downVotes, userId) {
                    self.downVoteButton.selected = true
                }
            }
        }
        
        self.upVoteButton.enabled = !readonly
        self.downVoteButton.enabled = !readonly

    }
    
    func checkSendEnablility() {
        self.sendButton?.enabled = !(self.commentTextView != nil && self.commentTextView!.text.isEmpty)
    }
    
    func loadData() {
        if let user = PFMember.currentUser() {
            if let query = PFComment.queryWithPost(self.post) {
                query.findObjectsInBackgroundWithBlock {
                    (objects: [AnyObject]?, error: NSError?) -> Void in
                    
                    if error == nil {
                        // The find succeeded.
                        println("Successfully retrieved \(objects!.count) comments.")
                        // Do something with the found objects
                        if let objects = objects as? [PFComment] {
                            for object in objects {
                                println(object.objectId)
                            }
                            self.comments = objects
                            self.tableView.reloadData()
                            self.tableView.hidden = false
                        }
                    } else {
                        // Log details of the failure
                        println("Error: \(error!) \(error!.userInfo!)")
                    }
                }
                self.tableView.hidden = true
            }
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var fixedWidth = tableView.contentSize.width - 44 //width of cell, minus 4 (left) 40 (right)
        var standardHeight : CGFloat = 53 //base height of textview
        var textView = UITextView()
        //textView.font = [UIFont fontWithName:@"Myriad Pro" size:13.0f];
        let comment = self.comments[indexPath.row]
        textView.text = comment.text
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
        let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! CommentTableViewCell
        let comment = self.comments[indexPath.row]
        cell.configureWithComment(comment, readonly: readonly)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let comment = self.comments[indexPath.row]
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        let alertController = UIAlertController(title: "", message: comment.text, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let shareAction = UIAlertAction(title: "Share", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            self.shareContent(nil, comment: comment, sender:cell)
        }
        let flagAction = UIAlertAction(title: "Flag", style: UIAlertActionStyle.Destructive) { (alertAction) -> Void in
            self.flagContent(nil, comment: comment)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(shareAction)
        alertController.addAction(flagAction)
        alertController.addAction(cancelAction)
        
        alertController.popoverPresentationController?.sourceView = cell.viewForBaselineLayout()!

        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func commentTableViewCellSelectButton(cell: CommentTableViewCell, comment: PFComment, actionType: CommentActionType) {
        if (actionType == CommentActionType.UpVote) {
            comment.upVote()
            if let indexPath = self.tableView.indexPathForCell(cell) {
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
        }
        else if (actionType == CommentActionType.DownVote) {
            comment.downVote()
            if let indexPath = self.tableView.indexPathForCell(cell) {
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        checkSendEnablility()
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        /*if (self.sendButton.enabled) {
            self.send(self.sendButton)
        }*/
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        let currentString = textView.text as NSString
        let proposedNewString = currentString.stringByReplacingCharactersInRange(range, withString: text) as String
        if (count(proposedNewString) < MAX_TEXT_LENGTH) {
            //self.charactersLabel.text = "\(MAX_TEXT_LENGTH-count(proposedNewString))"
            updateTextViewSize()
            return true
        }
        return false
    }
    
    func updateTextViewSize() {
        var height = self.heightForTextView()
        if height != self.textViewHeightConstraint.constant {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.textViewHeightConstraint.constant = height
            })
        }
    }
    
    func heightForTextView() -> CGFloat {
        var fixedWidth = self.view.frame.size.width - 70 //width of textview : 3*8 padding, 46 send button
        var standardHeight : CGFloat = 34 //base height of textview
        var textView = UITextView()
        textView.font = UIFont(name: "DIN Alternate", size:14)
        textView.text = self.commentTextView?.text
        textView.scrollEnabled = false
        var expectedSize = textView.sizeThatFits(CGSizeMake(fixedWidth, CGFloat(MAXFLOAT)))
        var newHeight = expectedSize.height
        if (standardHeight > newHeight) {
            newHeight = standardHeight
        }
        var height = 50 - standardHeight + newHeight //50 is base constraint
        return height
    }

    @IBAction func share(sender: AnyObject) {
        self.shareContent(self.post, comment: nil, sender: sender)
    }
    
    func shareContent(post: PFPost?, comment: PFComment?, sender: AnyObject) {
        var text = ""
        if (post != nil) {
            text = "\(post!.title) \(post!.text)"
        }
        else if (comment != nil) {
            text = "\(comment!.text)"
        }
        let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let button = sender as? UIButton {
            activityViewController.popoverPresentationController?.sourceView = button.viewForBaselineLayout()!
        }
        else if let cell = sender as? UITableViewCell {
            activityViewController.popoverPresentationController?.sourceView = cell.viewForBaselineLayout()!
        }
        /*controller.excludedActivityTypes = @[UIActivityTypePostToWeibo,
        UIActivityTypePrint,
        UIActivityTypeCopyToPasteboard,
        UIActivityTypeAssignToContact,
        UIActivityTypeAddToReadingList,
        UIActivityTypePostToFlickr,
        UIActivityTypePostToVimeo,
        UIActivityTypePostToTencentWeibo,
        UIActivityTypeAirDrop];*/
        
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func flag(sender: AnyObject) {
        self.flagContent(self.post, comment: nil)
    }
    
    func flagContent(post: PFPost?, comment: PFComment?) {
        let alertController = UIAlertController(title: "What's happening?", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        let offensiveAction = UIAlertAction(title: "Offensive content", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            if (post != nil) {
                post!.flag(FlagType.Offensive)
            }
            else if (comment != nil) {
                comment!.flag(FlagType.Offensive)
            }
            self.mute(post, comment: comment)
        }
        let personalAction = UIAlertAction(title: "Personal attack", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            if (post != nil) {
                post!.flag(FlagType.Personal)
            }
            else if (comment != nil) {
                comment!.flag(FlagType.Personal)
            }
            self.mute(post, comment: comment)
        }
        let spamAction = UIAlertAction(title: "Spam", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            if (post != nil) {
                post!.flag(FlagType.Spam)
            }
            else if (comment != nil) {
                comment!.flag(FlagType.Spam)
            }
            self.mute(post, comment: comment)
        }
        let otherAction = UIAlertAction(title: "Other", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            if (post != nil) {
                post!.flag(FlagType.Other)
            }
            else if (comment != nil) {
                comment!.flag(FlagType.Other)
            }
            self.mute(post, comment: comment)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(offensiveAction)
        alertController.addAction(personalAction)
        alertController.addAction(spamAction)
        alertController.addAction(otherAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func mute(post: PFPost?, comment: PFComment?)  {
        let alertController = UIAlertController(title: "Do you want to mute this user?", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        let muteAction = UIAlertAction(title: "Mute", style: UIAlertActionStyle.Destructive) { (alertAction) -> Void in
            if (post != nil) {
                post!.mute()
            }
            else if (comment != nil) {
                comment!.mute()
            }
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(muteAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func colorIndex() -> Int {
        if let user = PFMember.currentUser() {
            if (self.post.user.objectId != user.objectId) {
                for comment in self.comments {
                    if (comment.user.objectId == user.objectId) {
                        return comment.colorIndex
                    }
                }
            }
            else {
                return -1
            }
        }
        return Constants.randomColorIndex()
    }
    
    func imageIndex() -> Int {
        if let user = PFMember.currentUser() {
            if (self.post.user.objectId != user.objectId) {
                for comment in self.comments {
                    if (comment.user.objectId == user.objectId) {
                        return comment.imageIndex
                    }
                }
            }
            else {
                return -1
            }
        }
        return Constants.randomImageIndex()
    }

    @IBAction func send(sender: AnyObject) {
        var text = ""
        if (self.commentTextView != nil) {
            text = self.commentTextView!.text
        }
        
        let comment = PFComment(post: self.post, text: text, colorIndex: self.colorIndex(), imageIndex: self.imageIndex())
        if (comment.user != nil && comment.location != nil) {
            comment.saveInBackgroundWithBlock({ (success, error) -> Void in
                if (!contains(self.comments, comment)) {
                    self.comments.append(comment)
                    self.tableView.reloadData()
                }
                PFCloud.callFunctionInBackground("addComment", withParameters: ["postObjectId":self.post.objectId!,"commentObjectId":comment.objectId!], block: { (obj, error) -> Void in
                    if (error == nil) {
                        println("add comment \(comment.objectId!) for post \(self.post.objectId)")
                    }
                })
            })
            self.commentTextView?.resignFirstResponder()
            self.commentTextView?.text = ""
            self.updateTextViewSize()
            self.checkSendEnablility()
        }
    }
    
    @IBAction func upVote(sender: AnyObject) {
        self.post.upVote()
        self.setupVotes()
    }
    
    @IBAction func downVote(sender: AnyObject) {
        self.post.downVote()
        self.setupVotes()
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
