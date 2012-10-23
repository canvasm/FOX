//
//  FSPEventAffiliateIdentificationProcessingOperation.h
//  FoxSports
//
//  Created by Jason Whitford on 3/1/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSPProcessingOperation.h"

@interface FSPEventAffiliateIdentificationProcessingOperation : FSPProcessingOperation
- (id)initWithAffiliateInfo:(NSDictionary *)affiliateInfo organizationIds:(NSArray *)organizationIds
                    context:(NSManagedObjectContext *)context;
@end
