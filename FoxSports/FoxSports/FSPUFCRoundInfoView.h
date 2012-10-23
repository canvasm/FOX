//
//  FSPUFCRoundInfoView.h
//  FoxSports
//
//  Created by Pat Sluth on 2012-10-09.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSPUFCRoundInfoView : UIView

@property (strong, nonatomic) IBOutlet UILabel *roundNumber;
@property (strong, nonatomic) IBOutlet UILabel *roundTimeLeft;
@property (strong, nonatomic) IBOutlet UILabel *currentPositionLabel;

@end