//
//  FSPMLBGameTraxViewController.h
//  FoxSports
//
//  Created by Jeremy Eccles on 10/12/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPExtendedEventDetailManaging.h"
#import "FSPMLBPlayByPlayViewController.h"
#import "FSPMLBGameTraxBDHViewController.h"
#import "FSPMLBGameTraxHotZoneView.h"
#import "FSPMLBGameTraxPlayerView.h"
#import "FSPMLBGameTraxPlayerStatsView.h"

@interface FSPMLBGameTraxViewController : UIViewController <FSPExtendedEventDetailManaging, UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UIView *playByPlayContentView;
    IBOutlet UIView *bdhContentView;
    IBOutlet UIImageView *battingLeftImageView;
    IBOutlet UIImageView *battingRightImageView;
    IBOutlet UITableView *pitchCountTableView;
    IBOutlet UILabel *mphLabel;
    IBOutlet UILabel *liveLabel;
    IBOutlet FSPMLBGameTraxHotZoneView *hotZoneView;
    IBOutlet FSPMLBGameTraxPlayerView *pitcherView;
    IBOutlet FSPMLBGameTraxPlayerView *batterView;
    IBOutlet FSPMLBGameTraxPlayerStatsView *playerStatsView;
    IBOutlet UIView *onDeckView;
    IBOutlet UIButton *hotZoneButton;
}

@property (nonatomic, retain) UIViewController <FSPExtendedEventDetailManaging> *playByPlayViewController;
@property (nonatomic, retain) FSPMLBGameTraxBDHViewController *bdhViewController;
@property (nonatomic, retain) UIView *playByPlayContentView;
@property (nonatomic, retain) UIView *bdhContentView;
@property (nonatomic, retain) UIImageView *battingLeftImageView;
@property (nonatomic, retain) UIImageView *battingRightImageView;
@property (nonatomic, retain) UITableView *pitchCountTableView;
@property (nonatomic, retain) UILabel *mphLabel;
@property (nonatomic, retain) UILabel *liveLabel;
@property (nonatomic, retain) FSPMLBGameTraxHotZoneView *hotZoneView;
@property (nonatomic, retain) FSPMLBGameTraxPlayerView *pitcherView;
@property (nonatomic, retain) FSPMLBGameTraxPlayerView *batterView;
@property (nonatomic, retain) FSPMLBGameTraxPlayerStatsView *playerStatsView;
@property (nonatomic, retain) UIView *onDeckView;
@property (nonatomic, retain) UIButton *hotZoneButton;

- (IBAction)hotZoneButtonPressed:(id)sender;

@end
