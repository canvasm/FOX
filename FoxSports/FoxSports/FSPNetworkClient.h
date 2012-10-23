//
//  FSPNetworkClient.h
//  FoxSports
//
//  Created by Chase Latta on 1/13/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "FSPDataCoordinatorDataRetrieving.h"
#import "FSPBaseNetworkClient.h"

extern NSString * const FSPNetworkClientErrorDomain;

enum FSPNetworkClientErrors {
    FSPErrorInvalidReturnedData = 1001,
};


@class FSPTeam;

@interface FSPNetworkClient : FSPBaseNetworkClient <FSPDataCoordinatorDataRetrieving>

@end
