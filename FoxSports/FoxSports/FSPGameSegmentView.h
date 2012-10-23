//
//  FSPGameSegmentView.h
//  FoxSports
//
//  Created by Laura Savino on 2/2/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSPGameSegmentView : UIView

@property (nonatomic, strong, readonly) UILabel *gameSegmentLabel;
@property (nonatomic, strong, readonly) UILabel *homeTeamScoreLabel;
@property (nonatomic, strong, readonly) UILabel *awayTeamScoreLabel;

- (void)setXPosition:(CGFloat)xPosition;
- (void)setScoreLabelFonts:(UIFont *)font;

@end
