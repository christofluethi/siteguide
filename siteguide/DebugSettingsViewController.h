//
//  DebugSettingsViewController.h
//  siteguide
//
//  Created by Christof Luethi on 13.03.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DebugSettingsViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *xCoordTextfield;
@property (weak, nonatomic) IBOutlet UITextField *yCoordTextfield;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
- (IBAction)save:(id)sender;

@end
