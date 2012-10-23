//
//  FSPMLBGameTraxBDHViewController.h
//  FoxSports
//
//  Created by Jeremy Eccles on 10/13/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSPMLBGameTraxBDHViewController : UIViewController {
    IBOutlet UIButton *fieldNavBaserunnersButton;
    IBOutlet UIButton *fieldNavDefenseButton;
    IBOutlet UIButton *fieldNavHitChartButton;
}

@property (nonatomic, retain) UIButton *fieldNavBaserunnersButton;
@property (nonatomic, retain) UIButton *fieldNavDefenseButton;
@property (nonatomic, retain) UIButton *fieldNavHitChartButton;

- (IBAction)fieldNavBaserunnersButtonPressed:(id)sender;
- (IBAction)fieldNavDefenseButtonPressed:(id)sender;
- (IBAction)fieldNavHitChartButtonPressed:(id)sender;

@end
