//
//  FSPPGATourScheduleHeaderView.m
//  FoxSports
//
//  Created by Matthew Fay on 3/13/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPPGATourScheduleHeaderView.h"
#import "FSPScheduleEvent.h"
#import "FSPStandingsScheduleSectionHeader.h"

CGFloat const FSPPGATourScheduleHeaderHieght = 35;

@interface FSPPGATourScheduleHeaderView()

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventLabel;
@property (weak, nonatomic) IBOutlet UILabel *auxiliaryLabel1;
@property (weak, nonatomic) IBOutlet UILabel *auxiliaryLabel2;

@end

@implementation FSPPGATourScheduleHeaderView

@synthesize dateLabel;
@synthesize eventLabel;
@synthesize auxiliaryLabel1;
@synthesize auxiliaryLabel2;


- (id)init
{
    UINib *nib = [UINib nibWithNibName:@"FSPPGATourScheduleHeaderView" bundle:nil];
    NSArray *objects = [nib instantiateWithOwner:nil options:nil];
    self = [objects lastObject];
    if (self) {
    }
    return self;
}

+ (CGFloat)headerHeght
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return 30.0;
    }
    return 60.0;
}

- (void)setEvent:(FSPScheduleEvent *)event
{
    [super setEvent:event];
    
    [self setAuxiliaryLabelTitles];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        for (UILabel *label in self.labels) {
            label.hidden = YES;
        }
    }
}

- (void)setAuxiliaryLabelTitles
{
    NSDate *currentDate = [NSDate date];
    if ([[self.event.startDate laterDate:currentDate] isEqualToDate:currentDate]) {  
        self.auxiliaryLabel1.text= @"Winner";
        self.auxiliaryLabel2.text = @"Winnings";
        self.topBarView.sectionTitleLabel.text = [NSString stringWithFormat:@"%d PGA Tour Results", [self scheduleYear]];
    } else {
        static NSDateFormatter *dateFormatter = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            dateFormatter = [[NSDateFormatter alloc] init];
        });
        [dateFormatter setDateStyle:NSDateFormatterFullStyle];
        NSString *timeZone = [dateFormatter timeZone].abbreviation;
        self.auxiliaryLabel1.text = [NSString stringWithFormat:@"Time (%@)", timeZone];
        self.auxiliaryLabel2.text = @"TV";
        self.topBarView.sectionTitleLabel.text = [NSString stringWithFormat:@"%d PGA Tour Schedule", [self scheduleYear]];;

    }
}

- (NSInteger)scheduleYear
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:self.event.startDate];
    return [components year];
}

@end
