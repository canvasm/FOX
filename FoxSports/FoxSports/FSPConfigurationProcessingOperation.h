//
//  FSPConfigurationProcessingOperation.h
//  FoxSports
//
//  Created by Joshua Dubey on 7/16/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSPProcessingOperation.h"

@interface FSPConfigurationProcessingOperation : FSPProcessingOperation
@property (nonatomic, strong) NSDate *lastOrgChangeDate;
@property (nonatomic, strong) NSDate *lastLogoChangeDate;
- (id)initWithConfiguration:(NSDictionary *)configuration;
@end
