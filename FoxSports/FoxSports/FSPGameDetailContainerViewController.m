//
//  FSPGameDetailContainerViewController.m
//  FoxSports
//
//  Created by Joshua Dubey on 7/5/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPGameDetailContainerViewController.h"
#import "FSPEvent.h"
#import "FSPDataCoordinator+EventUpdating.h"

@interface FSPGameDetailContainerViewController ()
+ (NSMutableDictionary *)savedTabs;
@end

@implementation FSPGameDetailContainerViewController

@synthesize segmentedControl = _segmentedControl;
@synthesize currentEvent = _currentEvent;
@synthesize managedObjectContext = _managedObjectContext;

+ (NSMutableDictionary *)savedTabs
{
	static NSMutableDictionary *savedTabs = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        savedTabs = [NSMutableDictionary dictionary];
		NSString *savedTab = [[NSUserDefaults standardUserDefaults] valueForKey:@"selectedGameDetailContainerView"];
		NSArray *components = [savedTab componentsSeparatedByString:@"::"];
		if (components.count == 2) {
			NSNumber *index = @([[components objectAtIndex:0] intValue]);
			NSString *eventIdentifier = [components objectAtIndex:1];
			[savedTabs setValue:index forKey:eventIdentifier];
		}
        
    });
	return savedTabs;
}

//------------------------------------------------------------------------------
// MARK: - Segmented Control / Navigation
//------------------------------------------------------------------------------

- (IBAction)segmentedControlUpdate:(id)sender;
{
    NSInteger newIndex = [(UISegmentedControl *)sender selectedSegmentIndex];
    self.segmentedControl.selectedSegmentIndex = newIndex;
    [self selectGameDetailViewAtIndex:newIndex];
}

- (void)selectGameDetailViewAtIndex:(NSUInteger)index
{
    	[[FSPGameDetailContainerViewController savedTabs] setValue:@(index) forKey:self.currentEvent.uniqueIdentifier];
    	[[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d::%@", index, self.currentEvent.uniqueIdentifier] forKey:@"selectedGameDetailContainerView"];
}

//------------------------------------------------------------------------------
// MARK: - Custom getters and setters
//------------------------------------------------------------------------------
- (void)setCurrentEvent:(FSPEvent *)event;
{
    if (_currentEvent != event) {
        _currentEvent = event;
        [self eventDidChange];
    }
}

- (void)eventDidChange;
{
	NSUInteger index = [[[FSPGameDetailContainerViewController savedTabs] valueForKey:self.currentEvent.uniqueIdentifier] unsignedIntValue];
    self.segmentedControl.selectedSegmentIndex = index;
    [self selectGameDetailViewAtIndex:index];
}

@end
