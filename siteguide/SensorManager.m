//
//  SensorManager.m
//  siteguide
//
//  Created by Christof Luethi on 20.02.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import "SensorManager.h"

NSString *const LOG_SENSORDATA_API_CALL = @"/TestCockpit/api/1/trackingSession/%i/beaconData";
const int DISPATCH_QUEUE_AFTER = 50;

@implementation SensorManager {
    ESTBeaconManager *beaconManager;
    ESTBeaconRegion *beaconRegion;
    Site *site;
    SensorDataQueue *queue;
    SensorDataQueue *loggerQueue;
    bool isRunning;
    bool isLogging;
}

/* yes this is a singleton */
+ (id)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

-(id)init {
    self = [super init];
    
    if(self) {
        beaconManager = [ESTBeaconManager new];
        beaconManager.delegate = self;
        beaconManager.avoidUnknownStateBeacons = YES;
        queue = [[SensorDataQueue alloc] init];
        isRunning = NO;
        NSData *encodedObject = [[NSUserDefaults standardUserDefaults] objectForKey:kSettingsSite];
        if(encodedObject) {
            site = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
        }
        isLogging = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingsLogging];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(siteChanged:) name:kNotificationSiteChanged object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object: nil];
    }
    
    return self;
}

-(void)siteChanged:(NSNotification *)notification {
    DLog("Received Notification SiteChanged");
    
    if ([[notification name] isEqualToString:kNotificationSiteChanged]) {
        [self restart];
    }
}

-(void)setHandler:(SiteGuideDataHandler *)handler {
    _handler = handler;
}

-(void)restart {
    if(isRunning) {
        [self stop];
    }
    
    DLog("Restarting SensorManager...");
    NSData *encodedObject = [[NSUserDefaults standardUserDefaults] objectForKey:kSettingsSite];
    if(encodedObject) {
        site = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    }
    
    isLogging = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingsLogging];
    
    [queue clear];
    if(site) {
        [self startBeaconMonitoring];
        isRunning = YES;
    }
}

-(bool)isRunning {
    return isRunning;
}

-(void)start {
    [self restart];
}

-(void)stop {
    if(site) {
        [self stopBeaconMonitoring];
        isRunning = NO;
    }
}

-(void)startBeaconMonitoring {
    // create sample region with major value defined
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:site.beaconUUID];
    
    /* do nothing if we have no UUID */
    if(!uuid) {
        return;
    }
    beaconRegion = [[ESTBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"siteguide"];
    
    [beaconManager startRangingBeaconsInRegion:beaconRegion];
    DLog("Start monitoring for region: %@", site.beaconUUID);
}

-(void)stopBeaconMonitoring {
    [beaconManager stopRangingBeaconsInRegion:beaconRegion];
    
    isRunning = NO;
    DLog("Stop monitoring for region %@", site.beaconUUID);
}



-(void)beaconManager:(ESTBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region {
    // DLog(@"Beacons: %lu", (long int)[beacons count]);
    
    // This is just for debugging. Remove later
    BOOL debugPosition = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingsIsDebugPosition];
    if(debugPosition) {
        DLog("SensorManager is in Debug Position Mode.");
        MonomorphicArray *dataArr = [[MonomorphicArray alloc] initWithClass:[SensorData class] andCapacity:[beacons count]];
        SensorData *data = [[SensorData alloc] initWithType:fakeDebugData];
        [dataArr addObject:data];
        if(_handler != nil) {
            [_handler handleData:dataArr];
        }
    } else if(beacons && [beacons count] > 0) {
        MonomorphicArray *dataArr = [[MonomorphicArray alloc] initWithClass:[SensorData class] andCapacity:[beacons count]];
        long currentTime = ((long)[[NSDate date] timeIntervalSince1970]) * 1000;
        
        for (int i = 0; i < [beacons count]; i++) {
            ESTBeacon *beacon = [beacons objectAtIndex:i];
            // DLog("%i, %ld, [%@/%@], %@", i, (long)beacon.rssi, beacon.major, beacon.minor, beacon.distance);
            // DLog("Beacon: Major[%@] Minor[%@] RSSI[%ld]", beacon.major, beacon.minor, (long)beacon.rssi);
            SensorData *data = [[SensorData alloc] initWithType:iBeaconData];
            [data setObject:[NSNumber numberWithLong:currentTime] forKey:@"timestamp"];
            [data setObject:beacon.major forKey:@"major"];
            [data setObject:beacon.minor forKey:@"minor"];
            [data setObject:beacon.distance forKey:@"distance"];
            [data setObject:[NSNumber numberWithLong:beacon.rssi] forKey:@"rssi"];
            [dataArr addObject:data];
            
            if(isLogging) {
                [queue enqueue:data];
            }
        }
        
        if(_handler != nil) {
            [_handler handleData:dataArr];
        } else {
            DLog("SensorManager has no handlers set.");
        }
        
        if([queue size] > DISPATCH_QUEUE_AFTER) {
            SensorDataQueue *logQueue = [[SensorDataQueue alloc] init];
            [logQueue enqueueElementsFromQueue:queue];
            DLog("Queue is > %i: %lu", DISPATCH_QUEUE_AFTER, (unsigned long)[queue size]);
            [self dispatchQueue:logQueue];
        }
    }
}

/*
 * Quick implementation of server logging.
 * session and deviceid are hardcoded.
 */
-(void)dispatchQueue:(SensorDataQueue *)logQueue {
    NSString* baseUrl = [[NSUserDefaults standardUserDefaults] stringForKey:kSettingsUrl];
    NSString* beaconLoggerCall = [NSString stringWithFormat:@"%@%@", baseUrl, [NSString stringWithFormat:LOG_SENSORDATA_API_CALL, STATIC_TRACKING_SESSION]];

    NSError *error;
    
    DLog("Network Call: %@", beaconLoggerCall);
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURL *url = [NSURL URLWithString:beaconLoggerCall];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [request setHTTPMethod:@"POST"];

    NSMutableArray *array = [[NSMutableArray alloc] init];
    while ([logQueue size] > 0) {
        SensorData *d = [logQueue dequeue];
        NSMutableDictionary *sensorData = [[NSMutableDictionary alloc] init];
        [sensorData setObject:site.beaconUUID forKey:@"uuid"];
        [sensorData setObject:[NSNumber numberWithLong:[[d objectForKey:@"timestamp"] integerValue]] forKey:@"timestamp"];
        [sensorData setObject:[NSString stringWithFormat:@"%@", [d objectForKey:@"minor"]] forKey:@"minor"];
        [sensorData setObject:[NSString stringWithFormat:@"%@", [d objectForKey:@"major"]] forKey:@"major"];
        [sensorData setObject:[NSString stringWithFormat:@"%@", [d objectForKey:@"rssi"]] forKey:@"rssi"];
        [sensorData setObject:[NSString stringWithFormat:@"%@", [d objectForKey:@"distance"]] forKey:@"accuracy"];
        [sensorData setObject:@"0" forKey:@"macAddress"];
        [sensorData setObject:@"UNKNOWN" forKey:@"proximity"];
        [sensorData setObject:@"0" forKey:@"measuredPower"];
        [array addObject:sensorData];
    }
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:array options:0 error:&error];
    [request setHTTPBody:postData];
    DLog("Data: %@", [NSString stringWithUTF8String:[postData bytes]]);
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *r = [NSString stringWithUTF8String:[data bytes]];
        
        if([@"ok" caseInsensitiveCompare:r] == NSOrderedSame) {
            DLog("POST Request Successfull");
        } else {
            DLog("POST Request Failed");
        }
    }];
    
    [postDataTask resume];
}

-(void)reachabilityChanged:(NSNotification *)notification {
    Reachability *r = [notification object];
    if( [r isKindOfClass: [Reachability class]]) {
        NetworkStatus status = [r currentReachabilityStatus];
        switch(status) {
            case NotReachable:
                [self stop];
                break;
            case ReachableViaWiFi:
                [self start];
                break;
            case ReachableViaWWAN:
                [self start];
                break;
            default:
                DLog("Unknown");
                break;
        }
    }
}

@end
