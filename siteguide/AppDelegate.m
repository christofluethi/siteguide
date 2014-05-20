//
//  AppDelegate.m
//  siteguide
//
//  Created by Christof Luethi on 10.02.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate {
    Reachability *reachability;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    /* setting default user settings */
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:NO], kSettingsLogging,
                                 [NSNumber numberWithBool:NO], kSettingsPositionFeedback,
                                 [NSNumber numberWithBool:YES], kSettingsShowBeacon,
                                 [NSNumber numberWithInt:0], kSettingsDebugXCoord,
                                 [NSNumber numberWithInt:0], kSettingsDebugYCoord,
                                 [NSNumber numberWithBool:NO], kSettingsIsDebug,
                                 [NSNumber numberWithBool:NO], kSettingsIsDebugPosition,
                                 [NSNumber numberWithInt:simulationModeNone], kSettingsSimulationMode,
                                 [NSNumber numberWithInt:positionModeProximity], kSettingsPositionMode,
                                 [NSNumber numberWithInt:sortModeNameDescending], kSettingsSortMode,
                                 [NSNumber numberWithFloat:1.0], kSettingsProximityTolerance,
                                 nil];
    
    DLog(@"%@", appDefaults);
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    /* end user settings */
    
    
    /* 
     Reachability
     Check network connection 
     */
    reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    /* end reachability */
    
    
    /* sensor stuff */
    
    /* 
     * the positioningMode should be set at one point only. appdelegate should not know all strategies.
     * needs to be refactored. This code is also at PositionModeTableViewController.
     *
     * this code should be removed here
     *
     * since we set a default value for PositionMode we are save here.
     */
    int mode = (int)[[NSUserDefaults standardUserDefaults] integerForKey:kSettingsPositionMode];
    id strategy = nil;
    if(mode == positionModeProximity) {
        strategy = [[ProximityStrategy alloc] init];
    } else if(mode == positionModePosition) {
        strategy = [[TrilaterationStrategy alloc] init];
    } else if(mode == positionModeMixed) {
        strategy = [[MixedStrategy alloc] init];
    } else if(mode == positionModePositionServer) {
        strategy = [[ServerPositionStrategy alloc] init];
    }
    
    
    /* setup sensor processing chain */
    SensorManager *sensorManager = [SensorManager sharedInstance];
    SiteGuideDataHandler *calibration = [[CalibrationModule alloc] init];
    SiteGuideDataHandler *positioning = [[PositionCalculationModule alloc] initWithStrategy:strategy];
    [calibration setNext:positioning];
    [sensorManager setHandler:calibration];
    
    DLog("Starting SensorManager...");
    [sensorManager start];
    /* end sensor */
    
    DLog("Initialize RegionManager...");
    [RegionManager sharedInstance];
    
    DLog("Initialize BeaconManager...");
    [BeaconManager sharedInstance];

    
    
    /* configure navigation bar color */
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:40/255.0f green:61/255.0f blue:82/255.0f alpha:1.0f]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    
    NSDictionary *titleAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [[UINavigationBar appearance] setTitleTextAttributes:titleAttributes];
    
    return YES;
}

-(Reachability *)getReachability {
    return reachability;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    DLog("Stopping SensorManager...");
    [[SensorManager sharedInstance] stop];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    DLog("Starting SensorManager...");
    [[SensorManager sharedInstance] restart];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
@end
