//
//  PositionCalculationModule.m
//  siteguide
//
//  Created by Christof Luethi on 24.02.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import "PositionCalculationModule.h"

@implementation PositionCalculationModule

-(id)initWithStrategy:(id)s {
    self = [super init];
    if (self) {
        strategy = s;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(positionStrategyChanged:) name:kNotificationPositioningStrategyChanged object:nil];
    }
    return self;
}


-(void)handleData:(MonomorphicArray *)data {
    //DLog("PositionModule handling data. Sample Count: %lu", (unsigned long)[data count]);
    
    if(strategy != nil) {
        BOOL isDebugPosition = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingsIsDebugPosition];
        
        /* this is only for debuging of BFH - remove later and use serverside debug mode */
        Location *pos = nil;
        if(isDebugPosition) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            int x = (int)[defaults integerForKey:kSettingsDebugXCoord];
            int y = (int)[defaults integerForKey:kSettingsDebugYCoord];
            pos = [[Location alloc] initWithXCoordinate:x YCoordinate:y];
        } else {
            DLog("Using strategy: %@", [strategy name]);
            pos = [strategy calculateWithSensorData:data];
        }
        
        if(pos) {
            NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
            [userInfo setObject:pos forKey:@"lastPosition"];
    
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPositionUpdate object:self userInfo:userInfo];
        }
    } else {
        DLog("No strategy set");
    }
    
    if(nextHandler != nil) {
        [nextHandler handleData:data];
    }
}

-(void)setStrategy:(id)newStrategy {
    strategy = newStrategy;
}

-(void)positionStrategyChanged:(NSNotification *) notification {
    if ([[notification name] isEqualToString:kNotificationPositioningStrategyChanged]) {
        NSDictionary* userInfo = notification.userInfo;
        strategy = [userInfo objectForKey:@"strategy"];
    }
}
@end
