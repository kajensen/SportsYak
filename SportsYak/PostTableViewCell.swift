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
    func postTableViewCellSelectButton(cell: PostTableViewCell, actionType: PostActionType)
}

class PostTableViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var textView: UITextView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var replyLabel: UILabel!
    
    @IBOutlet var voteLabel: UILabel!
    
    @IBOutlet var upVoteButton: UIButton!
    @IBOutlet var downVoteButton: UIButton!
    var delegate: PostTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureWithPost(post:PFPost) {
        self.titleLabel.text = post.title
        self.textView.text = post.text
        self.timeLabel.text = post.createdAt?.timeAgoSimple
        self.replyLabel.text = post.replyString()
        self.voteLabel.text = "\(post.upVotes.count - post.downVotes.count)"
        if let user = PFMember.currentUser() {
            if let userId = user.objectId {
                if contains(post.upVotes, userId) {
                    self.upVoteButton.selected = true
                }
                else if contains(post.downVotes, userId) {
                    self.downVoteButton.selected = true
                }
            }
        }
    }

    @IBAction func downVote(sender: AnyObject) {
        self.delegate?.postTableViewCellSelectButton(self, actionType: PostActionType.DownVote)
    }
    
    @IBAction func upVote(sender: AnyObject) {
        self.delegate?.postTableViewCellSelectButton(self, actionType: PostActionType.UpVote)
    }
    
}
