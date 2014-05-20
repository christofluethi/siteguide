//
//  Constants.m
//  siteguide
//
//  Created by Christof Luethi on 10.02.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import "Constants.h"

// Settings
NSString *const kSettingsSite = @"site";
NSString *const kSettingsUrl = @"baseUrl";
NSString *const kSettingsLogging = @"loggingActive";
NSString *const kSettingsPositionFeedback = @"positionFeedbackActive";
NSString *const kSettingsSimulationMode = @"simulationMode";
NSString *const kSettingsPositionMode = @"positionMode";
NSString *const kSettingsSortMode = @"sortMode";
NSString *const kSettingsProximityTolerance = @"proximityTolerance";

// Notifications
NSString *const kNotificationPositionUpdate = @"PositionUpdate";
NSString *const kNotificationSiteChanged = @"SiteChanged";
NSString *const kNotificationPositioningStrategyChanged = @"PositioningStrategyChanged";


// Debug
NSString *const kSettingsShowBeacon = @"showBeacon";
NSString *const kSettingsDebugXCoord = @"DebugXPosition";
NSString *const kSettingsDebugYCoord = @"DebugYPosition";
NSString *const kSettingsIsDebug = @"isDebug";
NSString *const kSettingsIsDebugPosition = @"fakePosition";


// Tracking Session
const int STATIC_TRACKING_SESSION = 315075;

@implementation Constants

@end
