//
//  SiteNameTableViewController.h
//  siteguide
//
//  Created by Christof Luethi on 17.02.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Site.h"

@class SiteNameTableViewController;

@protocol SiteNameTableViewControllerDelegate <NSObject>
- (void)siteNameTableViewController:(SiteNameTableViewController *)controller didSelectSite:(Site *)site;
@end

@interface SiteNameTableViewController : UITableViewController
@property (nonatomic, weak) id <SiteNameTableViewControllerDelegate> delegate;
@property (nonatomic, strong) Site *selectedSite;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@end
