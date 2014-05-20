//
//  ContentViewController.m
//  SiteGuide
//
//  Created by Christof Luethi on 04.03.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import "ContentViewController.h"

@implementation ContentViewController {
    Site *site;
    NSString *link;
    UIActivityIndicatorView *activity;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSData *encodedObject = [[NSUserDefaults standardUserDefaults] objectForKey:kSettingsSite];
    if(encodedObject) {
        site = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    }
    
    CGRect frame = CGRectMake (120.0, 185.0, 80, 80);
    activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activity setFrame:frame];
    
    activity.hidesWhenStopped = YES;
    
    activity.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin |
    UIViewAutoresizingFlexibleHeight |
    UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:activity];
    
    [activity startAnimating];
    _webView.delegate = self;
    DLog("Content URL: %@", _contentLink);
    NSURL *url = [NSURL URLWithString:_contentLink];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:requestObj];
    
}

- (void)webViewDidFinishLoad:webView {
        [activity stopAnimating];
}
@end
