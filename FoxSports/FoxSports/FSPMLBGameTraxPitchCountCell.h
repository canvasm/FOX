//
//  FSPMLBGameTraxPitchCountCell.h
//  FoxSports
//
//  Created by Jeremy Eccles on 10/13/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSLabel.h"

@interface FSPMLBGameTraxPitchCountCell : UITableViewCell {
    IBOutlet MSLabel *callLabel;
    IBOutlet UILabel *pitchLabel;
    IBOutlet UILabel *speedLabel;
    IBOutlet UIImageView *countImageView;
}

@property (nonatomic, retain) MSLabel *callLabel;
@property (nonatomic, retain) UILabel *pitchLabel;
@property (nonatomic, retain) UILabel *speedLabel;
@property (nonatomic, retain) UIImageView *countImageView;

@end
