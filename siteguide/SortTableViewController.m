//
//  SortTableViewController.m
//  siteguide
//
//  Created by Christof Luethi on 11.03.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import "SortTableViewController.h"

@implementation SortTableViewController {
    NSArray* _sortModes;
    NSArray* _sortIcons;
    NSUInteger _selectedIndex;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /* must be the same ordering as the values in constants.h */
    _sortModes = @[@"Name [A-Z]", @"Name [Z-A]", @"Distanz"];
    _sortIcons = @[@"barIconDown_cell_25x25.png", @"barIconUp_cell_25x25.png", @"barIconDistance_cell_25x25.png"];
    _selectedIndex = [[NSUserDefaults standardUserDefaults] integerForKey:kSettingsSortMode];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_sortModes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SortMode"];
    cell.textLabel.text = _sortModes[indexPath.row];
    
    UIImage *image = [UIImage imageNamed:_sortIcons[indexPath.row]];
    cell.imageView.image = image;
    
    if (indexPath.row == _selectedIndex) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_selectedIndex != NSNotFound) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0]];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    _selectedIndex = indexPath.row;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLong:_selectedIndex] forKey:kSettingsSortMode];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.delegate sortTableViewController:self didSelectSort:(int)_selectedIndex];
}

- (void)viewDidUnload
{
    [super viewDidLoad];
}

- (IBAction)cancelAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
