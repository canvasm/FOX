//
//  FSPBaseNetworkClient.h
//  FoxSports
//
//  Created by Ed McKenzie on 8/27/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "AFHTTPClient.h"

@interface FSPBaseNetworkClient : AFHTTPClient

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;

@end
