//
//  HideBarsOnSwipeViewController.swift
//  SportsYak
//
//  Created by Kurt Jensen on 8/23/15.
//  Copyright (c) 2015 Arbor Apps. All rights reserved.
//

import UIKit

class HideBarsOnSwipeViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var topViews: [AnyObject]?
    @IBOutlet var bottomViews: [AnyObject]?
    var isDragging = false
    var refreshControl : BOZPongRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if (self.refreshControl == nil) {
            self.refreshControl = BOZPongRefreshControl.attachToTableView(self.tableView, withRefreshTarget: self, andRefreshAction: "refreshTriggered")
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.refreshControl.scrollViewDidScroll()
    }
    
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.refreshControl.scrollViewDidEndDragging()
    }
    
    func refreshTriggered() {
        self.loadData(true)
    }
    
    func refreshFinished() {
        self.refreshControl.finishedLoading()
    }
    
    func loadData(forceDownload: Bool) {
        self.refreshControl.finishedLoading()
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        isDragging = true
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        //self.navigationController?.setToolbarHidden(true, animated: true)
        //self.setTabBarVisible(false, animated: true)
        if (self.topViews != nil) {
            for view in self.topViews! {
                setViewHidden(view, hidden: false, animated: true)
            }
        }
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        isDragging = false
        self.performSelector("hideBarsDelay", withObject: nil, afterDelay: 3)
    }
    
    func hideBarsDelay() {
        if (!isDragging) {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            
            //self.navigationController?.setToolbarHidden(false, animated: true)
            //self.setTabBarVisible(true, animated: true)
            if (self.topViews != nil) {
                for view in self.topViews! {
                    setViewHidden(view, hidden: true, animated: true)
                }
            }
        }
    }
    
    func setTabBarHidden(hidden:Bool, animated:Bool) {
        if let tabBarController = self.tabBarController {
            let frame = tabBarController.tabBar.frame
            let height = frame.size.height
            let offsetY = (hidden ? height : -height)
            let duration:NSTimeInterval = (animated ? 0.3 : 0.0)
            
            UIView.animateWithDuration(duration) {
                self.tabBarController?.tabBar.frame = CGRectOffset(frame, 0, offsetY)
                return
            }
        }
    }
    
    func setViewHidden(object: AnyObject!, hidden:Bool, animated:Bool) {
        if let view = object as? UIView {
            let frame = view.frame
            let height = frame.size.height
            let offsetY = (hidden ? 0 : -height)
            let duration:NSTimeInterval = (animated ? 0.3 : 0.0)
            
            UIView.animateWithDuration(duration) {
                view.frame = CGRectOffset(frame, 0, offsetY)
                return
            }
        }
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
