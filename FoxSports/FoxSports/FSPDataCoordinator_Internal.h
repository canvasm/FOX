//
//  FSPDataCoordinator_Internal.h
//  FoxSports
//
//  Created by Chase Latta on 3/20/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPDataCoordinator.h"


@class FSPMockDataFetcher, FSPProcessingOperationQueue;

extern NSTimeInterval FSPDataCoordinatorRetryInterval;
extern NSInteger FSPDataCoordinatorMaxRetryCount;

@interface FSPDataCoordinator () {
@package
    
}
@property (nonatomic, strong) id <FSPDataCoordinatorDataRetrieving> fetcher;
@property (nonatomic, strong) id <FSPLiveEngineDataRetrieving> liveEngineFetcher;
@property (nonatomic, strong) id <FSPPreferencesProtocol> profileClient;

@property (nonatomic, strong) FSPProcessingOperationQueue *eventProcessingQueue;;

@end
