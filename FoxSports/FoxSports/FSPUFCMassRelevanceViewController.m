//
//  FSPUFCMassRelevanceViewController.m
//  FoxSports
//
//  Created by Pat Sluth on 2012-10-18.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPUFCMassRelevanceViewController.h"

@interface FSPUFCMassRelevanceViewController ()

@end

@implementation FSPUFCMassRelevanceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"FSPMassRelevanceViewController" bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.topBarButtons insertSegmentWithTitle:@"Fight Card" atIndex:0 animated:NO];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *selectedTitle = [self.topBarButtons titleForSegmentAtIndex:self.topBarButtons.selectedSegmentIndex];
    
    if ([selectedTitle isEqualToString:@"Fight Card"])
        return 10; //TODO show 10 for now. Once fight card data is avalible will show correct ammount
    
    return [super tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    NSString *clickedButtonTitle = [self.topBarButtons titleForSegmentAtIndex:self.topBarButtons.selectedSegmentIndex];
    
    if ([clickedButtonTitle isEqualToString:@"Fight Card"])
    {
        CellIdentifier = @"FightCardCell";
        
        FSPUFCFightCardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
        {
            cell = [[FSPUFCFightCardTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            
            cell.backgroundView.contentMode = UIViewContentModeScaleToFill;
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"twitter_cell_unselected_background"]];
        }
        
        return cell;
    }
    
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setTopBarButtons:nil];
    [super viewDidUnload];
}
@end
