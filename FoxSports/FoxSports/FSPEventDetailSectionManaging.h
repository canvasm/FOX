//
//  FSPEventDetailSectionManaging.h
//  FoxSports
//
//  Created by Laura Savino on 5/9/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSPGame;

@protocol FSPEventDetailSectionManaging

/**
 * Whether the view has enough information to be ready to display
 */
@property (nonatomic, getter = isInformationComplete) BOOL informationComplete;



@end
