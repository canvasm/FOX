//
//  FSPConfigurationProcessingOperation.m
//  FoxSports
//
//  Created by Joshua Dubey on 7/16/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPConfigurationProcessingOperation.h"
#import "FSPConfigurationPrivate.h"

@interface FSPConfigurationProcessingOperation ()
@property (nonatomic, strong) NSDictionary *configuration;
@end

@implementation FSPConfigurationProcessingOperation

@synthesize configuration = _configuration;
@synthesize lastOrgChangeDate = _lastOrgChangeDate;
@synthesize lastLogoChangeDate = _lastLogoChangeDate;

- (id)initWithConfiguration:(NSDictionary *)configuration
{   
    self = [super initWithContext:nil];
    if (self) {
        self.configuration = configuration;
    }
    return self;
}

- (void)main
{
    if (self.isCancelled) 
        return;
    
    [[FSPConfiguration sharedConfiguration] setConfigurationDictionary:self.configuration];
}


@end
