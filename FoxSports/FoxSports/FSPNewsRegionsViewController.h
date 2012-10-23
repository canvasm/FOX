//
//  FSPNewsRegionsViewController.h
//  FoxSports
//
//  Created by Stephen Spring on 7/19/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSPNewsCity;

@interface FSPNewsRegionsViewController : UIViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) FSPNewsCity *selectedCity;

/*!
 @abstract Initializes a UIViewController with a tableView and populates it with regions.
 @param regions The regions to display in the tableView.
 @param selectionCompletion A block object completion handler containing the selected region. 
 */
- (id)initWithRegions:(NSArray *)regions context:(NSManagedObjectContext *)context selectionCompletionHandler:(void(^)(FSPNewsCity *selectedCity))selectionCompletion;

/*!
 @abstract Returns the size of the view.
 @return The size of the view, determined at runtime by checking UI_USER_INTERFACE_IDIOM
 */
+ (CGSize)viewSize;


@end
