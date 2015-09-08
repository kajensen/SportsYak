//
//  SplashViewController.swift
//  SportsYak
//
//  Created by Kurt Jensen on 9/3/15.
//  Copyright (c) 2015 Arbor Apps. All rights reserved.
//

import UIKit
import Parse

class SplashViewController: UIViewController {
    var requiredVersion : NSNumber?
    
    @IBOutlet var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let config = PFConfig.getConfig() {
            self.requiredVersion = config["requiredVersion"] as? NSNumber
        }
        self.validateApp()
    }
    
    func validateApp() {
        var isValid = true
        if (self.requiredVersion != nil) {
            if let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
                if let build = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String {
                    self.versionLabel.text = "Version \(version) (\(build))"
                }
                let versionNumber = (version as NSString).floatValue
                let versionNumberRequired = self.requiredVersion!.floatValue
                if (versionNumber < versionNumberRequired) {
                    isValid = false
                }
            }
        }
        
        if (isValid) {
            showApp()
        }
        else {
            promptUpgrade()
        }
    }
    
    func promptUpgrade() {
        if let appId = NSBundle.mainBundle().infoDictionary?["CFBundleIdentifier"] as? String {
            var alertController = UIAlertController(title: "Invalid App Version", message: "Please upgrade the app.", preferredStyle: UIAlertControllerStyle.Alert)
            let chooseAction = UIAlertAction(title: "App Store", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                let itunesLink = "http://itunes.apple.com/us/app/\(appId)"
                UIApplication.sharedApplication().openURL(NSURL(string: itunesLink)!)
            })
            alertController.addAction(chooseAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func showApp() {
        self.performSegueWithIdentifier("Home", sender: nil)
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
