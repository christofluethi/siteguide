//
//  CalibrationModule.h
//  siteguide
//
//  Created by Christof Luethi on 24.02.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SiteGuideDataHandler.h"

@interface CalibrationModule : SiteGuideDataHandler
@property (nonatomic, assign) int factor;
@end
