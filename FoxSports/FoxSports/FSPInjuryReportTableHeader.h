//
//  FSPNBAInjuryReportTableHeader.h
//  FoxSports
//
//  Created by Matthew Fay on 3/12/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat const FSPNBAInjuryReportHeaderHeight;

@class FSPGameDetailTeamHeader;
@interface FSPInjuryReportTableHeader : UIView
@property (nonatomic) CGGradientRef gradient;
@property (nonatomic, weak) IBOutlet FSPGameDetailTeamHeader *teamHeader;
@property (nonatomic, weak) IBOutlet FSPGameDetailTeamHeader *teamHeaderHome;

@end
