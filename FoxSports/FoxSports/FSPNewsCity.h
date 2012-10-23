//
//  FSPNewsCity.h
//  FoxSports
//
//  Created by Stephen Spring on 7/19/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FSPNewsCity : NSManagedObject

@property (nonatomic, retain) NSString * cityId;
@property (nonatomic, retain) NSString * cityName;

@property (nonatomic, retain) NSString * affiliateId;

@end
