//
//  SiteGuidePositioningStrategy.h
//  siteguide
//
//  Created by Christof Luethi on 10.03.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Location.h"
#import "MonomorphicArray.h"
#import "SensorData.h"
#import "BeaconManager.h"
#import "Beacon.h"

@protocol SiteGuidePositioningStrategy <NSObject>

@required
-(Location *)calculateWithSensorData:(MonomorphicArray *)data;
-(NSString *)name;
@end
