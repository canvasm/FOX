//
//  FSPNFLStandingsCell.h
//  FoxSports

#import <UIKit/UIKit.h>
#import "FSPStandingsCell.h"

@interface FSPPGAStandingsCell : FSPStandingsCell

- (void)setRank:(NSNumber *)rank;
- (void)setPlayerName:(NSString *)name;
- (void)setDetailText:(NSString *)text;

- (void)loadImageFromURL:(NSURL *)URL;

@end
