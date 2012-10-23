//
//  NSUserDefaults+FSPExtensions.h
//  FoxSports
//
//  Created by greay on 6/20/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (FSPExtensions)

- (NSIndexPath *)fsp_indexPathForKey:(NSString *)key;
- (void)fsp_setIndexPath:(NSIndexPath *)indexPath forKey:(NSString *)key;

@end
