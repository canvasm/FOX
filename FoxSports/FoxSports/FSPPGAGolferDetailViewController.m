//
//  FSPPGAGolferDetailViewController.m
//  FoxSports
//
//  Created by USS11SSpringMBP on 9/12/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPPGAGolferDetailViewController.h"
#import "FSPPGAGolferDetailView.h"
#import "FSPGolfer.h"
#import "FSPImageFetcher.h"

@interface FSPPGAGolferDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *round1Label;
@property (weak, nonatomic) IBOutlet UILabel *round2Label;
@property (weak, nonatomic) IBOutlet UILabel *round3Label;
@property (weak, nonatomic) IBOutlet UILabel *round4Label;

@end

@implementation FSPPGAGolferDetailViewController
@synthesize scoreLabel;
@synthesize round1Label;
@synthesize round2Label;
@synthesize round3Label;
@synthesize round4Label;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self populateWithGolfer];
}

- (void)populateWithGolfer
{
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", self.golfer.firstName, self.golfer.lastName];

    [FSPImageFetcher.sharedFetcher fetchImageForURL:[NSURL URLWithString:self.golfer.photoURL]
                                       withCallback:^(UIImage *image) {
                                           if (image) {
                                               self.headshotImageView.image = image;
                                           } else {
                                               self.headshotImageView.image = [UIImage imageNamed:@"Default_Headshot_GOLF"];
                                           }
                                       }];
    
    [self styleLabels];
    [self populateRoundDetails];
    [self populateRoundLabels];
}

- (void)populateRoundLabels
{
    if ([self.golfer.rounds count] > 0) {
        self.scoreLabel.text = [self.golfer.totalScore stringValue];
        FSPGolfRound *round1 = [[FSPPGAGolferDetailView sortedGolferRounds:self.golfer] objectAtIndex:0];
        self.round1Label.text = [round1.strokes stringValue];
        FSPGolfRound *round2 = [[FSPPGAGolferDetailView sortedGolferRounds:self.golfer] objectAtIndex:1];
        self.round2Label.text = [round2.strokes stringValue];
        FSPGolfRound *round3 = [[FSPPGAGolferDetailView sortedGolferRounds:self.golfer] objectAtIndex:2];
        self.round3Label.text = [round3.strokes stringValue];
        FSPGolfRound *round4 = [[FSPPGAGolferDetailView sortedGolferRounds:self.golfer] objectAtIndex:3];
        self.round4Label.text = [round4.strokes stringValue];
    }
}

- (void)populateRoundDetails
{
    for (UIView *view in [self.contentScrollView subviews]) {
        if ([view isKindOfClass:[FSPPGAGolferDetailView class]]) {
            [view removeFromSuperview];
        }
    }
    
    self.playerStandingsNib = [UINib nibWithNibName:@"FSPPGAGolferDetailView" bundle:nil];
    NSArray *topLevelObjects = [self.playerStandingsNib instantiateWithOwner:self options:nil];
    FSPPGAGolferDetailView *golferDetailView;
    for (UIView *view in topLevelObjects) {
        if ([view isKindOfClass:[FSPPGAGolferDetailView class]]) {
            golferDetailView = [topLevelObjects objectAtIndex:[topLevelObjects indexOfObject:view]];
        }
    }
    golferDetailView.frame = CGRectMake(0.0, CGRectGetMaxY(self.headshotImageView.frame), self.view.frame.size.width, golferDetailView.frame.size.height);
    [golferDetailView populateWithGolfer:self.golfer];
    [self.contentScrollView addSubview:golferDetailView];
    self.contentScrollView.contentSize = CGSizeMake(self.view.frame.size.width, CGRectGetMaxY(golferDetailView.frame));
}

- (void)viewDidUnload {
    [self setScoreLabel:nil];
    [self setRound1Label:nil];
    [self setRound2Label:nil];
    [self setRound3Label:nil];
    [self setRound4Label:nil];
    [super viewDidUnload];
}
@end
