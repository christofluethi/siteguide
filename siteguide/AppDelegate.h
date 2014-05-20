//
//  AppDelegate.h
//  siteguide
//
//  Created by Christof Luethi on 11.02.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SensorManager.h"
#import "RegionManager.h"
#import "BeaconManager.h"
#import "SiteGuideDataHandler.h"
#import "CalibrationModule.h"
#import "PositionCalculationModule.h"
#import "ProximityStrategy.h"
#import "TrilaterationStrategy.h"
#import "MixedStrategy.h"
#import "ServerPositionStrategy.h"
#import "Reachability.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

-(Reachability *)getReachability;
@end
