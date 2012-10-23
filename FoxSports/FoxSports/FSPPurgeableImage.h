//
//  FSPPurgeableImage.h
//  FoxSports
//
//  Created by Chase Latta on 4/11/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FSPPlayer;

@interface FSPPurgeableImage : NSManagedObject

@property (nonatomic, retain) NSData * backingData;
@property (nonatomic, retain) NSDate * expirationDate;
@property (nonatomic, retain) NSString * url;

/**
 TRUE if this image is expired.
 */
@property (nonatomic, assign, readonly) BOOL isExpired;

@end
