//
//  FSPGameHeaderView.h
//  FoxSports
//
//  Created by Matthew Fay on 2/21/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSPGame;

@interface FSPGameHeaderView : UIView

@property (nonatomic, strong) UIColor *homeColor;
@property (nonatomic, strong) UIColor *awayColor;
@property (nonatomic, strong) UIColor *middleColor;

@property (nonatomic, weak) IBOutlet UILabel *periodLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *finalLabel;

@property (nonatomic, weak) IBOutlet UILabel *awayScoreLabel;
@property (nonatomic, weak) IBOutlet UILabel *homeScoreLabel;

@property (nonatomic, weak) IBOutlet UIImageView *homeLogoImage;
@property (nonatomic, weak) IBOutlet UIImageView *awayLogoImage;

@property (nonatomic, weak) IBOutlet UILabel *dateTimeChannelLabel;

@property (weak, nonatomic) IBOutlet UILabel *eventTitle;
@property (weak, nonatomic) IBOutlet UILabel *eventOrganizationName;
@property (weak, nonatomic) IBOutlet UILabel *eventLocation;


//TODO: Move this elsewhere.
@property (nonatomic, weak) IBOutlet UIButton *shareButton;
@property (nonatomic, weak) IBOutlet UIButton *alertButton;

@property (nonatomic, strong, readonly) UIButton *toggleFullScreenButton;

// TVE Testing
@property (nonatomic, strong) IBOutlet UIButton *tveLoginButton;
@property (nonatomic, strong) IBOutlet UIButton *deleteKeychainItemsButton;

- (void)populateWithGame:(FSPGame *)game updateLogos:(BOOL)updateLogos;
- (void)updateLabelsWithGame:(FSPGame *)game;

@end
