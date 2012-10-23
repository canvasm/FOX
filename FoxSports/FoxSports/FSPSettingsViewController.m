//
//  FSPSettingsViewController.m
//  FoxSports
//
//  Created by greay on 5/31/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPSettingsViewController.h"
#import "FSPTveLoginViewcontroller.h"
#import "FSPRootViewController.h"
#import "FSPAppDelegate.h"

enum {
    FSPSettingsAccountSection = 0,
    FSPSettingsGeneralSection,
    FSPSettingsLegalSection,
	FSPSettingsSectionCount
};


@interface FSPSettingsViewController ()

@end

@implementation FSPSettingsViewController
@synthesize owner;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
		self.title = @"Settings";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return FSPSettingsSectionCount;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section) {
		case FSPSettingsAccountSection: {
			return 4;
		}
		case FSPSettingsGeneralSection: {
			return 3;
		}
		case FSPSettingsLegalSection: {
			return 4;
		}
		default: {
			return 0;
		}
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
	}
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.accessoryView = nil;
	cell.detailTextLabel.text = nil;
    cell.textLabel.shadowColor = [UIColor clearColor];
	
	switch (indexPath.section) {
		case FSPSettingsAccountSection: {
			switch (indexPath.row) {
				case 0: {
					cell.textLabel.text = @"Sign In";
					break;
				}
				case 1: {
					cell.textLabel.text = @"Choose Provider";
					break;
				}
				case 2: {
					cell.textLabel.text = @"My Account";
					break;
				}
				case 3: {
					cell.textLabel.text = @"Alerts";
					break;
				}
			}
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
		}
		case FSPSettingsGeneralSection: {
			switch (indexPath.row) {
				case 0: {
					cell.textLabel.text = @"View Scores";
					cell.accessoryView = [[UISwitch alloc] initWithFrame:CGRectZero];
					break;
				}
				case 1: {
					cell.textLabel.text = @"Screen Auto-Lock";
					cell.accessoryView = [[UISwitch alloc] initWithFrame:CGRectZero];
					break;
				}
				case 2: {
					cell.textLabel.text = @"Refresh Rate";
					cell.detailTextLabel.text = @"n Seconds";
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					break;
				}
			}
			break;
		}
		case FSPSettingsLegalSection: {
			switch (indexPath.row) {
				case 0: {
					cell.textLabel.text = @"FAQ";
					break;
				}
				case 1: {
					cell.textLabel.text = @"Feedback";
					break;
				}
				case 2: {
					cell.textLabel.text = @"Privacy Policy";
					break;
				}
				case 3: {
					cell.textLabel.text = @"Terms of Service";
					break;
				}
			}
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
		}
		default: {

		}
	}
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	switch (indexPath.section) {
		case FSPSettingsAccountSection: {
			switch (indexPath.row) {
				case 0: {
					break;
				}
				case 1: {
					[FSPTveAuthManager sharedManager].delegate = self.owner;
					[[FSPTveAuthManager sharedManager] getAuthentication];
					
					[self.owner settingsDoneButtonWasTapped:nil];
					break;
				}
				case 2: {
					break;
				}
				case 3: {
					break;
				}
			}
			break;
		}
		case FSPSettingsGeneralSection: {
			switch (indexPath.row) {
				case 0: {
					break;
				}
				case 1: {
					break;
				}
				case 2: {
					break;
				}
			}
			break;
		}
		case FSPSettingsLegalSection: {
			switch (indexPath.row) {
				case 0: {
                    FSPRootViewController *rootViewController = [((FSPAppDelegate *)[UIApplication sharedApplication].delegate) rootViewController];
                    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://msn.foxsports.com/"]];
                    [rootViewController presentModalWebViewControllerWithRequest:request title:@"FAQ"];
					break;
				}
				case 1: {
                    FSPRootViewController *rootViewController = [((FSPAppDelegate *)[UIApplication sharedApplication].delegate) rootViewController];
                    [rootViewController composeMailMessage];
					break;
				}
				case 2: {
                    FSPRootViewController *rootViewController = [((FSPAppDelegate *)[UIApplication sharedApplication].delegate) rootViewController];
                    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://msn.foxsports.com/"]];
                    [rootViewController presentModalWebViewControllerWithRequest:request title:@"Privacy Policy"];
					break;
				}
				case 3: {
                    FSPRootViewController *rootViewController = [((FSPAppDelegate *)[UIApplication sharedApplication].delegate) rootViewController];
                    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://msn.foxsports.com/"]];
                    [rootViewController presentModalWebViewControllerWithRequest:request title:@"Terms of Service"];
					break;
				}
			}
			break;
		}
		default: {
			
		}
	}
}


@end
