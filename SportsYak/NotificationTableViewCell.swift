//
//  NotificationTableViewCell.swift
//  SportsYak
//
//  Created by Kurt Jensen on 8/7/15.
//  Copyright (c) 2015 Arbor Apps. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
    
    @IBOutlet var notificationImageView: UIImageView!

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!

    @IBOutlet var timeLabel: UILabel!
    
    var post : PFPost!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureWithNotification(notification: PFNotification) {
        self.titleLabel.text = notification.message
        
        if let comment = notification.comment {
            self.configureWithPost(comment.post)
            self.notificationImageView.image = UIImage(named: "Response-100")
        }
        else if let post = notification.post {
            self.configureWithPost(post)
            self.notificationImageView.image = UIImage(named: "Up Circled-100")
        }
        else {
            print("no post or comment.")
        }

    }
    
    func configureWithPost(post: PFPost) {
        self.post = post
        self.timeLabel.text = self.post.createdAt?.timeAgoSimple
        self.messageLabel.text = "'\(self.post.text)'"
    }

}
