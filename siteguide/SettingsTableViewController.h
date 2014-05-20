//
//  SettingsTableViewController.h
//  siteguide
//
//  Created by Christof Luethi on 11.02.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PositionModeTableViewController.h"
#import "SiteNameTableViewController.h"
#import "SensorManager.h"


@interface SettingsTableViewController : UITableViewController<UITextFieldDelegate, PositionModeTableViewControllerDelegate, SiteNameTableViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *loggingSwitch;
@property (weak, nonatomic) IBOutlet UITextField *urlTextfield;
@property (weak, nonatomic) IBOutlet UILabel *simulationModeLabel;
@property (weak, nonatomic) IBOutlet UILabel *positionModeLabel;
@property (weak, nonatomic) IBOutlet UILabel *siteNameLabel;
@property (weak, nonatomic) IBOutlet UISwitch *debugSwitch;
- (IBAction)switchDebugMode:(id)sender;
- (IBAction)switchShowBeaconMode:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *debugPositionLabel;
@property (weak, nonatomic) IBOutlet UISwitch *showBeaconSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *debugPositionSwitch;
- (IBAction)switchDebugPosition:(id)sender;
@end
