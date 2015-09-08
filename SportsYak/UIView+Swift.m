//
//  UIView+Swift.m
//  TimeTracker
//
//  Created by Kurt Jensen on 8/25/15.
//  Copyright (c) 2015 Arbor Apps. All rights reserved.
//

#import "UIView+Swift.h"

@implementation UIView (Swift)

+ (instancetype)my_appearanceWhenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    return [self appearanceWhenContainedIn:containerClass, nil];
}

@end
