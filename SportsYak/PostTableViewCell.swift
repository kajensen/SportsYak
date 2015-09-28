//
//  PostTableViewCell.swift
//  SportsYak
//
//  Created by Kurt Jensen on 8/7/15.
//  Copyright (c) 2015 Arbor Apps. All rights reserved.
//

import UIKit

enum PostActionType: Int {
    case UpVote = 0
    case DownVote
}

protocol PostTableViewCellDelegate {
    func postTableViewCellSelectButton(cell: PostTableViewCell, post: PFPost, actionType: PostActionType)
}

class PostTableViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var postLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var replyLabel: UILabel!
    
    @IBOutlet var voteLabel: UILabel!
    
    @IBOutlet var upVoteButton: UIButton!
    @IBOutlet var downVoteButton: UIButton!
    var post: PFPost!
    var delegate: PostTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureWithPost(post:PFPost, readonly: Bool) {
        self.post = post
        if post.shouldShow() {
            self.titleLabel.text = post.title
            self.postLabel?.text = post.text
        }
        else {
            self.titleLabel.text = "[post muted]"
            self.postLabel?.text = "you have previously muted this user"
        }
        self.timeLabel.text = post.createdAt?.timeAgoSimple
        self.replyLabel.text = post.replyString()
        self.voteLabel.text = "\(post.upVotes.count - post.downVotes.count)"
        if let user = PFMember.currentUser() {
            if let userId = user.objectId {
                self.upVoteButton.selected = false
                self.downVoteButton.selected = false
                if post.upVotes.contains(userId) {
                    self.upVoteButton.selected = true
                }
                else if post.downVotes.contains(userId) {
                    self.downVoteButton.selected = true
                }
            }
        }
        self.upVoteButton.enabled = !readonly
        self.downVoteButton.enabled = !readonly
    }

    @IBAction func downVote(sender: AnyObject) {
        self.delegate?.postTableViewCellSelectButton(self, post:self.post, actionType: PostActionType.DownVote)
    }
    
    @IBAction func upVote(sender: AnyObject) {
        self.delegate?.postTableViewCellSelectButton(self, post:self.post, actionType: PostActionType.UpVote)
    }
    
}
