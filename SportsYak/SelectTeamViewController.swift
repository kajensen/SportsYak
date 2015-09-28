//
//  SelectTeamViewController.swift
//  SportsYak
//
//  Created by Kurt Jensen on 8/7/15.
//  Copyright (c) 2015 Arbor Apps. All rights reserved.
//

import UIKit
import Parse

class SelectTeamViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    var teams = [PFTeam]()
    var type = TeamType.count
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadData() {
        if let _ = PFMember.currentUser() {
            var query : PFQuery?
            switch self.type {
                case TeamType.NFL:
                    query = PFNFLTeam.query()!
                default:
                    print("uh oh, invalid type")
            }
            if query != nil {
                print("fetching teams for type: \(self.type)")
                query!.findObjectsInBackgroundWithBlock({
                    (objects, error) -> Void in
                    
                    if error == nil {
                        print("Successfully retrieved \(objects!.count) teams.")
                        if let objects = objects as? [PFTeam] {
                            self.teams = objects
                            self.tableView.reloadData()
                        }
                    } else {
                        print("Error: \(error!) \(error!.userInfo)")
                    }
                })
            }
        }
    }
    
    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.teams.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TeamCell", forIndexPath: indexPath) 
        let team = self.teams[indexPath.row]
        if team.isDataAvailable() {
            cell.textLabel!.text = team.name
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let team = self.teams[indexPath.row]
        if let user = PFMember.currentUser() {
            let title = team.name
            let alertController = UIAlertController(title: title, message: "You can only choose your team once.", preferredStyle: UIAlertControllerStyle.Alert)
            let chooseAction = UIAlertAction(title: "Select", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                user.addTeam(team)
                user.saveInBackground()
                self.navigationController?.popViewControllerAnimated(true)
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            alertController.addAction(chooseAction)
            alertController.addAction(cancelAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
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
