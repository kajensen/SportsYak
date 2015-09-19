//
//  PeekViewController.swift
//  SportsYak
//
//  Created by Kurt Jensen on 8/7/15.
//  Copyright (c) 2015 Arbor Apps. All rights reserved.
//

import UIKit
import Parse

class PeekViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    var events = [PFEvent]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRowAtIndexPath(selectedIndexPath, animated: false)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData() {
        if let _ = PFMember.currentUser() {
            if let query = PFEvent.query() {
                print("fetching events")
                query.findObjectsInBackgroundWithBlock {
                    (objects: [AnyObject]?, error: NSError?) -> Void in
                    
                    if error == nil {
                        print("Successfully retrieved \(objects!.count) events.")
                        if let objects = objects as? [PFEvent] {
                            for object in objects {
                                print(object.objectId)
                            }
                            self.events = objects
                            self.tableView.reloadData()
                            self.tableView.hidden = false
                        }
                    } else {
                        print("Error: \(error!) \(error!.userInfo)")
                    }
                }
                self.tableView.hidden = true
            }
        }
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.events.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EventCell", forIndexPath: indexPath) 
        let event = self.events[indexPath.row]
        cell.textLabel!.text = "\(event.teamOneName) vs \(event.teamTwoName)"
        if (event.live) {
            cell.imageView?.image = UIImage(named: "Filled Circle-100")
        }
        else {
            cell.imageView?.image = nil
        }
        
        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "ViewEvent") {
            if let eventViewController = segue.destinationViewController as? EventViewController {
                if let cell = sender as? UITableViewCell {
                    if let indexPath = self.tableView.indexPathForCell(cell) {
                        let event = self.events[indexPath.row]
                        eventViewController.event = event
                    }
                }
            }
        }
    }

}
