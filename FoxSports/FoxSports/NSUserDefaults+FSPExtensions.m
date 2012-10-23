//
//  NSUserDefaults+FSPExtensions.m
//  FoxSports
//
//  Created by greay on 6/20/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "NSUserDefaults+FSPExtensions.h"

@implementation NSUserDefaults (FSPExtensions)

- (NSIndexPath *)fsp_indexPathForKey:(NSString *)key
{
	NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:key];
	if (!data) return nil;
	
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
	NSIndexPath *indexPath = [unarchiver decodeObjectForKey:key];
	[unarchiver finishDecoding];

	return indexPath;
}

- (void)fsp_setIndexPath:(NSIndexPath *)indexPath forKey:(NSString *)key
{
	NSMutableData *data = [NSMutableData data];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];

	[archiver encodeObject:indexPath forKey:key];
	[archiver finishEncoding];

	[[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
}


@end
