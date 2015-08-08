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
            
            // Configure the cell...
            
            return cell
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
