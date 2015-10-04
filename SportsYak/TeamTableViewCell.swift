//
//  TeamTableViewCell.swift
//  SportsYak
//
//  Created by Kurt Jensen on 8/7/15.
//  Copyright (c) 2015 Arbor Apps. All rights reserved.
//

import UIKit
import Parse

protocol TeamTableViewCellDelegate {
    func teamTableViewCellSwitched(cell: TeamTableViewCell, tSwitch: UISwitch!)
}

class TeamTableViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var tSwitch: UISwitch!
    
    var delegate: TeamTableViewCellDelegate?
    var team: PFTeam?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureWithTeam(team:PFTeam) {
        self.team = team
        if self.team != nil {
            if self.team!.isDataAvailable() {
                self.titleLabel.text = self.team!.name
                if let user = PFMember.currentUser() {
                    let isOn = user.isOn(self.team!)
                    self.tSwitch.on = isOn
                }
            }
        }
    }
    
    func configureWithType(type:TeamType) {
        var title = ""
        switch type {
        case TeamType.NFL:
            title = "NFL posts"
        default:
            print("uh oh, no type")
        }
        self.titleLabel.text = title
        self.tSwitch.on = false
    }
    
    @IBAction func changedSwitch(sender: UISwitch) {
        self.delegate?.teamTableViewCellSwitched(self, tSwitch: sender)
    }

}
