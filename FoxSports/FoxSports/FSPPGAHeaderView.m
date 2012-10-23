//
//  FSPPGAHeaderView.m
//  FoxSports
//
//  Created by Chase Latta on 3/12/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPPGAHeaderView.h"
#import "FSPPGAEvent.h"

static NSDateFormatter *
FSPPGAHeaderDateFormatter(void)
{
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"EEE, M/d hh:mma v";
    });
    return formatter;
}


@interface FSPPGAHeaderView ()
@property (weak, nonatomic) IBOutlet UILabel *startDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *channelLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventLocationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *eventLogoImageView;

@end

@implementation FSPPGAHeaderView
@synthesize startDateLabel;
@synthesize channelLabel;
@synthesize eventTitleLabel;
@synthesize eventStateLabel;
@synthesize eventLocationLabel;
@synthesize eventLogoImageView;
@synthesize event = _event;

- (void)setEvent:(FSPPGAEvent *)event;
{
    if (_event != event) {
        _event = event;
        [self refreshEvent];
    }
}

- (id)init;
{
    return [self initWithFrame:CGRectNull];
}

- (id)initWithFrame:(CGRect)frame
{
    UINib *nib = [UINib nibWithNibName:@"FSPPGAHeaderView" bundle:nil];
    NSArray *objects = [nib instantiateWithOwner:nil options:nil];
    self = [objects objectAtIndex:0];
    if (self) {
        if (!CGRectIsNull(frame)) {
            // If no frame is supplied use the default loaded from the nib
            self.frame = frame;
        }
    }
    return self;
}

- (void)refreshEvent;
{
    self.startDateLabel.text = [FSPPGAHeaderDateFormatter() stringFromDate:self.event.startDate];
    self.channelLabel.text = self.event.channelDisplayName;
    self.eventTitleLabel.text = self.event.eventTitle;
    self.eventStateLabel.text = self.event.eventState;
    self.eventLocationLabel.text = [NSString stringWithFormat:@"%@, %@", self.event.locationName, self.event.location];
}

@end
