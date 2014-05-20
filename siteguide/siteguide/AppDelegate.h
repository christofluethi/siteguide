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
#import "SiteGuideDataHandler.h"
#import "CalibrationModule.h"
#import "PositionCalculationModule.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@end
