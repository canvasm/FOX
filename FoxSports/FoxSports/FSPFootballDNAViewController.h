//
//  FSPFootballDNAViewController.h
//  FoxSports
//
//  Created by Rowan Christmas on 7/21/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPEvent.h"

@interface FSPFootballDNAViewController : UIViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) FSPEvent *currentEvent;

@end
