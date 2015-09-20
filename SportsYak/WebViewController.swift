//
//  WebViewController.swift
//  SportsYak
//
//  Created by Kurt Jensen on 9/20/15.
//  Copyright © 2015 Arbor Apps. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

    @IBOutlet var webView: UIWebView!
    var url : NSURL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if (url != nil) {
            let urlRequest = NSURLRequest(URL: url!)
            self.webView.loadRequest(urlRequest)
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
