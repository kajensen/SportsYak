//
//  KarmaNavigationController.swift
//  SportsYak
//
//  Created by Kurt Jensen on 8/23/15.
//  Copyright (c) 2015 Arbor Apps. All rights reserved.
//

import UIKit

class KarmaNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateKarma()
    }
    
    func updateKarma() {
        if let childViewController = self.childViewControllers.first {
            if let leftBarButton = childViewController.navigationItem.leftBarButtonItem {
                if let customView = leftBarButton.customView {
                    for subView in customView.subviews {
                        if let countingView = subView as? UICountingLabel {
                            if let user = PFMember.currentUser() {
                                countingView.countFromZeroTo(CGFloat(user.contentKarma+user.voteKarma))
                            }
                        }
                    }
                }
            }
            else {
                let frame = CGRectMake(0, 0, 40, 80)
                let countingButton = UIButton(frame: frame)
                countingButton.addTarget(self, action: "viewKarma", forControlEvents: UIControlEvents.TouchUpInside)
                let countingLabel = UICountingLabel(frame: frame)
                countingLabel.textColor = Constants.GLOBAL_TINT
                countingLabel.textAlignment = NSTextAlignment.Left
                countingLabel.format = "%d"
                countingButton.addSubview(countingLabel)
                let leftBarButton = UIBarButtonItem(customView: countingButton)
                if let user = PFMember.currentUser() {
                    countingLabel.countFromZeroTo(CGFloat(user.contentKarma+user.voteKarma))
                }
                childViewController.navigationItem.setLeftBarButtonItem(leftBarButton, animated: false)
            }
        }
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
