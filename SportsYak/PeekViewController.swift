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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData() {
        if let user = PFMember.currentUser() {
            var query = PFEvent.query()
            if query != nil {
                println("fetching events")
                query!.findObjectsInBackgroundWithBlock {
                    (objects: [AnyObject]?, error: NSError?) -> Void in
                    
                    if error == nil {
                        println("Successfully retrieved \(objects!.count) events.")
                        if let objects = objects as? [PFEvent] {
                            for object in objects {
                                println(object.objectId)
                            }
                            self.events = objects
                            self.tableView.reloadData()
                        }
                    } else {
                        println("Error: \(error!) \(error!.userInfo!)")
                    }
                }
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
        let cell = tableView.dequeueReusableCellWithIdentifier("EventCell", forIndexPath: indexPath) as! UITableViewCell
        let event = self.events[indexPath.row]
        cell.textLabel!.text = event.name
        
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
