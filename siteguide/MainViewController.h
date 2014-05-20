//
//  MainViewController.h
//  siteguide
//
//  Created by Christof Luethi on 10.02.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AdSupport/ASIdentifierManager.h>
#import "AppDelegate.h"

@interface MainViewController : UIViewController
/*@property (weak, nonatomic) IBOutlet UIButton *monitoringToggle;*/
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIButton *listButton;
@property (weak, nonatomic) IBOutlet UIButton *debugButton;
@property (weak, nonatomic) IBOutlet UIButton *mapButton;
@property (weak, nonatomic) IBOutlet UILabel *positionLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastPositionTime;
@property (weak, nonatomic) IBOutlet UILabel *lastPositionLabel;
- (IBAction)aboutAction:(id)sender;

-(void)reachabilityChanged:(NSNotification *)notification;
/*-(void)fixManagerState;*/
@end
