//
//  SensorManager.h
//  siteguide
//
//  Created by Christof Luethi on 20.02.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESTBeaconManager.h"
#import "Site.h"
#import "SensorDataQueue.h"
#import "SensorData.h"
#import "SiteGuideDataHandler.h"
#import "MonomorphicArray.h"
#import "Reachability.h"

/**
 Sonsor Manager captures SensorData. Currently Siteguide uses only iBeacon Bluetooth LE data.
 Implementation of Sensormanager is a singleton
 */
@interface SensorManager : NSObject <ESTBeaconManagerDelegate>

@property (nonatomic, strong) SiteGuideDataHandler *handler;
+(id)sharedInstance;
-(void)start;
-(void)stop;
-(void)restart;
-(void)startBeaconMonitoring;
-(void)stopBeaconMonitoring;
-(bool)isRunning;
-(void)setHandler:(SiteGuideDataHandler *)handler;
-(void)reachabilityChanged:(NSNotification *)notification;
@end
