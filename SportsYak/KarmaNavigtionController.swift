//
//  KarmaNavigtionController.swift
//  SportsYak
//
//  Created by Kurt Jensen on 8/23/15.
//  Copyright (c) 2015 Arbor Apps. All rights reserved.
//

import UIKit

class KarmaNavigtionController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        let leftBarButton = UIBarButtonItem(title: "Karma", style: UIBarButtonItemStyle.Plain, target: self, action: "viewKarma")
        if let childViewController = self.childViewControllers.first as? UIViewController {
            childViewController.navigationItem.setLeftBarButtonItem(leftBarButton, animated: false)
        }
        super.viewWillAppear(animated)
    }
    
    func viewKarma() {
        let karmaViewController = self.storyboard?.instantiateViewControllerWithIdentifier("KarmaViewController") as! UINavigationController
        self.presentViewController(karmaViewController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
