//
//  constants.h
//  siteguide
//
//  Created by Christof Luethi on 10.02.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

/* function to log output. only log if DEBUG=1 */
#ifdef DEBUG
    #define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
    #define DLog(...)
#endif

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

/* simulation modes. currently unused */
typedef enum SimulationMode {
    simulationModeNone = 0,
    simulationModeSensors = 1,
    simulationModePosition = 2
} simulationMode;

/* position modes */
typedef enum PositionMode {
    positionModeProximity = 0,
    positionModePosition = 1,
    positionModeMixed = 2,
    positionModePositionServer = 3,
    positionModeDebug = 4
} positionMode;

/* sort modes */
typedef enum SortMode {
    sortModeNameDescending = 0,
    sortModeNameAscending = 1,
    sortModeDistance = 2,
} sortMode;

/* type of sensordate */
typedef enum SensorDataType {
    iBeaconData = 0,
    fakeDebugData =1
} sensorDataType;


/* settings */
extern NSString *const kSettingsSite;
extern NSString *const kSettingsUrl;
extern NSString *const kSettingsLogging;
extern NSString *const kSettingsPositionFeedback;
extern NSString *const kSettingsSimulationMode;
extern NSString *const kSettingsPositionMode;
extern NSString *const kSettingsSortMode;
extern NSString *const kSettingsProximityTolerance;
extern NSString *const kSettingsShowBeacon;

// Notifications
extern NSString *const kNotificationPositionUpdate;
extern NSString *const kNotificationSiteChanged;
extern NSString *const kNotificationPositioningStrategyChanged;

// Debug Position
extern NSString *const kSettingsDebugXCoord;
extern NSString *const kSettingsDebugYCoord;
extern NSString *const kSettingsIsDebug;
extern NSString *const kSettingsIsDebugPosition;

/* tracking session */
const int STATIC_TRACKING_SESSION;

@interface Constants : NSObject

@end
