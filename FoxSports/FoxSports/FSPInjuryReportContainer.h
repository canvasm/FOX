//
//  FSPInjuryReportContainer.h
//  FoxSports
//
//  Created by Laura Savino on 5/9/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPEventDetailSectionManaging.h"

@interface FSPInjuryReportContainer : UIView <FSPEventDetailSectionManaging, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)injuryReportDidChangeContent;

/**
 * Sets properties on subviews from a given game.
 */
- (void)updateInterfaceWithGame:(FSPGame *)game;

@end
