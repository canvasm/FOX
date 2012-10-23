//
//  FSPNBAInjuryReportTitle.h
//  FoxSports
//
//  Created by Matthew Fay on 3/13/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

void FSPDrawGameSectionDividerLine(CGContextRef context, CGPoint lineStartPoint, CGPoint lineEndPoint, BOOL drawHighlightLine, BOOL drawDarkLine);

@interface FSPGameDetailSectionHeader : UIView

@property (nonatomic, weak, readonly) UILabel *titleLabel;
@property (nonatomic, strong) NSNumber *highlightLineFlag;
@property (nonatomic, strong) NSNumber *darkLineFlag;

@end
