//
//  PositionCalculationModule.h
//  siteguide
//
//  Created by Christof Luethi on 24.02.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SiteGuideDataHandler.h"
#import "Location.h"
#import "BeaconManager.h"
#import "SiteGuidePositioningStrategy.h"

@interface PositionCalculationModule : SiteGuideDataHandler {
    id<SiteGuidePositioningStrategy> strategy;
}

/**
 init PositionCalculationModule with a given positioning strategy
 */
-(id)initWithStrategy:(id)s;
@end
