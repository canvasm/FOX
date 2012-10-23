//
//  FSPChannel.h
//  FoxSports
//
//  Created by USS11SSpringMBP on 9/4/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FSPChannel : NSObject

@property (nonatomic, retain) NSString * callSign;
@property (nonatomic, retain) NSString * broadcastDate;
@property (nonatomic, retain) NSNumber * isDelayed;


/*!
 @abstract Populates the FSPChannel instance with data from dictionary.
 @param channelData A dictionary containing the data to populate the object with.
*/
- (void)populateWithDictionary:(NSDictionary *)channelData;

/*!
 @abstract Returns the broadcastDate formatted for display;
 @return A string representation of the broadcastDate.
 */
- (NSString *)formattedBroadcastDate;

@end
