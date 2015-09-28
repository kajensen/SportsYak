//
//  CommentTableViewCell.swift
//  SportsYak
//
//  Created by Kurt Jensen on 8/7/15.
//  Copyright (c) 2015 Arbor Apps. All rights reserved.
//

import UIKit

enum CommentActionType: Int {
    case UpVote = 0
    case DownVote
}

protocol CommentTableViewCellDelegate {
    func commentTableViewCellSelectButton(cell: CommentTableViewCell, comment: PFComment, actionType: CommentActionType)
}

class CommentTableViewCell: UITableViewCell {

    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var replyLabel: UILabel!
    @IBOutlet var commentLabel: UILabel!
    
    @IBOutlet var voteLabel: UILabel!
    
    @IBOutlet var upVoteButton: UIButton!
    @IBOutlet var downVoteButton: UIButton!
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var userImageBackgroundView: UIView!
    
    var delegate: CommentTableViewCellDelegate?
    var comment: PFComment!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configureWithComment(comment:PFComment, readonly: Bool) {
        self.comment = comment
        if comment.shouldShow() {
            self.commentLabel.text = comment.text
        }
        else {
            self.commentLabel.text = "[comment muted] you have previously muted this user"
        }
        self.timeLabel.text = comment.createdAt?.timeAgoSimple
        self.voteLabel.text = "\(comment.upVotes.count - comment.downVotes.count)"
        self.upVoteButton.selected = false
        self.downVoteButton.selected = false
        self.upVoteButton.enabled = !readonly
        self.downVoteButton.enabled = !readonly
        self.userImageView.image = Constants.userImage(comment.imageIndex)
        self.userImageBackgroundView.backgroundColor = Constants.userColor(comment.colorIndex)
        self.userImageBackgroundView.layer.cornerRadius = self.userImageBackgroundView.frame.size.width/4.0
        self.userImageBackgroundView.layer.masksToBounds = false
        if let user = PFMember.currentUser() {
            if let userId = user.objectId {
                if comment.upVotes.contains(userId) {
                    self.upVoteButton.selected = true
                }
                else if comment.downVotes.contains(userId) {
                    self.downVoteButton.selected = true
                }
            }
        }
    }
    
    @IBAction func downVote(sender: AnyObject) {
        self.delegate?.commentTableViewCellSelectButton(self, comment: self.comment, actionType: CommentActionType.DownVote)
    }
    
    @IBAction func upVote(sender: AnyObject) {
        self.delegate?.commentTableViewCellSelectButton(self, comment: self.comment, actionType: CommentActionType.UpVote)
    }


}
