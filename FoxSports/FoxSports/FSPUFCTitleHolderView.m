//
//  FSPUFCTitleHolderView.m
//  FoxSports
//
//  Created by Matthew Fay on 7/23/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPUFCTitleHolderView.h"
#import "FSPFightTitleHolder.h"
#import "UIColor+FSPExtensions.h"
#import "UIFont+FSPExtensions.h"
#import "FSPImageFetcher.h"

@interface FSPUFCTitleHolderView ()

@property (nonatomic, weak) IBOutlet UILabel * titleLabel;
@property (nonatomic, weak) IBOutlet UILabel * weightClassLabel;
@property (nonatomic, weak) IBOutlet UILabel * titleHolderLabel;
@property (nonatomic, weak) IBOutlet UILabel * dateLabel;
@property (nonatomic, weak) IBOutlet UILabel * defencesLabel;
@property (nonatomic, weak) IBOutlet UIImageView * titleHolderImage;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *allLabels;

@property (nonatomic, strong) NSString * imageURL;

@end

@implementation FSPUFCTitleHolderView
@synthesize titleLabel;
@synthesize weightClassLabel;
@synthesize titleHolderLabel;
@synthesize dateLabel;
@synthesize defencesLabel;
@synthesize titleHolderImage;
@synthesize allLabels;
@synthesize imageURL;


- (id)init
{
    UINib *matchupNib = [UINib nibWithNibName:@"FSPUFCTitleHolderView" bundle:nil];
    NSArray *objects = [matchupNib instantiateWithOwner:nil options:nil];
    self = [objects lastObject];
    return self;
}

- (void)awakeFromNib
{
    self.titleLabel.font = [UIFont fontWithName:FSPClearFOXGothicHeavyFontName size:14.0f];
    self.weightClassLabel.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:11.0f];
    self.titleHolderLabel.font = [UIFont fontWithName:FSPUScoreRGKFontName size:16.0f];
    self.dateLabel.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:11.0f];
    self.defencesLabel.font = [UIFont fontWithName:FSPClearFOXGothicMediumFontName size:11.0f];
}

- (void)populateWithTitleHolder:(FSPFightTitleHolder *)titleHolder;
{
    self.titleLabel.text = [titleHolder.title length] > 0 ? titleHolder.title : @"--";
    self.weightClassLabel.text = [titleHolder.minWeigth intValue] > 0 && [titleHolder.maxWeight intValue] > 0 ? [NSString stringWithFormat:@"(%@-%@ lbs)", titleHolder.minWeigth, titleHolder.maxWeight] : @"--";
    self.titleHolderLabel.text = titleHolder.name;
    
    self.dateLabel.text = titleHolder.wonDate ? [NSString stringWithFormat:@"Title won: %@ (%d days)", [[self dateFormatter] stringFromDate:titleHolder.wonDate], (abs([titleHolder.wonDate timeIntervalSinceNow]) / 86400)] : @"--";
    self.defencesLabel.text = [NSString stringWithFormat:@"Defenses: %@", titleHolder.numberOfDefences];
    [FSPImageFetcher.sharedFetcher fetchImageForURL:[NSURL URLWithString:titleHolder.photoURL]
                                       withCallback:^(UIImage *image) {
                                           if (image) {
                                               self.titleHolderImage.image = image;
                                           }
                                           else {
                                               self.titleHolderImage.image = [UIImage imageNamed:@"Default_Headshot_UFC"];
                                           }
                                       }];
    self.imageURL = titleHolder.photoURL;
    
    //Text and shadow color
    for (UILabel *label in self.allLabels) {
        label.textColor = [UIColor colorWithRed:46.0f/255.0f green:83.0f/255.0f blue:122.0f/255.0f alpha:1.0f];
        label.shadowColor = [UIColor colorWithWhite:1.0f alpha:.8f];
    }
}

- (NSDateFormatter *) dateFormatter
{
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"M/d/yyyy";
    });
    return formatter;
}

@end
