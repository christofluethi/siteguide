//
//  Site.h
//  siteguide
//
//  Created by Christof Luethi on 20.02.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Model Class holding values for a site.
 Site-Informations are fetched as JSON from Server in the SiteNameTableViewController
 */
@interface Site : NSObject
@property (nonatomic, assign, readonly) int siteId;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *beaconUUID;

/**
 initialize a new site
 */
-(id)initWithName:(NSString*)name siteId:(int)siteId beaconUUID:(NSString*)beaconUUID;
@end
