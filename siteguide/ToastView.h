//
//  ToastView.h
//  siteguide
//
//  Created by Stefan Wagner on 16.03.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface ToastView : UIView

@property (strong, nonatomic) UILabel *textLabel;
+ (void)showToastInParentView: (UIView *)parentView withText:(NSString *)text withDuaration:(float)duration;

@end