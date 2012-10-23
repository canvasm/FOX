//
//  FSPTournamentEvent.h
//  FoxSports
//
//  Created by Laura Savino on 1/19/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSPEvent.h"

/**
 * A protocol for for events with more than two competitors (e.g., not Team A vs Team B).
 * Examples of sports using this type of chip: PGA, UFC, NASCAR.
 */
@protocol FSPTournamentEvent

/**
 * The displayed heading for the event.
 */
@property (nonatomic, strong, readonly) NSString * tournamentTitle;

/**
 * Additional details about the event (e.g., main fighters' names in UFC, 
 * golf course name in PGA); any information that could serve as a subtitle.
 */
@property (nonatomic, strong, readonly) NSString * tournamentSubtitle;

@optional
/**
 * The geographical location of the event (e.g., "Augusta, Georgia" or "London, England")
 */
@property (nonatomic, strong, readonly) NSString * location;

@end
