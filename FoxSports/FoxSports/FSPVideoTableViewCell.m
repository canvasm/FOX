//
//  FSPVideoTableViewCell.m
//  FoxSports
//
//  Created by Stephen Spring on 6/15/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPVideoTableViewCell.h"
#import "FSPVideo.h"
#import "FSPVideoPlayerViewController.h"
#import "FSPAppDelegate.h"
#import "FSPRootViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "UIFont+FSPExtensions.h"

@interface FSPVideoTableViewCell()

@property (weak, nonatomic) IBOutlet UIView *videoContainer1;
@property (weak, nonatomic) IBOutlet UIView *videoContainer2;
@property (weak, nonatomic) IBOutlet UIView *videoContainer3;
@property (weak, nonatomic) IBOutlet UIImageView *container1Thumbnail;
@property (weak, nonatomic) IBOutlet UIImageView *container2Thumbnail;
@property (weak, nonatomic) IBOutlet UIImageView *container3Thumbnail;
@property (weak, nonatomic) IBOutlet UILabel *videoTitleLabel1;
@property (weak, nonatomic) IBOutlet UILabel *videoTitleLabel2;
@property (weak, nonatomic) IBOutlet UILabel *videoTitleLabel3;
@property (weak, nonatomic) IBOutlet UILabel *videoDurationLabel1;
@property (weak, nonatomic) IBOutlet UILabel *videoDurationLabel2;
@property (weak, nonatomic) IBOutlet UILabel *videoDurationLabel3;
@property (weak, nonatomic) IBOutlet UIButton *playButton1;
@property (weak, nonatomic) IBOutlet UIButton *playButton2;
@property (weak, nonatomic) IBOutlet UIButton *playButton3;

@property (strong, nonatomic) NSArray *cellVideos;

@property (strong, nonatomic) UIFont *titleFont;

-(void)setVideo:(NSObject *)video forIndex:(NSUInteger)index;
-(void)playVideo:(UIButton *)sender;
-(void)resetVideoContainers:(NSUInteger)index;
-(void)resizeTitleLabel:(UILabel *)label forVideo:(FSPVideo *)video;

@end

@implementation FSPVideoTableViewCell
@synthesize videoContainer1;
@synthesize videoContainer2;
@synthesize videoContainer3;
@synthesize container1Thumbnail;
@synthesize container2Thumbnail;
@synthesize container3Thumbnail;
@synthesize videoTitleLabel1;
@synthesize videoTitleLabel2;
@synthesize videoTitleLabel3;
@synthesize videoDurationLabel1;
@synthesize videoDurationLabel2;
@synthesize videoDurationLabel3;
@synthesize playButton1;
@synthesize playButton2;
@synthesize playButton3;
@synthesize cellVideos;
@synthesize titleFont;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)awakeFromNib
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.titleFont = [UIFont fontWithName:FSPClearViewBoldFontName size:13.0f];
    } else {
        self.titleFont = [UIFont fontWithName:FSPClearViewBoldFontName size:7.0f];
    }
    
    self.videoTitleLabel1.font = titleFont;
    self.videoTitleLabel2.font = titleFont;
    self.videoTitleLabel3.font = titleFont;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    // Need to relayout title labels
    CGFloat titleLabelTopMargin = 15.0f;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        titleLabelTopMargin = 6.0f;
    }
    self.videoTitleLabel1.frame = CGRectMake(self.container1Thumbnail.frame.origin.x, self.container1Thumbnail.frame.origin.y + self.container1Thumbnail.frame.size.height + titleLabelTopMargin, self.videoTitleLabel1.frame.size.width, self.videoTitleLabel1.frame.size.height);
    self.videoTitleLabel2.frame = CGRectMake(self.container2Thumbnail.frame.origin.x, self.container2Thumbnail.frame.origin.y + self.container2Thumbnail.frame.size.height + titleLabelTopMargin, self.videoTitleLabel2.frame.size.width, self.videoTitleLabel2.frame.size.height);
    self.videoTitleLabel3.frame = CGRectMake(self.container3Thumbnail.frame.origin.x, self.container3Thumbnail.frame.origin.y + self.container3Thumbnail.frame.size.height + titleLabelTopMargin, self.videoTitleLabel3.frame.size.width, self.videoTitleLabel3.frame.size.height);
}

#pragma mark - Public Instance Methods

-(void)configureWithVideos:(NSArray *)videos
{    
    NSUInteger maxVideosPerCell = 3;
    NSUInteger numberOfVideos = [videos count];
    NSAssert(numberOfVideos <= 3, @"Too many videos sent to FSPVideoTableViewCell.");
    if (numberOfVideos > maxVideosPerCell) {
        return;
    }
    self.cellVideos = videos;
    for (FSPVideo *video in videos) {
        NSUInteger index = [videos indexOfObject:video];
        [self setVideo:video forIndex:index];
    }
    
    if (numberOfVideos/maxVideosPerCell != 1) {
        [self resetVideoContainers:numberOfVideos];
    }
}

#pragma mark - Private Instance Methods

-(void)setVideo:(FSPVideo *)video forIndex:(NSUInteger)index
{
    switch (index) {
        case 0:
            self.videoContainer1.hidden = NO;
            [self resizeTitleLabel:self.videoTitleLabel1 forVideo:video];
            self.videoTitleLabel1.text = video.title;
            self.videoDurationLabel1.text = [video durationFormattedForDisplay];
            self.playButton1.accessibilityLabel = [NSString stringWithFormat:@"%@ %@", video.title, [video durationFormattedForAccessibility]];
            [self.playButton1 addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
            break;
        case 1:
            self.videoContainer2.hidden = NO;
            [self resizeTitleLabel:self.videoTitleLabel2 forVideo:video];
            self.videoTitleLabel2.text = video.title;
            self.videoDurationLabel2.text = [video durationFormattedForDisplay];
            self.playButton2.accessibilityLabel = [NSString stringWithFormat:@"%@ %@", video.title, [video durationFormattedForAccessibility]];
            [self.playButton2 addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
            break; 
        case 2:
            self.videoContainer3.hidden = NO;
            [self resizeTitleLabel:self.videoTitleLabel3 forVideo:video];
            self.videoTitleLabel3.text = video.title;
            self.videoDurationLabel3.text = [video durationFormattedForDisplay];
            self.playButton3.accessibilityLabel = [NSString stringWithFormat:@"%@ %@", video.title, [video durationFormattedForAccessibility]];
            [self.playButton3 addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
            break;
        default:
            break;
    }
}

-(void)resizeTitleLabel:(UILabel *)label forVideo:(FSPVideo *)video
{
    CGFloat maxLabelWidth;
    CGFloat maxLabelHeight;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        maxLabelWidth = 168.0f;
        maxLabelHeight = 56.0f;
    } else {
        maxLabelWidth = 80.0f;
        maxLabelHeight = 40.0f;
    }
    NSString *videoTitle = video.title;
    CGSize titleLabelSize  = [videoTitle sizeWithFont:self.titleFont constrainedToSize:CGSizeMake(maxLabelWidth, maxLabelHeight) lineBreakMode:UILineBreakModeWordWrap];
    label.frame = CGRectMake(10.0, label.frame.origin.y, titleLabelSize.width, titleLabelSize.height);
}

-(void)resetVideoContainers:(NSUInteger)index
{
    switch (index) {
        case 1:
            self.videoContainer2.hidden = YES;
            break;
        case 2:
            self.videoContainer3.hidden = YES;
            break;
        default:
            break;
    }
}

-(void)playVideo:(UIButton *)sender
{
    FSPVideo *selectedVideo = [self.cellVideos objectAtIndex:sender.tag];
    FSPAppDelegate *appDelegate = (FSPAppDelegate *)[UIApplication sharedApplication].delegate;
    FSPVideoPlayerViewController *videoViewController = [[FSPVideoPlayerViewController alloc] initWithURL:selectedVideo.videoURL];
    videoViewController.view.frame = CGRectMake(0, 0, 400.0, 300.0);
    UIViewController *viewController = [[UIViewController alloc] init];
    [viewController.view addSubview:videoViewController.view];
    [appDelegate.rootViewController presentModalViewController:viewController animated:YES];
}

@end
