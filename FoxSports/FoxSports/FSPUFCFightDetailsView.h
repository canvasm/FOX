//
//  FSPUFCFightDetailsView.h
//  FoxSports
//
//  Created by Pat Sluth on 2012-10-17.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSPUFCFightDetailsView : UIView

typedef enum FSPUFCDamageType { Head, Body, Legs } FSPUFCDamageType;

- (void)incrementFighterDamage:(int)fighterNumber:(enum FSPUFCDamageType)damageType;
- (void)setFighterDamage:(int)newDamageValue:(int)fighterNumber:(enum FSPUFCDamageType)damageType;
@end