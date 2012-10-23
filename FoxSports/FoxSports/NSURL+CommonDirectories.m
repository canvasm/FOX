//
//  NSURL+CommonDirectories.m
//  FoxSports
//
//  Created by Chase Latta on 12/22/11.
//  Copyright (c) 2011 Übermind. All rights reserved.
//

#import "NSURL+CommonDirectories.h"

@implementation NSURL (FSPCommonDirectories)

+ (NSURL *)fsp_applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

+ (NSURL *)fsp_cacheDirectory;
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
