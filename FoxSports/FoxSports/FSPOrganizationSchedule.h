//
//  FSPOrganizationSchedule.h
//  DataCoordinatorTestApp
//
//  Created by Chase Latta on 2/20/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FSPEvent, FSPOrganization;

@interface FSPOrganizationSchedule : NSManagedObject

@property (nonatomic, retain) NSDate * updatedDate;
@property (nonatomic, retain) NSString * seasonName;
@property (nonatomic, retain) FSPOrganization *organization;
@property (nonatomic, retain) NSSet *events;
@end

@interface FSPOrganizationSchedule (CoreDataGeneratedAccessors)

- (void)addEventsObject:(FSPEvent *)value;
- (void)removeEventsObject:(FSPEvent *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;

@end
