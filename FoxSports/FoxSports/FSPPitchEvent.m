//
//  FSPPitchEvent.m
//  FoxSports
//
//  Created by Matthew Fay on 6/26/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPPitchEvent.h"
#import "FSPGamePlayByPlayItem.h"
#import "NSDictionary+FSPExtensions.h"


@implementation FSPPitchEvent

@dynamic result;
@dynamic sequence;
@dynamic pitchType;
@dynamic pitchVelocity;
@dynamic verticalAxis;
@dynamic horizontalAxis;
@dynamic playByPlay;

- (void)populateWithDictionary:(NSDictionary *)dictionary
{
    self.result = [dictionary fsp_objectForKey:@"RES" defaultValue:@""];
    self.sequence = [dictionary fsp_objectForKey:@"SEQ" defaultValue:@-1];
    self.pitchType = [dictionary fsp_objectForKey:@"T" defaultValue:@0];
    self.pitchVelocity = [dictionary fsp_objectForKey:@"VEL" defaultValue:@-1];
    //TODO: this are coming in backwards in the feed
//    self.verticalAxis = [dictionary fsp_objectForKey:@"V" defaultValue:[NSNumber numberWithInt:-1]];
//    self.horizontalAxis = [dictionary fsp_objectForKey:@"H" defaultValue:@""];
    self.verticalAxis = @-1;
    self.horizontalAxis = @"";
    
}

@end
