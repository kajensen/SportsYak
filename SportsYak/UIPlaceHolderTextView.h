//
//  UIPlaceHolderTextView.h
//  RouteMyRun
//
//  Created by Kurt Jensen on 8/29/14.
//  Copyright (c) 2014 Kurt Jensen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface UIPlaceHolderTextView : UITextView

@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;

-(void)textChanged:(NSNotification*)notification;

@end