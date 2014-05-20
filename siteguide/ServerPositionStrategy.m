//
//  ServerPositionStrategy.m
//  siteguide
//
//  Created by Christof Luethi on 10.03.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import "ServerPositionStrategy.h"



NSString *const SERVER_POSITION_API_CALL = @"/TestCockpit/api/1/trackingSession/%i/lastCalculatedPosition";
NSString *const SERVER_POSITION_API_CALL_MOCK = @"http://dev.shaped.ch/posMock";


@implementation ServerPositionStrategy
-(Location *)calculateWithSensorData:(MonomorphicArray *)data {
    return [self makePositionRequest];
}

-(NSString *)name {
    return @"ServerPositionStrategy";
}


-(Location *)makePositionRequest {
    Location *l = nil;
    
    NSString* baseUrl = [[NSUserDefaults standardUserDefaults] stringForKey:kSettingsUrl];
    NSString* positionCall = [NSString stringWithFormat:@"%@%@", baseUrl, [NSString stringWithFormat:SERVER_POSITION_API_CALL, STATIC_TRACKING_SESSION]];
    
    DLog(@"NetworkCall: %@", positionCall);
    
    // Send a synchronous request
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:positionCall] cachePolicy:NSURLCacheStorageAllowedInMemoryOnly timeoutInterval:1];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    
    /*
     [
        {"x":4.346718805175176,"y":38.191974850769135},
        {"x":4.346718805175176,"y":38.191974850769135}
     ]
     */
    
    if (error == nil) {
        NSError *jsonError = nil;
        NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        DLog(@"%@", json);
        
        if (!jsonError && [json count] > 0) {
            NSDictionary *firstPos = [json objectAtIndex:0];
            double xCoord = [[firstPos objectForKey:@"x"] doubleValue];
            double yCoord = [[firstPos objectForKey:@"y"] doubleValue];
            l = [[Location alloc] initWithXCoordinate:xCoord YCoordinate:yCoord];
        }
    }
    
    return l;
}


@end
