//
//  MoreViewController.swift
//  SportsYak
//
//  Created by Kurt Jensen on 8/7/15.
//  Copyright (c) 2015 Arbor Apps. All rights reserved.
//

import UIKit
import Parse

class MoreViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TeamTableViewCellDelegate {

    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0){
            return TeamType.count.rawValue
        }
        else if (section == 1) {
            return 4
        }
        else if (section == 2) {
            return 4
        }
        return 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.section == 0){
            let cell = tableView.dequeueReusableCellWithIdentifier("TeamCell", forIndexPath: indexPath) as! TeamTableViewCell
            cell.delegate = self
            if let user = PFMember.currentUser() {
                let type = TeamType(rawValue: indexPath.row)!
                let team = user.teamForType(type)
                if (team != nil) {
                    cell.configureWithTeam(team!)
                }
                else {
                    cell.configureWithType(type)
                }
            }
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("InfoCell", forIndexPath: indexPath) as! UITableViewCell
            
            if (indexPath.section == 0) {
                if (indexPath.row == 0) {
                    cell.textLabel?.text = "Share Sports Yak"
                }
                else if (indexPath.row == 1) {
                    cell.textLabel?.text = "Rate Sports Yak"
                }
                else if (indexPath.row == 2) {
                    cell.textLabel?.text = "Follow Us on Twitter"
                }
                else if (indexPath.row == 3) {
                    cell.textLabel?.text = "Like Us on Facebook"
                }
            }
            else if (indexPath.section == 1) {
                if (indexPath.row == 0) {
                    cell.textLabel?.text = "Getting Help/Contact Us"
                }
                else if (indexPath.row == 1) {
                    cell.textLabel?.text = "Rules and Info"
                }
                else if (indexPath.row == 2) {
                    cell.textLabel?.text = "Terms of Service"
                }
                else if (indexPath.row == 3) {
                    cell.textLabel?.text = "Privacy Policy"
                }
            }
            
            return cell
        }

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) { // SHARE
            }
            else if (indexPath.row == 1) { // RATE
            }
            else if (indexPath.row == 2) { // TWITTER
            }
            else if (indexPath.row == 3) { // FACEBOOK
            }
        }
        else if (indexPath.section == 1) {
            if (indexPath.row == 0) { // HELP
            }
            else if (indexPath.row == 1) { // RULES
            }
            else if (indexPath.row == 2) { // TERMS
            }
            else if (indexPath.row == 3) { // POLICY
            }
        }
    }

    func teamTableViewCellSwitched(cell: TeamTableViewCell, tSwitch: UISwitch!) {
        // TODO
        if (tSwitch.on) {
            if (cell.team != nil) {
                if let user = PFMember.currentUser() {
                    user.turnOnTeam(cell.team!)
                }
            }
            else {
                self.performSegueWithIdentifier("SelectTeam", sender: cell)
            }
        }
        else {
            if (cell.team != nil) {
                if let user = PFMember.currentUser() {
                    user.turnOffTeam(cell.team!)
                }
            }
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "SelectTeam") {
            if let selectTeamViewController = segue.destinationViewController as? SelectTeamViewController {
                if let cell = sender as? TeamTableViewCell {
                    if let indexPath = self.tableView.indexPathForCell(cell) {
                        selectTeamViewController.type = TeamType(rawValue: indexPath.row)!
                    }
                }
            }
        }
    }

}
