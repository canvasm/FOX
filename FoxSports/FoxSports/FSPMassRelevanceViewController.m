//
//  FSPMassRelevanceViewController.m
//  FoxSports
//
//  Created by Rowan Christmas on 7/22/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPMassRelevanceViewController.h"
#import "FSPEvent.h"
#import "FSPDataCoordinator.h"
#import "UIImageView+AFNetworking.h"
#import "FSPRootViewController.h"
#import <Twitter/TWTweetComposeViewController.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface FSPMassRelevanceViewController ()

@property NSArray *tweetArray;
@property (weak, nonatomic) IBOutlet UIButton *streamButton;
@property (nonatomic, weak) FSPDataCoordinator *dataCoordinator;

- (IBAction)selectStream:(id)sender;
- (void)refreshMassRelevance;
- (IBAction)tweet:(id)sender;

@end

@implementation FSPMassRelevanceViewController

@synthesize currentEvent = _currentEvent;
@synthesize tableView = _tableView;
@synthesize streamButton = _streamButton;
@synthesize tweetArray = _tweetArray;

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    self.dataCoordinator = [FSPDataCoordinator defaultCoordinator];
    self.tableView.rowHeight = 120;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.topBarButtons.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 50);
    [self.topBarButtons addTarget:self action:@selector(topBarButtonClicked:) forControlEvents:UIControlEventValueChanged];

    [self refreshMassRelevance];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setStreamButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Data Fetching

- (void)refreshMassRelevance;
{
    [self.dataCoordinator updateMassRelevanceForOrganizationId:nil success:^(NSArray *tweets){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (tweets) {
                _tweetArray = nil;
                _tweetArray = tweets;
                [self.tableView reloadData];
            }
        });
    } failure:^(NSError *error) {
        //TODO: Notify about error.
    }];
}

- (void)setCurrentEvent:(FSPEvent *)currentEvent;
{
    if (_currentEvent != currentEvent)
    {
        _currentEvent = currentEvent;
    }
}

- (void)topBarButtonClicked:(UISegmentedControl *)sender
{
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *selectedTitle = [self.topBarButtons titleForSegmentAtIndex:self.topBarButtons.selectedSegmentIndex];
    
    if ([selectedTitle isEqualToString:@"Social"])
        return 5; //return self.tweetArray.count; //TODO OVERRIDING TO SHOW CELLS NOW
    else if ([selectedTitle isEqualToString:@"Stats"])
        return 20;
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    NSString *selectedTitle = [self.topBarButtons titleForSegmentAtIndex:self.topBarButtons.selectedSegmentIndex];

    if ([selectedTitle isEqualToString:@"Social"])
    {
        CellIdentifier = @"SocialCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.detailTextLabel.numberOfLines = 4;
            
            cell.textLabel.textColor = [UIColor colorWithRed:0.180 green:0.325 blue:0.478 alpha:1.000];
            cell.textLabel.shadowColor = [UIColor whiteColor];
            cell.textLabel.backgroundColor = [UIColor clearColor];
            
            cell.detailTextLabel.textColor = [UIColor colorWithRed:0.180 green:0.325 blue:0.478 alpha:1.000];
            cell.detailTextLabel.shadowColor = [UIColor whiteColor];
            cell.detailTextLabel.backgroundColor = [UIColor clearColor];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.backgroundView.contentMode = UIViewContentModeScaleToFill;
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"twitter_cell_unselected_background"]];
        }
        
        cell.textLabel.text = [[[self.tweetArray objectAtIndex:indexPath.row] valueForKey:@"user"] valueForKey:@"name"];
        cell.detailTextLabel.text = [[self.tweetArray objectAtIndex:indexPath.row] valueForKey:@"text"];
        
        //TODO this override current twitter stuff because its not loading right now
        cell.detailTextLabel.text = @"TODO load twitter cells";
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[[[self.tweetArray objectAtIndex:indexPath.row] valueForKey:@"user"] valueForKey:@"profile_image_url"]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
        
        [cell.imageView af_setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
         {
             [cell setNeedsLayout];
             
         } failure:nil];
        
        
        return cell;
    }
    else if ([selectedTitle isEqualToString:@"Stats"])
    {
        CellIdentifier = @"StatsCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            
            cell.backgroundView.contentMode = UIViewContentModeScaleToFill;
            cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"twitter_cell_unselected_background"]];
            cell.detailTextLabel.text = @"TODO load stats cells";
        }
        
        return cell;
    }
    
    //should never get down here. but just in case use a default cell
    CellIdentifier = @"ErrorCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"twitter_cell_unselected_background"]];
        cell.detailTextLabel.text = @"Error";
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *urls = [[[self.tweetArray objectAtIndex:indexPath.row] valueForKey:@"entities"] valueForKey:@"urls"];
    if (urls.count) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[[urls lastObject] valueForKey:@"expanded_url"]]];
        [[FSPRootViewController rootViewController] presentModalWebViewControllerWithRequest:request title:@"Twitter" modalStyle:UIModalPresentationFullScreen];
    }
}

#pragma mark -

- (IBAction)tweet:(id)sender;
{
    TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];
    
    tweetSheet.completionHandler = ^(TWTweetComposeViewControllerResult result) {
        switch(result) {
            case TWTweetComposeViewControllerResultCancelled:
                //  This means the user cancelled without sending the Tweet
                break;
            case TWTweetComposeViewControllerResultDone:
                //  This means the user hit 'Send'
                break;
        }
        
        //  dismiss the Tweet Sheet 
        dispatch_async(dispatch_get_main_queue(), ^{            
            [self dismissViewControllerAnimated:NO completion:^{
                //NSLog(@"Tweet Sheet has been dismissed."); 
            }];
        });
    };
    
    //  Set the initial body of the Tweet
    [tweetSheet setInitialText:@"OMG #NEEDHASHTAG"]; 
            
    //  Presents the Tweet Sheet to the user
    [self presentViewController:tweetSheet animated:NO completion:^{
        //NSLog(@"Tweet sheet has been presented.");
    }];
    
}
- (IBAction)selectStream:(id)sender;
{
    // TODO: present some sort of popover
}
@end
