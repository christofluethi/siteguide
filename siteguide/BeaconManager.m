//
//  BeaconManager.m
//  siteguide
//
//  Created by Christof Luethi on 08.03.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import "BeaconManager.h"

NSString* const BEACON_API_CALL = @"/TestCockpit/api/1/site/%i/beacons";

@implementation BeaconManager {
    Site *site;
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
        [self reload];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(siteChanged:) name:kNotificationSiteChanged object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object: nil];
    }
    
    return self;
}

-(void)reload {
    NSData *encodedObject = [[NSUserDefaults standardUserDefaults] objectForKey:kSettingsSite];
    if(encodedObject) {
        site = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    }
    
    if(_beacons == nil) {
        _beacons = [[NSMutableArray alloc] init];
        _beaconDict = [[NSMutableDictionary alloc] init];
    } else {
        [_beacons removeAllObjects];
        [_beaconDict removeAllObjects];
    }
    
    if(site) {
        [self makeBeaconRequest];
    }
}

-(void)makeBeaconRequest {
    NSString* baseUrl = [[NSUserDefaults standardUserDefaults] stringForKey:kSettingsUrl];
    NSString* regionCall = [NSString stringWithFormat:@"%@%@", baseUrl, [NSString stringWithFormat:BEACON_API_CALL, site.siteId]];
    
    DLog(@"NetworkCall: %@", regionCall);
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:regionCall]
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                NSError *jsonError = nil;
                                                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                                                DLog(@"%@", json);
                                                
                                                if (jsonError) {
                                                    return;
                                                } 

                                                for (NSDictionary *dataDict in json) {
                                                    NSString *bid = [dataDict objectForKey:@"id"];
                                                    NSString *bname = [dataDict objectForKey:@"name"];
                                                    int major = [[dataDict objectForKey:@"major"] intValue];
                                                    int minor = [[dataDict objectForKey:@"minor"] intValue];
                                                    NSString *bpowerLevelOffset = [dataDict objectForKey:@"powerLevelOffset"];
                                                    /* uuid is site global - do not use here */
                                                    // NSString *buuid = [dataDict objectForKey:@"uuid"];
                                                    
                                                    Location *location = [[Location alloc] initWithDictionary:[dataDict objectForKey:@"position"]];
                                                    
                                                    Beacon *beacon = [[Beacon alloc] initWithName:bname beaconId:[bid intValue] major:major minor:minor location:location powerLevelOffset:[bpowerLevelOffset intValue]];
                                                    
                                                    [_beacons addObject:beacon];
                                                    [_beaconDict setObject:beacon forKey:[NSString stringWithFormat:@"%d/%d", major, minor]];
                                                }
                                            }];
    
    [dataTask resume];
}


-(void)siteChanged:(NSNotification *)notification {
    DLog("Received Notification SiteChanged");
    
    if ([[notification name] isEqualToString:kNotificationSiteChanged]) {
        [self reload];
    }
}

-(Beacon *)getBeaconByMajor:(int)major minor:(int)minor {
    return [_beaconDict objectForKey:[NSString stringWithFormat:@"%d/%d", major, minor]];
}

-(void)reachabilityChanged:(NSNotification *)notification {
    Reachability *r = [notification object];
    if( [r isKindOfClass: [Reachability class]]) {
        NetworkStatus status = [r currentReachabilityStatus];
        switch(status) {
            case NotReachable:
                break;
            case ReachableViaWiFi:
                [self reload];
                break;
            case ReachableViaWWAN:
                [self reload];
                break;
            default:
                DLog("Unknown");
                break;
        }
    }
}

@end
