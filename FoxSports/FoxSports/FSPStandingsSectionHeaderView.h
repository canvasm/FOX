//
//  FSPStandingsSectionHeaderView.h
//  FoxSports
//
//  Created by Matthew Fay on 2/6/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    FSPNBAConferenceTypeNone = 0,
    FSPNBAConferenceTypeWestern,
    FSPNBAConferenceTypeEastern
} FSPNBAConferenceHeaderType;

extern CGFloat const FSPNBAStandingsConferenceSectionHeaderHeight;
extern CGFloat const FSPNBAStandingsDivisionSectionHeaderHeight;

@interface FSPStandingsSectionHeaderView : UIView

/**
 * The division name for the section; may be nil if sections are grouped by conference.
 */
@property (nonatomic, strong) NSString *divisionName;
@property (nonatomic, weak, readonly) IBOutlet UILabel *sectionNameLabel;
@property (nonatomic, strong, readonly) IBOutletCollection(UILabel) NSArray *columnHeadingLabels;

@end
