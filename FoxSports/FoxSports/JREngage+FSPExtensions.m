//
//  JREngage+FSPExtensions.m
//  FoxSports
//
//  Created by Laura Savino on 4/15/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "JREngage+FSPExtensions.h"

static NSString *const FSPJanrainAppID = @"emgkdelpeacoebnmcjoi";

@implementation JREngage(FSPExtensions)

+ (JREngage *)jrEngageClientWithDelegate:(id<JREngageDelegate>) delegate;
{
    return [JREngage jrEngageWithAppId:FSPJanrainAppID andTokenUrl:nil delegate:delegate];
}

@end
