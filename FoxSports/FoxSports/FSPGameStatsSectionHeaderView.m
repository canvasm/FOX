//
//  FSPGameStatsSectionHeaderView.m
//  FoxSports
//
//  Created by Chase Latta on 2/2/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPGameStatsSectionHeaderView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIFont+FSPExtensions.h"
#import "UIColor+FSPExtensions.h"

static NSString * const FSPNBAStartersHeaderViewNibName = @"FSPNBAStatsSectionHeaderView";
static NSString * const FSPMLBBattingHeaderViewNibName = @"FSPMLBBattingStatsSectionHeaderView";
static NSString * const FSPMLBPitchingHeaderViewNibName = @"FSPMLBPitchingStatsSectionHeaderView";
static NSString * const FSPNFLTopPerformersHeaderViewNibName = @"FSPNFLTopPerformersHeaderView";
static NSString * const FSPNFLPassingSectionHeaderViewNibName = @"FSPNFLPassingSectionHeaderView";
static NSString * const FSPNFLReceivingSectionHeaderViewNibName = @"FSPNFLReceivingSectionHeaderView";
static NSString * const FSPNFLRushingSectionHeaderViewNibName = @"FSPNFLRushingSectionHeaderView";
static NSString * const FSPNFLKickingSectionHeaderViewNibName = @"FSPNFLKickingSectionHeaderView";
static NSString * const FSPSoccerStartersHeaderViewNibName = @"FSPSoccerStartersHeaderView";
static NSString * const FSPSoccerSubsHeaderViewNibName = @"FSPSoccerSubsHeaderView";
static NSString * const FSPNHLSkaterGameStatsHeaderViewNibName = @"FSPNHLSkaterGameStatsHeaderView";
static NSString * const FSPNHLGoaltenderGameStatsHeaderViewNibName = @"FSPNHLGoaltenderGameStatsHeaderView";

@interface FSPGameStatsSectionHeaderView ()
@property (weak, nonatomic) IBOutlet UILabel *sectionTypeLabel;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *statLabels;
@property (nonatomic, assign) FSPViewType viewType;

/**
 Set this property to change the value between starters, bench, and totals. 
 */
@property (nonatomic) NSUInteger section;

@end

@implementation FSPGameStatsSectionHeaderView

- (id)initWithViewType:(FSPViewType)viewType section:(NSUInteger)section
{
	switch (viewType) {
		case FSPBasketballViewType:
        case FSPNCAABViewType:
        case FSPNCAAWBViewType: {
			UINib *nib = [UINib nibWithNibName:FSPNBAStartersHeaderViewNibName bundle:nil];
			NSArray *objects = [nib instantiateWithOwner:nil options:nil];
			self = [objects objectAtIndex:0];
			break;
		}
		case FSPBaseballViewType: {
			UINib *nib = nil;
			if (section == 0) {
				nib = [UINib nibWithNibName:FSPMLBBattingHeaderViewNibName bundle:nil];
			} else {
				nib = [UINib nibWithNibName:FSPMLBPitchingHeaderViewNibName bundle:nil];
			}
			NSArray *objects = [nib instantiateWithOwner:nil options:nil];
			self = [objects objectAtIndex:0];
			break;
		}
		case FSPNFLViewType:
		case FSPNCAAFViewType: {
			UINib *nib = nil;
			switch (section) {
				case 0:
					nib = [UINib nibWithNibName:FSPNFLTopPerformersHeaderViewNibName bundle:nil];
					break;
				case 1:
					nib = [UINib nibWithNibName:FSPNFLPassingSectionHeaderViewNibName bundle:nil];
					break;
				case 2:
					nib = [UINib nibWithNibName:FSPNFLRushingSectionHeaderViewNibName bundle:nil];
					break;
				case 3:
					nib = [UINib nibWithNibName:FSPNFLReceivingSectionHeaderViewNibName bundle:nil];
					break;
				case 4:
					nib = [UINib nibWithNibName:FSPNFLKickingSectionHeaderViewNibName bundle:nil];
					break;
				case 5:
					nib = [UINib nibWithNibName:@"FSPNFLDefensiveSectionHeaderView" bundle:nil];
					break;
				default:
					break;
			}
			NSArray *objects = [nib instantiateWithOwner:nil options:nil];
			self = [objects objectAtIndex:0];
			break;
		}
        case FSPSoccerViewType: {
            UINib *nib = nil;
			if (section == 0) {
				nib = [UINib nibWithNibName:FSPSoccerStartersHeaderViewNibName bundle:nil];
			} else {
				nib = [UINib nibWithNibName:FSPSoccerSubsHeaderViewNibName bundle:nil];
			}
			NSArray *objects = [nib instantiateWithOwner:nil options:nil];
			self = [objects objectAtIndex:0];
			break;
        }
        case FSPHockeyViewType: {
			if (section == 0) {
                UINib *nib = [UINib nibWithNibName:FSPNHLSkaterGameStatsHeaderViewNibName bundle:nil];
                NSArray *objects = [nib instantiateWithOwner:nil options:nil];
                self = [objects objectAtIndex:0];
            } else {
                UINib *nib = [UINib nibWithNibName:FSPNHLGoaltenderGameStatsHeaderViewNibName bundle:nil];
                NSArray *objects = [nib instantiateWithOwner:nil options:nil];
                self = [objects objectAtIndex:0];
            }
            break;
        }
		default:
			self = nil;
			break;
	}

    self.viewType = viewType;
	self.section = section;
    return self;
}

- (void)setSection:(NSUInteger)section
{
    if (_section != section) {
        _section = section;
		switch (section) {
			case 0:
				switch (self.viewType) {
					case FSPBasketballViewType:
					case FSPNCAABViewType:
					case FSPNCAAWBViewType:
						self.sectionTypeLabel.text = @"STARTERS";
						break;
					case FSPBaseballViewType:
						self.sectionTypeLabel.text = @"BATTING";
						break;
					case FSPNFLViewType:
					case FSPNCAAFViewType:
						self.sectionTypeLabel.text = @"TEAM LEADERS";
						break;
					case FSPHockeyViewType:
						self.sectionTypeLabel.text = @"SKATER";
						break;
					default:
						break;
				}

				break;
			case 1:
				switch (self.viewType) {
					case FSPBasketballViewType:
					case FSPNCAABViewType:
					case FSPNCAAWBViewType:
						self.sectionTypeLabel.text = @"BENCH";
						break;
					case FSPBaseballViewType:
						self.sectionTypeLabel.text = @"PITCHING";
						break;
					case FSPNFLViewType:
					case FSPNCAAFViewType:
						self.sectionTypeLabel.text = @"PASSING";
						break;
					case FSPHockeyViewType:
						self.sectionTypeLabel.text = @"GOALIE";
					default:
						break;
				}
				break;
			case 2:
				if (self.viewType == FSPNFLViewType || self.viewType == FSPNCAAFViewType) {
					self.sectionTypeLabel.text = @"RUSHING";
				}
				break;
			case 3:
				if (self.viewType == FSPNFLViewType || self.viewType == FSPNCAAFViewType) {
					self.sectionTypeLabel.text = @"RECEIVING";
				}
				break;
			case 4:
				if (self.viewType == FSPNFLViewType || self.viewType == FSPNCAAFViewType) {
					self.sectionTypeLabel.text = @"KICKING";
				}
				break;
			default:
				self.sectionTypeLabel.text = @"";
				break;
		}
    }
}

- (void)awakeFromNib
{
    self.sectionTypeLabel.textColor = [UIColor fsp_yellowColor];
    UIFont *statLabelHeaderFont = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0];
    self.sectionTypeLabel.font = statLabelHeaderFont;
    for(UILabel *label in self.statLabels) {
        label.font = statLabelHeaderFont;
        label.textColor = [UIColor whiteColor];
    }
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSaveGState(context);

    CGFloat minY = 1.0;
    CGFloat maxX = CGRectGetMaxX(rect);
    CGFloat maxY = CGRectGetMaxY(rect);
    CGFloat bottomLineTop = maxY - 3;

    CGContextSetBlendMode(context, kCGBlendModeOverlay);
    CGContextSetLineWidth(context, 1);
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 0.1);

    if(self.section == 0)
    {
        CGPoint shadowSegmentTop[] = {CGPointMake(0, minY), CGPointMake(maxX, minY)};
        CGContextStrokeLineSegments(context, shadowSegmentTop, 2);
    }

    CGPathRef topPath = CGPathCreateWithRect(CGRectMake(0.0, bottomLineTop + 1, rect.size.width, 1.0), NULL);
    CGContextAddPath(context, topPath);
    CGContextDrawPath(context, kCGPathFill);
    CGPathRelease(topPath);

    CGContextSetRGBFillColor(context, 0.0/255.0, 16.0/255.0, 35.0/255.0, 1.0);
    
    CGContextSetBlendMode(context, kCGBlendModeNormal);

    CGPathRef bottomPath = CGPathCreateWithRect(CGRectMake(0.0, bottomLineTop, rect.size.width, 1.0), NULL);
    CGContextAddPath(context, bottomPath);
    CGContextDrawPath(context, kCGPathFill);
    CGPathRelease(bottomPath);

    CGContextRestoreGState(context);
}

#pragma mark Accessibility

- (BOOL)isAccessibilityElement;
{
    return YES;
}

- (NSString *)accessibilityLabel;
{
    return @"￼starters, position, minutes, field goals made and attempted, defensive rebounds, assists, steals, blocks, turnovers, personal fouls, plus minus, points";
}

@end
