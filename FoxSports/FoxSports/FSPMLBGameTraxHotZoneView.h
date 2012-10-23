//
//  FSPMLBGameTraxHotZoneView.h
//  FoxSports
//
//  Created by Jeremy Eccles on 10/13/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSPMLBGameTraxHotZoneView : UIView {
    IBOutlet UIView *view;
    
    IBOutlet UIView *hotZone1;
    IBOutlet UIView *hotZone2;
    IBOutlet UIView *hotZone3;
    IBOutlet UIView *hotZone4;
    IBOutlet UIView *hotZone5;
    IBOutlet UIView *hotZone6;
    IBOutlet UIView *hotZone7;
    IBOutlet UIView *hotZone8;
    IBOutlet UIView *hotZone9;

    IBOutlet UILabel *hotLabel1;
    IBOutlet UILabel *hotLabel2;
    IBOutlet UILabel *hotLabel3;
    IBOutlet UILabel *hotLabel4;
    IBOutlet UILabel *hotLabel5;
    IBOutlet UILabel *hotLabel6;
    IBOutlet UILabel *hotLabel7;
    IBOutlet UILabel *hotLabel8;
    IBOutlet UILabel *hotLabel9;

    NSArray *_hotValues;
    NSArray *hotLabels;
    NSArray *hotZones;
}

@property (nonatomic, retain) UIView *view;

@property (nonatomic, retain) UIView *hotZone1;
@property (nonatomic, retain) UIView *hotZone2;
@property (nonatomic, retain) UIView *hotZone3;
@property (nonatomic, retain) UIView *hotZone4;
@property (nonatomic, retain) UIView *hotZone5;
@property (nonatomic, retain) UIView *hotZone6;
@property (nonatomic, retain) UIView *hotZone7;
@property (nonatomic, retain) UIView *hotZone8;
@property (nonatomic, retain) UIView *hotZone9;

@property (nonatomic, retain) UILabel *hotLabel1;
@property (nonatomic, retain) UILabel *hotLabel2;
@property (nonatomic, retain) UILabel *hotLabel3;
@property (nonatomic, retain) UILabel *hotLabel4;
@property (nonatomic, retain) UILabel *hotLabel5;
@property (nonatomic, retain) UILabel *hotLabel6;
@property (nonatomic, retain) UILabel *hotLabel7;
@property (nonatomic, retain) UILabel *hotLabel8;
@property (nonatomic, retain) UILabel *hotLabel9;

@property (nonatomic, retain) NSArray *_hotValues;
@property (nonatomic, retain) NSArray *hotLabels;
@property (nonatomic, retain) NSArray *hotZones;

- (void)setHotValues:(NSArray *)hotValues;
- (void)setHotLabelsHidden:(BOOL)hidden;

@end
