//
//  FSPUFCFightCardTableViewCell.m
//  FoxSports
//
//  Created by Pat Sluth on 2012-10-18.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPUFCFightCardTableViewCell.h"

@interface FSPUFCFightCardTableViewCell()

@property (strong, nonatomic) IBOutlet UILabel *fighterOneName;
@property (strong, nonatomic) IBOutlet UILabel *fighterTwoName;
@property (strong, nonatomic) IBOutlet UILabel *roundEndingMove;
@property (strong, nonatomic) IBOutlet UILabel *roundEndingTime;
@property (strong, nonatomic) IBOutlet UILabel *roundWeightClass;

@end

@implementation FSPUFCFightCardTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        NSArray *nibArray = [[NSBundle mainBundle]loadNibNamed:@"FSPUFCFightCardTableViewCell" owner:self options:nil];
        self = [nibArray objectAtIndex:0];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end