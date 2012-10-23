//
//  JREngage+FSPExtensions.h
//  FoxSports
//
//  Created by Laura Savino on 4/15/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JREngage.h"

@interface JREngage(FSPExtensions)

/**
 * Returns a JREngage instance with the needed app ID and a nil token.
 */
+ (JREngage *)jrEngageClientWithDelegate:(id<JREngageDelegate>) delegate;

@end
