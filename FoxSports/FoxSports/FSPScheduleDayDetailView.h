//
//  FSPScheduleDayDetailView.h
//  FoxSports
//
//  Created by USS11SSpringMBP on 9/4/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSPScheduleDayDetailView : UIView

@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayCoverageLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *channelLabel;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *valueLabels;

@end
