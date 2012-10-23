//
//  FSPStoryViewController.h
//  FoxSports
//
//  Created by Laura Savino on 3/25/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSPExtendedEventDetailManaging.h"
#import "FSPNewsStory.h"
#import "FSPFontViewController.h"

@protocol FSPStoryViewDelegateProtocol;

@interface FSPStoryViewController : UIViewController <FSPExtendedEventDetailManaging, FSPFontViewControllerDelegate, UIPopoverControllerDelegate, UIWebViewDelegate>;

@property (nonatomic, assign) FSPStoryType storyType;
@property (nonatomic, strong) id <FSPStoryProtocol>story;
@property (assign) CGFloat fontSize;
@property (assign) BOOL scrollEnabled;
@property (assign) id <FSPStoryViewDelegateProtocol>delegate;

/**
 * Initializes the receiver with a story type, indicating whether the preview or recap story is expected.
 *
 * This is the designated initializer for the class.
 */
- (id)initWithStoryType:(FSPStoryType)storyType;


// get the size of the story view, for inclusion in another view
- (CGSize)storyViewSize;

@end

@protocol FSPStoryViewDelegateProtocol <NSObject>
- (void)storyViewControllerDidFinishLoad:(FSPStoryViewController *)storyViewController;
@end
