//
//  FSPLiveEngineClient.h
//  FoxSports
//
//  Created by Jason Whitford on 4/10/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "AFHTTPClient.h"
#import "FSPDataCoordinatorDataRetrieving.h"
#import "FSPBaseNetworkClient.h"

@interface FSPLiveEngineClient : FSPBaseNetworkClient <FSPLiveEngineDataRetrieving>

@end
