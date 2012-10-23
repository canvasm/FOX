//
//  NSURL+CommonDirectories.h
//  FoxSports
//
//  Created by Chase Latta on 12/22/11.
//  Copyright (c) 2011 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (FSPCommonDirectories)

/**
 Returns the URL to the application's Documents directory.
 */
+ (NSURL *)fsp_applicationDocumentsDirectory;

+ (NSURL *)fsp_cacheDirectory;
@end
