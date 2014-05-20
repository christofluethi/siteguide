//
//  AppDelegate.m
//  siteguide
//
//  Created by Christof Luethi on 10.02.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    /* setting default user settings */
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:NO], kSettingsLogging,
                                 [NSNumber numberWithBool:NO], kSettingsPositionFeedback,
                                 [NSNumber numberWithInt:simulationModeNone], kSettingsSimulationMode,
                                 [NSNumber numberWithInt:positionModeProximity], kSettingsPositionMode,
                                 [NSNumber numberWithFloat:1.0], kSettingsProximityTolerance,
                                 nil];
    
    DLog(@"%@", appDefaults);
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    /* end user settings */
    
    
    /* sensor */
    SensorManager *sensorManager = [SensorManager sharedInstance];
    SiteGuideDataHandler *calibration = [[CalibrationModule alloc] init];
    SiteGuideDataHandler *positioning = [[PositionCalculationModule alloc] init];
    [calibration setNext:positioning];
    [sensorManager setHandler:calibration];
    
    DLog("Starting SensorManager...");
    [sensorManager start];
    /* end sensor */
    
    DLog("Initialize RegionManager...");
    [RegionManager sharedInstance];
    
    /* configure navigation bar color */
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:89/255.0f green:174/255.0f blue:235/255.0f alpha:1.0f]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    
    NSDictionary *titleAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [[UINavigationBar appearance] setTitleTextAttributes:titleAttributes];
    /*[[UINavigationBar appearance] setTranslucent:YES];*/
    
    return YES;
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
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
