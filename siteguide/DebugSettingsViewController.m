//
//  DebugSettingsViewController.m
//  siteguide
//
//  Created by Christof Luethi on 13.03.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import "DebugSettingsViewController.h"

@interface DebugSettingsViewController ()
@property (nonatomic, assign) id currentResponder;
@end

@implementation DebugSettingsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    _xCoordTextfield.delegate = self;
    _yCoordTextfield.delegate = self;

	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignOnTap:)];
    [singleTap setNumberOfTapsRequired:1];
    [singleTap setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:singleTap];
}

- (void)resignOnTap:(id)iSender {
    [self.currentResponder resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.currentResponder = textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [_xCoordTextfield resignFirstResponder];
    [_yCoordTextfield resignFirstResponder];
    return NO;
}

-(void)viewWillAppear:(BOOL)animated {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int x = (int)[defaults integerForKey:kSettingsDebugXCoord];
    int y = (int)[defaults integerForKey:kSettingsDebugYCoord];

    _xCoordTextfield.text = [NSString stringWithFormat:@"%i", x];
    _yCoordTextfield.text = [NSString stringWithFormat:@"%i", y];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)save:(id)sender {
    int x = [_xCoordTextfield.text intValue];
    int y = [_yCoordTextfield.text intValue];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:x forKey:kSettingsDebugXCoord];
    [defaults setInteger:y forKey:kSettingsDebugYCoord];
    
    [defaults synchronize];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
