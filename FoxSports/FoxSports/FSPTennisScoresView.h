//
//  FSPTennisScoresView.h
//  FoxSports
//
//  Created by greay on 9/13/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSPTennisScoresView : UIView

@property (nonatomic, strong) NSSet *scores;
@property (nonatomic, strong) NSArray *topScoreLabels;
@property (nonatomic, strong) NSArray *topTieLabels;
@property (nonatomic, strong) NSArray *bottomScoreLabels;
@property (nonatomic, strong) NSArray *bottomTieLabels;

@end
