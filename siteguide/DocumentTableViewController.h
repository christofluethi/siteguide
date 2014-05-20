//
//  DocumentTableViewController.h
//  SiteGuide
//
//  Created by Christof Luethi on 06.03.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PointOfInterest.h"
#import "Site.h"
#import "Document.h"
#import "ContentViewController.h"
#import "SortTableViewController.h"

@interface DocumentTableViewController : UITableViewController<SortTableViewControllerDelegate>
@property (nonatomic, strong) PointOfInterest *poi;
@end
