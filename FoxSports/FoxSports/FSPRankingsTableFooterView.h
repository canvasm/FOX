//
//  FSPRankingsTableFooterView.h
//  FoxSports
//
//  Created by Joshua Dubey on 9/20/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FSPRankingsTableFooterViewDelegate <NSObject>

- (void)rankingsFooterDidFinishLayout;

@end

@interface FSPRankingsTableFooterView : UIView

@property (nonatomic, strong) NSString *droppedTeams;
@property (nonatomic, strong) NSString *otherTeams;
@property (nonatomic, assign) id <FSPRankingsTableFooterViewDelegate> delegate;

@end
