//
//  FSPSettingsBundleHelper.m
//  FoxSports
//
//  Created by Ed McKenzie on 9/7/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

#import "FSPSettingsBundleHelper.h"

#pragma mark - Top-level key

NSString *FSPSettingsBundleAppEnvironmentKey = @"FSPAppEnvironment";

#pragma mark - Values for FSPSettingsBundleAppEnvironmentKey

NSString *FSPSettingsBundleAppEnvironmentQA = @"FSPAppEnvironmentQA";
NSString *FSPSettingsBundleAppEnvironmentStaging = @"FSPAppEnvironmentStaging";
NSString *FSPSettingsBundleAppEnvironmentLiveEngineLiveGames = @"FSPAppEnvironmentLiveEngineLiveGames";
NSString *FSPSettingsBundleAppEnvironmentLiveEngineRecordedGames = @"FSPAppEnvironmentLiveEngineRecordedGames";
NSString *FSPSettingsBundleAppEnvironmentPenguinNHL = @"FSPAppEnvironmentPenguinNHL";
NSString *FSPSettingsBundleAppEnvironmentPenguinOther = @"FSPAppEnvironmentPenguinOther";
NSString *FSPSettingsBundleAppEnvironmentPenguinLiveEngine = @"FSPAppEnvironmentPenginLiveEngine";

#pragma mark - Keys for Environment Dictionaries
NSString *FSPSettingsBundleAppURLKey = @"FSPAppURL";
NSString *FSPSettingsBundleLiveDataURLKey = @"FSPLiveDataURL";
NSString *FSPSettingsBundleDataSchemeKey = @"FSPLiveDataURLScheme";

#pragma mark - Values for FSPSettingsBundleAppURLKey
NSString *FSPSettingsBundleAppURLQA = @"http://qa-data.foxsports.com";
NSString *FSPSettingsBundleAppURLStaging = @"http://fs.staging-data.foxsports.com";
NSString *FSPSettingsBundleAppURLPenguin = @"http://ec2-107-20-228-45.compute-1.amazonaws.com";
NSString *FSPSettingsBundleAppURLLiveEngineRecordedGames = @"http://ec2-50-112-208-200.us-west-2.compute.amazonaws.com:5555";

#pragma mark - Values for FSPSettingsBundleLiveDataURLKey
NSString *FSPSettingsBundleLiveDataURLStaticURL = @"FSPUseLiveDataStaticURL";
NSString *FSPSettingsBundleLiveDataURLLiveGames = @"http://ec2-50-112-79-9.us-west-2.compute.amazonaws.com:4567/livedata/bundle.html";
NSString *FSPSettingsBundleLiveDataURLRecordedGames = @"http://ec2-50-112-208-200.us-west-2.compute.amazonaws.com:4567/livedata/bundle.html";
NSString *FSPSettingsBundleLiveDataURLGameDictionary = @"FSPUseLiveDataGameDictionaryURL";

#pragma mark - Values for FSPSettingsBundleLiveDataURLSchemeKey

NSString *FSPSettingsBundleLiveDataURLSchemeAkamai = @"FSPUseLiveDataURLSchemeAkamai";
NSString *FSPSettingsBundleLiveDataURLSchemeNugget = @"FSPUseLiveDataURLSchemeNugget";


static NSDictionary *stagingDictionary;
static NSDictionary *qaDictionary;
static NSDictionary *liveEngineLiveGamesDictionary;
static NSDictionary *liveEngineRecordedGames;
static NSDictionary *penguinNHL;
static NSDictionary *penguinOther;
static NSDictionary *penguinLiveEngine;

@implementation FSPSettingsBundleHelper

+ (void)initialize
{
    stagingDictionary = @{ FSPSettingsBundleAppURLKey : FSPSettingsBundleAppURLStaging,
                    FSPSettingsBundleLiveDataURLKey : FSPSettingsBundleLiveDataURLGameDictionary,
                    FSPSettingsBundleDataSchemeKey : FSPSettingsBundleLiveDataURLSchemeAkamai };
    
    qaDictionary = @{ FSPSettingsBundleAppURLKey : FSPSettingsBundleAppURLQA,
                    FSPSettingsBundleLiveDataURLKey : FSPSettingsBundleLiveDataURLGameDictionary,
                    FSPSettingsBundleDataSchemeKey : FSPSettingsBundleLiveDataURLSchemeAkamai };
    
    liveEngineLiveGamesDictionary = @{ FSPSettingsBundleAppURLKey : FSPSettingsBundleAppURLStaging,
                    FSPSettingsBundleLiveDataURLKey : FSPSettingsBundleLiveDataURLLiveGames,
                    FSPSettingsBundleDataSchemeKey : FSPSettingsBundleLiveDataURLSchemeAkamai };
    
    liveEngineRecordedGames = @{ FSPSettingsBundleAppURLKey : FSPSettingsBundleAppURLLiveEngineRecordedGames,
                    FSPSettingsBundleLiveDataURLKey : FSPSettingsBundleLiveDataURLRecordedGames,
                    FSPSettingsBundleDataSchemeKey : FSPSettingsBundleLiveDataURLSchemeAkamai };
    
    penguinNHL = @{ FSPSettingsBundleAppURLKey : FSPSettingsBundleAppURLPenguin,
                    FSPSettingsBundleLiveDataURLKey : FSPSettingsBundleLiveDataURLGameDictionary,
                    FSPSettingsBundleDataSchemeKey : FSPSettingsBundleLiveDataURLSchemeNugget };
    
    penguinOther = @{ FSPSettingsBundleAppURLKey : FSPSettingsBundleAppURLPenguin,
                    FSPSettingsBundleLiveDataURLKey : FSPSettingsBundleLiveDataURLGameDictionary,
                    FSPSettingsBundleDataSchemeKey : FSPSettingsBundleLiveDataURLSchemeAkamai };
    
    penguinLiveEngine = @{ FSPSettingsBundleAppURLKey : FSPSettingsBundleAppURLPenguin,
                    FSPSettingsBundleLiveDataURLKey : FSPSettingsBundleLiveDataURLRecordedGames,
                    FSPSettingsBundleDataSchemeKey : FSPSettingsBundleLiveDataURLSchemeAkamai };
    
    [[NSUserDefaults standardUserDefaults] setValue:stagingDictionary forKey:FSPSettingsBundleAppEnvironmentStaging];
    [[NSUserDefaults standardUserDefaults] setValue:qaDictionary forKey:FSPSettingsBundleAppEnvironmentQA];
    [[NSUserDefaults standardUserDefaults] setValue:liveEngineLiveGamesDictionary forKey:FSPSettingsBundleAppEnvironmentLiveEngineLiveGames];
    [[NSUserDefaults standardUserDefaults] setValue:liveEngineRecordedGames forKey:FSPSettingsBundleAppEnvironmentLiveEngineRecordedGames];
    [[NSUserDefaults standardUserDefaults] setValue:penguinNHL forKey:FSPSettingsBundleAppEnvironmentPenguinNHL];
    [[NSUserDefaults standardUserDefaults] setValue:penguinOther forKey:FSPSettingsBundleAppEnvironmentPenguinOther];
    [[NSUserDefaults standardUserDefaults] setValue:penguinLiveEngine forKey:FSPSettingsBundleAppEnvironmentPenguinLiveEngine];
}

+ (NSString *)appEnvironmentURL
{
    NSString *appenvironmentKey = [[NSUserDefaults standardUserDefaults] valueForKey:FSPSettingsBundleAppEnvironmentKey];
    return [[[NSUserDefaults standardUserDefaults] valueForKey:appenvironmentKey] objectForKey:FSPSettingsBundleAppURLKey];
}

+ (NSString *)liveDataURL
{
    NSString *appenvironmentKey = [[NSUserDefaults standardUserDefaults] valueForKey:FSPSettingsBundleAppEnvironmentKey];
    return [[[NSUserDefaults standardUserDefaults] valueForKey:appenvironmentKey] objectForKey:FSPSettingsBundleLiveDataURLKey];
}

+ (NSString *)dataScheme
{
    NSString *appenvironmentKey = [[NSUserDefaults standardUserDefaults] valueForKey:FSPSettingsBundleAppEnvironmentKey];
    return [[[NSUserDefaults standardUserDefaults] valueForKey:appenvironmentKey] objectForKey:FSPSettingsBundleDataSchemeKey];
}
@end

