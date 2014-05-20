//
//  PositionModeTableViewController.h
//  siteguide
//
//  Created by Christof Luethi on 12.02.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProximityStrategy.h"
#import "TrilaterationStrategy.h"
#import "MixedStrategy.h"
#import "ServerPositionStrategy.h"
#import "SensorManager.h"
#import "AppDelegate.h"

@class PositionModeTableViewController;

@protocol PositionModeTableViewControllerDelegate <NSObject>
- (void)positionModeTableViewController:(PositionModeTableViewController *)controller didSelectPositionMode:(NSUInteger *)positionMode;
@end

@interface PositionModeTableViewController : UITableViewController

@property (nonatomic, weak) id <PositionModeTableViewControllerDelegate> delegate;
@property (nonatomic, assign) NSUInteger positionMode;

@end
