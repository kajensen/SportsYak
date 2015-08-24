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

    @IBOutlet var textView: UITextView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var replyLabel: UILabel!
    
    @IBOutlet var voteLabel: UILabel!
    
    @IBOutlet var upVoteButton: UIButton!
    @IBOutlet var downVoteButton: UIButton!
    @IBOutlet var userImageView: UIImageView!
    
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
    
    func configureWithComment(comment:PFComment) {
        self.comment = comment
        self.textView.text = comment.text
        self.timeLabel.text = comment.createdAt?.timeAgoSimple
        self.voteLabel.text = "\(comment.upVotes.count - comment.downVotes.count)"
        self.upVoteButton.selected = false
        self.downVoteButton.selected = false
        if let user = PFMember.currentUser() {
            if let userId = user.objectId {
                if contains(comment.upVotes, userId) {
                    self.upVoteButton.selected = true
                }
                else if contains(comment.downVotes, userId) {
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
