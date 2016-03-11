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
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0){
            return "My Teams"
        }
        else if (section == 1) {
            return "Share the Love"
        }
        else {
            return "Important Stuff"
        }
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
            let cell = tableView.dequeueReusableCellWithIdentifier("InfoCell", forIndexPath: indexPath) 
            
            if (indexPath.section == 1) {
                if (indexPath.row == 0) {
                    cell.textLabel?.text = "Share Trash Talk"
                }
                else if (indexPath.row == 1) {
                    cell.textLabel?.text = "Rate Trash Talk"
                }
                else if (indexPath.row == 2) {
                    cell.textLabel?.text = "Follow Us on Twitter"
                }
                else if (indexPath.row == 3) {
                    cell.textLabel?.text = "Like Us on Facebook"
                }
            }
            else if (indexPath.section == 2) {
                if (indexPath.row == 0) {
                    cell.textLabel?.text = "Contact Us"
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
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if (indexPath.section == 1) {
            if (indexPath.row == 0) { // SHARE
                let text = "Share gameday with your squads. Talk smack, embrace victory, join your sports community with TrashTalk @TrashTalkApp."
                
                let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
                let cell = tableView.cellForRowAtIndexPath(indexPath)
                activityViewController.popoverPresentationController?.sourceRect = cell!.frame
                
                activityViewController.excludedActivityTypes = [UIActivityTypePostToWeibo,
                    UIActivityTypePrint,
                    UIActivityTypeCopyToPasteboard,
                    UIActivityTypeAssignToContact,
                    UIActivityTypeAddToReadingList,
                    UIActivityTypePostToFlickr,
                    UIActivityTypePostToVimeo,
                    UIActivityTypePostToTencentWeibo,
                    UIActivityTypeAirDrop]
                
                self.presentViewController(activityViewController, animated: true, completion: nil)
            }
            else if (indexPath.row == 1) { // RATE
                if let checkURL = NSURL(string: "http://itunes.apple.com/us/app/trash-talk-realtime-sports/id1033303390?mt=8") {
                    UIApplication.sharedApplication().openURL(checkURL)
                }
            }
            else if (indexPath.row == 2) { // TWITTER
                if let twitterUrl = NSURL(string:"twitter://user?screen_name=TrashTalkApp") {
                    if UIApplication.sharedApplication().canOpenURL(twitterUrl) {
                        UIApplication.sharedApplication().openURL(twitterUrl)
                    }
                    else {
                        if let safariUrl = NSURL(string: "https://twitter.com/TrashTalkApp") {
                            UIApplication.sharedApplication().openURL(safariUrl)
                        }
                    }
                }
            }
            else if (indexPath.row == 3) { // FACEBOOK
                if let facebookUrl = NSURL(string:"fb://profile/TrashTalkApp") {
                    if UIApplication.sharedApplication().canOpenURL(facebookUrl) {
                        UIApplication.sharedApplication().openURL(facebookUrl)
                    }
                    else {
                        if let safariUrl = NSURL(string: "https://facebook.com/TrashTalkApp") {
                            UIApplication.sharedApplication().openURL(safariUrl)
                        }
                    }
                }
            }
        }
        else if (indexPath.section == 2) {
            if (indexPath.row == 0) { // HELP
                Instabug.invokeFeedbackSender()
            }
            else if (indexPath.row == 1) { // RULES
                self.performSegueWithIdentifier("Web", sender: "http://trashtalk.arborapps.io/rules")
            }
            else if (indexPath.row == 2) { // TERMS
                self.performSegueWithIdentifier("Web", sender: "http://trashtalk.arborapps.io/terms")
            }
            else if (indexPath.row == 3) { // POLICY
                self.performSegueWithIdentifier("Web", sender: "http://trashtalk.arborapps.io/policy")
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
        else if (segue.identifier == "Web") {
            if let webViewController = segue.destinationViewController as? WebViewController {
                if let address = sender as? String {
                    webViewController.url = NSURL(string: address)
                }
            }
        }
    }

}
