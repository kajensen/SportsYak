//
//  ComposeViewController.swift
//  SportsYak
//
//  Created by Kurt Jensen on 8/7/15.
//  Copyright (c) 2015 Arbor Apps. All rights reserved.
//

import UIKit
import Parse
import AKPickerView

let MAX_TEXT_LENGTH = 200
let MAX_TITLE_LENGTH = 15

class ComposeViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, AKPickerViewDelegate, AKPickerViewDataSource {

    @IBOutlet var teamPickerView: AKPickerView!
    @IBOutlet var titleImageView: UIImageView!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var textView: UIPlaceHolderTextView!
    @IBOutlet var sendButton: UIBarButtonItem!
    
    @IBOutlet var mainView: UIView!
    @IBOutlet var charactersLabel: UILabel!
    var team : PFTeam?
    var teams = [PFTeam]()

    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var titleView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.setupPicker()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification : NSNotification) {
        let userInfo = notification.userInfo as! [String:AnyObject]
        if let keyboardFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            let intersect = CGRectIntersection(keyboardFrame, self.mainView.frame);
            //println("\(self.mainView.frame)")
            //println("\(self.titleView.frame)")
            if (!CGRectIsNull(intersect)) {

            }
            if let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue {
                UIView.animateWithDuration(NSTimeInterval(duration), animations: { () -> Void in
                    self.bottomConstraint.constant = keyboardFrame.height
                    //println("\(self.mainView.frame)")
                    //println("\(self.titleView.frame)")
                })
            }
        }
    }
    
    func keyboardWillHide(notification : NSNotification) {
        let userInfo = notification.userInfo as! [String:AnyObject]
        if let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue {
            UIView.animateWithDuration(duration, animations: { () -> Void in
                self.bottomConstraint.constant = 0
            })
        }
    }
    
    func setupView() {
        self.textView.text = ""
        self.textView.placeholder = "What's on your mind?"
        self.charactersLabel.text = "\(MAX_TEXT_LENGTH)"
        checkSendEnablility()
    }
    
    func setupPicker() {
        self.teamPickerView.delegate = self;
        self.teamPickerView.dataSource = self;
        self.teamPickerView.font = UIFont(name: "DIN Alternate", size: 15)!
        self.teamPickerView.highlightedFont = UIFont(name: "DINAlternate-Bold", size: 15)!
        if let user = PFMember.currentUser() {
            self.teams = user.teams()
        }
        self.teamPickerView.reloadData()
        if (self.teams.count > 0) {
            self.teamPickerView.selectItem(0, animated: false)
        }
    }
    
    func numberOfItemsInPickerView(pickerView: AKPickerView!) -> UInt {
        return UInt(self.teams.count)
    }
    
    func pickerView(pickerView: AKPickerView!, titleForItem item: Int) -> String! {
        let team = self.teams[item]
        return team.name
    }
    
    func pickerView(pickerView: AKPickerView!, didSelectItem item: Int) {
        self.team = self.teams[item]
        self.checkSendEnablility()
    }
    
    func checkSendEnablility() {
        let hasText = !(self.textView.text.isEmpty)
        let hasTeam = self.team != nil
        self.sendButton.enabled = (hasText && hasTeam)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if (self.teams.count > 0) {
            self.textView.becomeFirstResponder()
        }
        else {
            let alertController = UIAlertController(title: "No teams", message: "You need at least one team before you can post. Go to the 'more' tab", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (alertAction) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            alertController.addAction(okAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.textView.becomeFirstResponder()
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        /*if (self.sendButton.enabled) {
            self.send(self.sendButton)
        }*/
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        let currentString = textView.text as NSString
        let proposedNewString = currentString.stringByReplacingCharactersInRange(range, withString: text) as String
        if (proposedNewString.characters.count < MAX_TEXT_LENGTH) {
            self.charactersLabel.text = "\(MAX_TEXT_LENGTH-proposedNewString.characters.count)"
            return true
        }
        return false
    }
    
    func textViewDidChange(textView: UITextView) {
        checkSendEnablility()
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let currentString = textField.text! as NSString
        let proposedNewString = currentString.stringByReplacingCharactersInRange(range, withString: string)
        if (proposedNewString.characters.count < MAX_TITLE_LENGTH) {
            self.titleImageView.highlighted = proposedNewString.characters.count > 0
            return true
        }
        return false
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func send(sender: AnyObject) {
        let post = PFPost(team: self.team, title: self.titleTextField.text!, text: self.textView.text)
        if post.user != nil && post.location != nil { // TODO doesn't need a team?
            post.saveInBackground()
            self.dismissViewControllerAnimated(true, completion: nil)
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
