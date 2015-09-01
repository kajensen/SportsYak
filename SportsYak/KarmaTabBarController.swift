//
//  KarmaTabBarController.swift
//  SportsYak
//
//  Created by Kurt Jensen on 8/31/15.
//  Copyright (c) 2015 Arbor Apps. All rights reserved.
//

import UIKit

class KarmaTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateKarma", name: Notifications.KARMA_UPDATED, object: nil)
    }
    
    func updateKarma() {
        for viewController in self.childViewControllers as! [UIViewController] {
            if let karmaNavigationController = viewController as? KarmaNavigationController {
                karmaNavigationController.updateKarma()
            }
        }
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
