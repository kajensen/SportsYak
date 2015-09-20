//
//  KarmaViewController.swift
//  SportsYak
//
//  Created by Kurt Jensen on 8/23/15.
//  Copyright (c) 2015 Arbor Apps. All rights reserved.
//

import UIKit

class KarmaViewController: UIViewController {

    @IBOutlet var karmaView: UIView!
    @IBOutlet var karmaLabel: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var shareView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.karmaView.layer.cornerRadius = self.karmaView.frame.size.width/2.0
        self.karmaView.layer.masksToBounds = true
        
        if let user = PFMember.currentUser() {
            self.karmaLabel.text = "\(user.contentKarma+user.voteKarma)"
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "share:")
        self.shareView.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.scrollView.layoutSubviews()
        
        let csz = self.scrollView.contentSize
        let bsz = self.scrollView.bounds.size
        
        UIView.animateWithDuration(5.0, animations: { () -> Void in
            let contentOffset = CGPointMake(self.scrollView.contentOffset.x,
                csz.height - bsz.height)
            self.scrollView.contentOffset = contentOffset
        })
    }

    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func share(sender: AnyObject) {
        let text = "Share gameday with your squads. Talk smack, embrace victory, join your sports community with SportsYak @sportsyak."

        let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.shareView

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
