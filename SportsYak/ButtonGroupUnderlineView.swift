//
//  ButtonGroupUnderlineView.swift
//  SportsYak
//
//  Created by Kurt Jensen on 8/7/15.
//  Copyright (c) 2015 Arbor Apps. All rights reserved.
//

import UIKit

protocol ButtonGroupUnderlineViewDelegate {
    func buttonGroupUnderlineViewDidSelectButtonAtIndex(index: Int)
}

class ButtonGroupUnderlineView: UIView {
    @IBOutlet var buttons: [UIButton]!
    var selectedButton : UIButton?
    var delegate: ButtonGroupUnderlineViewDelegate?
    var underline : UIView?
    var underlineThickness : CGFloat = 3
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutSubviews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addTargets()
        addUnderline()
        if (buttons.count > 0) {
            if let button = buttons.first {
                tapped(button)
            }
        }
    }
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        self.layoutSubviews()
    }
    
    convenience init () {
        self.init(frame:CGRectZero)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addTargets() {
        for button in buttons {
            button.addTarget(self, action: Selector("tapped:"), forControlEvents: UIControlEvents.TouchUpInside)
        }
    }
    
    func addUnderline() {
        if (self.underline == nil) {
            if let button = buttons.first {
                var frame = button.frame
                frame.origin.y = frame.size.height + underlineThickness
                frame.size.height = underlineThickness
                self.underline = UIView(frame: frame)
                self.underline!.alpha = 0
                self.addSubview(self.underline!)
            }
        }
    }
    
    func tapped(sender : UIButton) {
        for button in buttons {
            if button != sender {
                button.selected = false
            }
        }
        sender.selected = true
        self.selectedButton = sender
        if (self.delegate != nil) {
            if let index = find(buttons, sender) {
                self.delegate?.buttonGroupUnderlineViewDidSelectButtonAtIndex(index)
            }
        }
        if (self.underline != nil) && (self.selectedButton != nil) {
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.underline!.alpha = 1
                    self.underline!.backgroundColor = UIColor.blackColor()
                    let width = self.selectedButton!.frame.size.width/2.0
                    self.underline!.frame.size.width = width
                    self.underline!.frame.origin.x = self.selectedButton!.frame.origin.x + width/2.0
                })
        }
    }

}
