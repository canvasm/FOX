//
//  FSPSoccerPlayByPlayViewController.m
//  FoxSports
//
//  Created by Ryan McPherson on 7/26/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPSoccerPlayByPlayViewController.h"

@interface FSPSoccerPlayByPlayViewController ()
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@end

@implementation FSPSoccerPlayByPlayViewController
@synthesize tableView;

- (NSArray *)segmentTitlesForEvent:(FSPEvent *)event
{
    return @[@"Play By Play"];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    tableView.delegate = self;
    tableView.dataSource = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

@end
