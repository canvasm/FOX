//
//  FSPSettingsBundleHelper.h
//  FoxSports
//
//  Created by Ed McKenzie on 9/7/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *FSPSettingsBundleAppEnvironmentKey;

#pragma mark - Values for FSPSettingsBundleAppEnvironmentKey

extern NSString *FSPSettingsBundleAppEnvironmentQA;
extern NSString *FSPSettingsBundleAppEnvironmentStaging;
extern NSString *FSPSettingsBundleAppEnvironmentLiveEngineLiveGames;
extern NSString *FSPSettingsBundleAppEnvironmentLiveEngineRecordedGames;
extern NSString *FSPSettingsBundleAppEnvironmentPenguinNHL;
extern NSString *FSPSettingsBundleAppEnvironmentPenguinOther;
extern NSString *FSPSettingsBundleAppEnvironmentPenguinLiveEngine;

#pragma mark - Keys for Environment Dictionaries
extern NSString *FSPSettingsBundleAppURLKey;
extern NSString *FSPSettingsBundleLiveDataURLKey;
extern NSString *FSPSettingsBundleDataSchemeKey;

#pragma mark - Values for FSPSettingsBundleAppURLKey
extern NSString *FSPSettingsBundleAppURLQA;
extern NSString *FSPSettingsBundleAppURLStaging;
extern NSString *FSPSettingsBundleAppURLPenguin;
extern NSString *FSPSettingsBundleAppURLLiveEngineRecordedGames;

#pragma mark - Values for FSPSettingsBundleLiveDataURLKey
extern NSString *FSPSettingsBundleLiveDataURLStaticURL;
extern NSString *FSPSettingsBundleLiveDataURLLiveGames;
extern NSString *FSPSettingsBundleLiveDataURLRecordedGames;
extern NSString *FSPSettingsBundleLiveDataURLGameDictionary;

#pragma mark - Values for FSPSettingsBundleLiveDataURLSchemeKey

extern NSString *FSPSettingsBundleLiveDataURLSchemeAkamai;
extern NSString *FSPSettingsBundleLiveDataURLSchemeNugget;

@interface FSPSettingsBundleHelper : NSObject

// Convenience methods to return the environmetn defaults
+ (NSString *)appEnvironmentURL;

+ (NSString *)liveDataURL;

+ (NSString *)dataScheme;


@end
