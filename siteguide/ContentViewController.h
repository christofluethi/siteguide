//
//  ContentViewController.h
//  SiteGuide
//
//  Created by Christof Luethi on 04.03.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Site.h"
#import "PointOfInterest.h"

@interface ContentViewController : UIViewController<UIWebViewDelegate>
@property (nonatomic, strong) NSString *contentLink;
@property (strong, nonatomic) IBOutlet UIWebView *webView;

/*- (IBAction)dismissModalView:(id)sender;
- (IBAction)stopSpinning:(id)sender;*/
@end
