//
//  FSPPitchEvent.h
//  FoxSports
//
//  Created by Matthew Fay on 6/26/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FSPGamePlayByPlayItem;

@interface FSPPitchEvent : NSManagedObject

@property (nonatomic, retain) NSString * result;
@property (nonatomic, retain) NSNumber * sequence;
@property (nonatomic, retain) NSNumber * pitchType;
@property (nonatomic, retain) NSNumber * pitchVelocity;
@property (nonatomic, retain) NSNumber * verticalAxis;
@property (nonatomic, retain) NSString * horizontalAxis;

@property (nonatomic, retain) FSPGamePlayByPlayItem *playByPlay;

- (void)populateWithDictionary:(NSDictionary *)dictionary;

@end
