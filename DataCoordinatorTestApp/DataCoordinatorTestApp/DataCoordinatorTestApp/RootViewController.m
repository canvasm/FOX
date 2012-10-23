//
//  RootViewController.m
//  DataCoordinatorTestApp
//
//  Created by Chase Latta on 2/19/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "RootViewController.h"
#import "FSPCoreDataManager.h"
#import "ShowOrganizationsViewController.h"

@implementation RootViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;
{
    if ([segue.identifier isEqualToString:@"ShowOrgsIdentifier"]) {
        // Fetch all the organizations;
        NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"FSPOrganization"];
        fetch.predicate = [NSPredicate predicateWithFormat:@"parent == nil"];
        
        NSArray *orgs = [[[FSPCoreDataManager sharedManager] GUIObjectContext] executeFetchRequest:fetch error:nil];
        ShowOrganizationsViewController *toVC = segue.destinationViewController;
        toVC.organizations = orgs;
    }
}
@end
