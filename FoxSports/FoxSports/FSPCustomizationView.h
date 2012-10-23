//
//  FSPCustomizationView.h
//  FoxSports
//
//  Created by Chase Latta on 4/26/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSPOrganization;
@protocol FSPCustomizationViewDelegate;


@interface FSPCustomizationView : UIView <UIGestureRecognizerDelegate>
@property (nonatomic, strong, readonly) FSPOrganization *organization;

@property (nonatomic, weak) id <FSPCustomizationViewDelegate> delegate;

+ (CGSize)preferedSize;

+ (id)customizationViewWithFrame:(CGRect)frame organization:(FSPOrganization *)organization;
- (id)initWithFrame:(CGRect)frame organization:(FSPOrganization *)organization;

@end


@protocol FSPCustomizationViewDelegate <NSObject>

@optional;
- (void)customizationViewWantsToShowSubOrganizations:(FSPCustomizationView *)customizationView;
- (void)customizationViewWantsToShowTeams:(FSPCustomizationView *)customizationView;

- (void)customizationView:(FSPCustomizationView *)customizationView willChangeFavoritedState:(BOOL)currentState newState:(BOOL)newState;
- (void)customizationView:(FSPCustomizationView *)customizationView didChangeFavoritedState:(BOOL)newFavoritedState;

@end