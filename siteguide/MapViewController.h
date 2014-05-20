//
//  MapViewController.h
//  siteguide
//
//  Created by Stefan Wagner on 04.03.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RegionManager.h"
#import "Region.h"
#import "DocumentTableViewController.h"
#import "POIListTableViewController.h"
#import "BeaconManager.h"
#import "ToastView.h"


@interface MapViewController : UIViewController<UIScrollViewDelegate>
@property(nonatomic, strong) UIScrollView* scrollMapView;
@property(nonatomic, strong) UIView* contentView;

- (void) drawRegions;
- (void) drawPois;
- (void) drawPosition;
- (void) drawBeacons;

/* Constants */
#define ScaleMap_X 20
#define ScaleMap_Y 20
#define BorderX 5
#define BorderY 5
#define poiSizeX 60
#define poiSizeY 60
#define beaconSizeX 30
#define beaconSizeY 30
#define roomBorderWidth 6.0f

#define colorRegionArea [UIColor colorWithRed:0.0/255.0 green:216.0/255.0 blue:113.0/255.0 alpha:0.5]
#define colorRegionOther [UIColor colorWithRed:123.0/255.0 green:10.0/255.0 blue:141.0/255.0 alpha:1.0]
#define colorRoomWithDocument [UIColor colorWithRed:123.0/255.0 green:140.0/255.0 blue:141.0/255.0 alpha:1.0]
#define colorRoomNoDocument [UIColor colorWithRed:161.0/255.0 green:173.0/255.0 blue:175.0/255.0 alpha:1.0]
#define colorRoomBorder [UIColor colorWithRed:/10.0 green:225.0/255.0 blue:228.0/255.0 alpha:1.0]
#define colorMapBackground [UIColor colorWithRed:219.0/255.0 green:225.0/255.0 blue:228.0/255.0 alpha:1.0]
#define colorButtomBar [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]
#define colorHeaderBar [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]
#define colorPosition [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]
#define colorFontRoom [UIColor colorWithRed:/123.0 green:140.0/255.0 blue:255.0/255.0 alpha:1.0]
#define colorFontavigatorBar [UIColor colorWithRed:0/255.0 green:216/255.0 blue:113/255.0 alpha:1.0]
#define colorBeaconBackground [UIColor colorWithRed:110.8 green:0.2 blue:0.2 alpha:0.8]
#define colorButtonBackground [UIColor colorWithRed:0.2 green:0.2 blue:0.5 alpha:0.0]
#define colorButtonBorder [UIColor blackColor].CGColor
#define colorTitle [UIColor whiteColor]
#define fontOpenSansRegular [UIFont fontWithName:@"OpenSans" size:20];


@end


