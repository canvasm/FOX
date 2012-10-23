//
//  FSPUFCScheduleHeaderView.m
//  FoxSports
//
//  Created by Rowan Christmas on 7/23/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPUFCScheduleHeaderView.h"

#import "FSPTeamScheduleHeaderView.h"
#import "FSPStandingsScheduleSectionHeader.h"
#import "UIFont+FSPExtensions.h"

@interface FSPUFCScheduleHeaderView ()
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *tournement;
@property (weak, nonatomic) IBOutlet UILabel *round;
@property (weak, nonatomic) IBOutlet UILabel *winner;
@property (weak, nonatomic) IBOutlet UILabel *method;
@property (weak, nonatomic) IBOutlet UILabel *channel;
@property (weak, nonatomic) IBOutlet UILabel *localTime;
@property (weak, nonatomic) IBOutlet UILabel *fightTime;

@end

@implementation FSPUFCScheduleHeaderView
@synthesize date;
@synthesize tournement;
@synthesize round;
@synthesize winner;
@synthesize method;
@synthesize channel;
@synthesize localTime;
@synthesize fightTime;


+ (CGFloat)headerHeght
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 60;
    } else {
        return 30;
    }
}

- (id)init;
{
    UINib *nib = [UINib nibWithNibName:@"FSPUFCScheduleHeaderView" bundle:nil];
    NSArray *objects = [nib instantiateWithOwner:nil options:nil];
    self = [objects lastObject];
    
    return self;
}

- (void)awakeFromNib;
{
    [super awakeFromNib];
    
    UIFont *font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14];
    
    self.date.font = font;
    self.tournement.font = font;
    self.localTime.font = font;
    self.channel.font = font;
    self.winner.font = font;
    self.method.font = font;
    self.round.font = font;
    self.fightTime.font = font;
    
}

- (void)setEvent:(FSPScheduleEvent *)event
{
    [super setEvent:event];
        
	if ([[event valueForKey:@"eventState"] isEqualToString:@"PRE-FIGHT"]) {
        self.topBarView.sectionTitleLabel.text = [NSString stringWithFormat:@"%@ %@ Schedule", [[FSPTeamScheduleHeaderView teamScheduleYearDateFormatter]  stringFromDate:event.normalizedStartDate], self.formattedSeasonType];

        self.localTime.hidden = NO;
        self.channel.hidden = NO;
        
        self.winner.hidden = YES;
        self.method.hidden = YES;
        self.round.hidden = YES;
        self.fightTime.hidden = YES;
    }
    else {
        self.topBarView.sectionTitleLabel.text = [NSString stringWithFormat:@"%@ %@ Results", [[FSPTeamScheduleHeaderView teamScheduleYearDateFormatter]  stringFromDate:event.normalizedStartDate], self.formattedSeasonType];
        
        self.localTime.hidden = YES;
        self.channel.hidden = YES;
        
        self.winner.hidden = NO;
        self.method.hidden = NO;
        self.round.hidden = NO;
        self.fightTime.hidden = NO;
        
		NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
		self.localTime.text = [NSString stringWithFormat:@"Time (%@)", [localTimeZone abbreviation]];
    }
}


@end
