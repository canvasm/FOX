//
//  FSPGameTopPlayerViewNFL.m
//  FoxSports
//
//  Created by Stephen Spring on 7/10/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPGameTopPlayerViewNFL.h"
#import "UIFont+FSPExtensions.h"
#import "FSPTeamPlayer.h"
#import "UIColor+FSPExtensions.h"
#import "FSPImageFetcher.h"

@interface FSPGameTopPlayerViewNFL()

@property (weak, nonatomic) IBOutlet UILabel *statType1Label;
@property (weak, nonatomic) IBOutlet UILabel *statValue1Label;
@property (weak, nonatomic) IBOutlet UILabel *statType2Label;
@property (weak, nonatomic) IBOutlet UILabel *statValue2Label;
@property (weak, nonatomic) IBOutlet UILabel *statType3Label;
@property (weak, nonatomic) IBOutlet UILabel *statValue3Label;
@property (weak, nonatomic) IBOutlet UILabel *statType4Label;
@property (weak, nonatomic) IBOutlet UILabel *statValue4Label;
@property (weak, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *playerImageView;
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;

@property (strong, nonatomic) NSArray *statTypeLabels;
@property (strong, nonatomic) NSArray *statValueLabels;

@end

@implementation FSPGameTopPlayerViewNFL

@synthesize statType1Label;
@synthesize statValue1Label;
@synthesize statType2Label;
@synthesize statValue2Label;
@synthesize statType3Label;
@synthesize statValue3Label;
@synthesize statType4Label;
@synthesize statValue4Label;
@synthesize firstNameLabel;
@synthesize lastNameLabel;
@synthesize playerImageView;
@synthesize fullNameLabel;
@synthesize statTypeLabels;
@synthesize statValueLabels;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithDirection:(FSPGamePlayerDirection)direction
{
    UINib *matchupNib;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        matchupNib = [UINib nibWithNibName:@"FSPGameTopPlayerViewNFL~ipad" bundle:nil];
    } else {
        matchupNib = [UINib nibWithNibName:@"FSPGameTopPlayerViewNFL~iphone" bundle:nil];
    }
    NSArray *views = [matchupNib instantiateWithOwner:nil options:nil];
    self = [views lastObject];
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.firstNameLabel.font = [UIFont fontWithName:FSPUScoreRGHFontName size:16.0];
    self.lastNameLabel.font = [UIFont fontWithName:FSPUScoreRGHFontName size:21.0];
    
    self.statTypeLabels = @[self.statType1Label, self.statType2Label, self.statType3Label, self.statType4Label];
    self.statValueLabels = @[self.statValue1Label, self.statValue2Label, self.statValue3Label, self.statValue4Label];
    
    UIFont *statTypeFont = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:12.0];
    for (UILabel *label in self.statTypeLabels) {
        label.font = statTypeFont;
        label.textColor = [UIColor fsp_lightMediumBlueColor];
    }
    
    UIFont *statValueFont = [UIFont fontWithName:FSPClearFOXGothicBoldFontName size:12.0];
    for (UILabel *label in self.statValueLabels) {
        label.font = statValueFont;
    }
    
    UIFont *fullNameLabelFont = [UIFont fontWithName:FSPUScoreRGHFontName size:12.0];
    self.fullNameLabel.font = fullNameLabelFont;
}

- (void)populateWithPlayer:(FSPTeamPlayer *)player statType:(NSString *)statType statValue:(NSNumber *)statValue title:(NSString *)title
{
    // Do Nothing
}

- (void)populateWithPlayer:(FSPTeamPlayer *)player statTypes:(NSArray *)statTypes statValues:(NSArray *)statValues
{
    if (player) {
        self.firstNameLabel.hidden = NO;
        self.lastNameLabel.hidden = NO;
        
        self.firstNameLabel.text = player.firstName.uppercaseString;
        self.lastNameLabel.text = player.lastName.uppercaseString;
        self.fullNameLabel.text = [player abbreviatedName];

        [FSPImageFetcher.sharedFetcher fetchImageForURL:[NSURL URLWithString:player.photoURL]
                                           withCallback:^(UIImage *image) {
                                               self.playerImageView.image = image;
                                               self.playerImageView.hidden = NO;
                                           }];
    } else {
        self.firstNameLabel.hidden = YES;
        self.lastNameLabel.hidden = YES;
        self.playerImageView.hidden = YES;
    }
    
    if (statTypes && [statTypes count] > 0) {        
        for (NSString *statType in statTypes) {
            
            NSUInteger currentIndex = [statTypes indexOfObject:statType];
            NSAssert(currentIndex < 4, @"FSPGameTopPlayerViewNFL: Too many data objects passed into view.");
            
            UILabel *statTypeLabel = [self.statTypeLabels objectAtIndex:currentIndex];
            statTypeLabel.hidden = NO;
            NSString *statTypeWithColon = [NSString stringWithFormat:@"%@:", statType];
            statTypeLabel.text = statTypeWithColon;
            CGSize labelSize = [statTypeWithColon sizeWithFont:statTypeLabel.font];
            statTypeLabel.frame = CGRectMake(statTypeLabel.frame.origin.x, statTypeLabel.frame.origin.y, labelSize.width, statTypeLabel.frame.size.height);
            
            UILabel *statValueLabel = [self.statValueLabels objectAtIndex:currentIndex];
            statValueLabel.hidden = NO;
            NSNumber *statValue = [statValues objectAtIndex:currentIndex];
            statValueLabel.text = [NSString stringWithFormat:@" %@", [statValue stringValue]];
            statValueLabel.frame = CGRectMake(CGRectGetMaxX(statTypeLabel.frame), statValueLabel.frame.origin.y, self.frame.size.width - statValueLabel.frame.origin.x, statValueLabel.frame.size.height);
        }
    } else {
        for (UILabel *label in self.statTypeLabels) {
            label.hidden = YES;
        }
        for (UILabel *label in self.statValueLabels) {
            label.hidden = YES;
        }
    }
}

@end
