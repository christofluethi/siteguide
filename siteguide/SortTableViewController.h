//
//  SortTableViewController.h
//  siteguide
//
//  Created by Christof Luethi on 11.03.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SortTableViewController;

@protocol SortTableViewControllerDelegate <NSObject>
- (void)sortTableViewController:(SortTableViewController *)controller didSelectSort:(int)sort;
@end

@interface SortTableViewController : UITableViewController
@property (nonatomic, weak) id <SortTableViewControllerDelegate> delegate;
@property (nonatomic, assign) int sortMode;
- (IBAction)cancelAction:(id)sender;

@end