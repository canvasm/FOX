/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 Copyright (c) 2010, Janrain, Inc.

 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
     list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
     this list of conditions and the following disclaimer in the documentation and/or
     other materials provided with the distribution.
 * Neither the name of the Janrain, Inc. nor the names of its
     contributors may be used to endorse or promote products derived from this
     software without specific prior written permission.


 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 File:   JRSessionData.m
 Author: Lilli Szafranski - lilli@janrain.com, lillialexis@gmail.com
 Date:   Tuesday, June 1, 2010
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifdef JRDEBUG
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define DLog(...)
#define ALog(...)
#endif



#import "JRSessionData.h"

#pragma mark server_urls
//#define ENGAGE_STAGING_SERVER
//#define ENGAGE_TESTING_SERVER
//#define LOCAL_ENGAGE_SERVER
//#define NATHAN_ENGAGE_SERVER
//#define OLEG_ENGAGE_SERVER
#ifdef ENGAGE_STAGING_SERVER
static NSString * const serverUrl = @"https://rpxstaging.com";
#else
#ifdef ENGAGE_TESTING_SERVER
static NSString * const serverUrl = @"https://rpxtesting.com";
#else
#ifdef LOCAL_ENGAGE_SERVER
static NSString * const serverUrl = @"http://lilli.janrain.com:8080";
#else
#ifdef NATHAN_ENGAGE_SERVER
static NSString * const serverUrl = @"http://nathan-dev.janrain.com:8080";
#else
#ifdef OLEG_ENGAGE_SERVER
static NSString * const serverUrl = @"http://oleg.janrain.com:8080";
#else
static NSString * const serverUrl = @"https://rpxnow.com";
#endif
#endif
#endif
#endif
#endif

#pragma mark consts
/* Lists of the standard names for providers' logo and icons */
static NSString * const iconNames[5] = { @"icon_%@_30x30.png",
                                         @"icon_%@_30x30@2x.png",
                                         @"logo_%@_280x65.png",
                                         @"logo_%@_280x65@2x.png", nil };

static NSString * const iconNamesSocial[11] = { @"icon_%@_30x30.png",
                                                @"icon_%@_30x30@2x.png",
                                                @"logo_%@_280x65.png",
                                                @"logo_%@_280x65@2x.png",
                                                @"icon_bw_%@_30x30.png",
                                                @"icon_bw_%@_30x30@2x.png",
                                                @"button_%@_135x40.png",
                                                @"button_%@_135x40@2x.png",
                                                @"button_%@_280x40.png",
                                                @"button_%@_280x40@2x.png", nil };

#define cJRAuthenticatedUsersByProvider @"jrengage.sessionData.authenticatedUsersByProvider"
#define cJRAllProviders                 @"jrengage.sessionData.allProviders"
#define cJRBasicProviders               @"jrengage.sessionData.basicProviders"
#define cJRSocialProviders              @"jrengage.sessionData.socialProviders"
#define cJRIconsStillNeeded             @"jrengage.sessionData.iconsStillNeeded"
#define cJRProvidersWithIcons           @"jrengage.sessionData.providersWithIcons"
#define cJRBaseUrl                      @"jrengage.sessionData.baseUrl"
#define cJRHidePoweredBy                @"jrengage.sessionData.hidePoweredBy"
#define cJRLastUsedSocialProvider       @"jrengage.sessionData.lastUsedSocialProvider"
#define cJRLastUsedBasicProvider        @"jrengage.sessionData.lastUsedBasicProvider"

#define cJRKeychainIdentifier    @"device_tokens.janrain"

#define cJRProviderName                     @"jrengage.provider.name"
#define cJRProviderFriendlyName             @"jrengage.provider.friendlyName"
#define cJRProviderPlaceholderText          @"jrengage.provider.placeholderText"
#define cJRProviderShortText                @"jrengage.provider.shortText"
#define cJRProviderOpenIdentifier           @"jrengage.provider.openIdentifier"
#define cJRProviderUrl                      @"jrengage.provider.url"
#define cJRProviderRequiresInput            @"jrengage.provider.requiresInput"
#define cJRProviderSocialSharingProperties  @"jrengage.provider.socialSharingProperties"
#define cJRProviderCookieDomains            @"jrengage.provider.cookieDomains"

#define cJRProviderUserInput     @"jrengage.provider.%@.userInput"
#define cJRProviderForceReauth   @"jrengage.provider.%@.forceReauth"

#define cJRUserProviderName      @"provider_name"
#define cJRUserPhoto             @"photo"
#define cJRUserPreferredUsername @"preferred_username"
#define cJRUserWelcomeString     @"welcome_string"

#pragma mark helper_functions
static NSString* applicationBundleDisplayNameAndIdentifier()
{
    NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
    NSString *name = [infoPlist objectForKey:@"CFBundleDisplayName"];
    NSString *ident = [infoPlist objectForKey:@"CFBundleIdentifier"];

    return [NSString stringWithFormat:@"%@.%@", name, ident];
}

static NSString* applicationBundleDisplayName()
{
    NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
    return [infoPlist objectForKey:@"CFBundleDisplayName"];
}

#pragma mark JRError
NSString * JREngageErrorDomain = @"JREngage.ErrorDomain";

@implementation JRError
+ (NSError*)setError:(NSString*)message withCode:(NSInteger)code
{
    ALog (@"An error occured (%d): %@", code, message);
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithString:message], NSLocalizedDescriptionKey, nil];

    return [[[NSError alloc] initWithDomain:JREngageErrorDomain
                                       code:code
                                   userInfo:userInfo] autorelease];
}
@end

#pragma mark JRActivityObject ()
@implementation JRActivityObject (shortenedUrl)
- (NSString*)shortenedUrl { return _shortenedUrl; }
- (void)setShortenedUrl:(NSString*)newUrl { [newUrl retain]; [_shortenedUrl release]; _shortenedUrl = newUrl; }
@end

#pragma mark JRAuthenticatedUser
@interface JRAuthenticatedUser ()
- (id)initUserWithDictionary:(NSDictionary*)dictionary andWelcomeString:(NSString*)welcomeString forProviderNamed:(NSString*)providerName;
@end

@implementation JRAuthenticatedUser
@synthesize photo             = _photo;
@synthesize preferredUsername = _preferredUsername;
@synthesize deviceToken       = _deviceToken;
@synthesize providerName      = _providerName;
@synthesize welcomeString     = _welcomeString;

- (id)initUserWithDictionary:(NSDictionary*)dictionary andWelcomeString:(NSString*)welcomeString forProviderNamed:(NSString*)providerName
{
    if (dictionary == nil || providerName == nil || (void*)[dictionary objectForKey:@"device_token"] == kCFNull)
    {
        [self release];
        return nil;
    }

    if ((self = [super init]))
    {
        _deviceToken  = [[dictionary objectForKey:@"device_token"] retain];
        _providerName = [providerName retain];

        if ((void*)[dictionary objectForKey:@"photo"] != kCFNull)
            _photo = [[dictionary objectForKey:@"photo"] retain];

        if ((void*)[dictionary objectForKey:@"preferred_username"] != kCFNull)
            _preferredUsername = [[dictionary objectForKey:@"preferred_username"] retain];

        if (welcomeString && ![welcomeString isEqualToString:@""])
            _welcomeString = [welcomeString retain];
        else
            _welcomeString = [[NSString stringWithFormat:@"Sign in as %@?", _preferredUsername] retain];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeObject:_providerName      forKey:cJRUserProviderName];
    [coder encodeObject:_photo             forKey:cJRUserPhoto];
    [coder encodeObject:_preferredUsername forKey:cJRUserPreferredUsername];
    [coder encodeObject:_welcomeString     forKey:cJRUserWelcomeString];

    [coder encodeObject:nil forKey:@"device_token"];

    NSError *error = nil;
    [SFHFKeychainUtils storeUsername:_providerName
                         andPassword:_deviceToken
                      forServiceName:[NSString stringWithFormat:@"%@.%@.",
                                      cJRKeychainIdentifier,
                                      applicationBundleDisplayNameAndIdentifier()]
                      updateExisting:YES
                               error:&error];

    if (error)
        ALog (@"Error storing device token in keychain: %@", [error localizedDescription]);
}

- (id)initWithCoder:(NSCoder*)coder
{
    if (self != nil)
    {
        _providerName      = [[coder decodeObjectForKey:cJRUserProviderName] retain];
        _photo             = [[coder decodeObjectForKey:cJRUserPhoto] retain];
        _preferredUsername = [[coder decodeObjectForKey:cJRUserPreferredUsername] retain];
        _welcomeString     = [[coder decodeObjectForKey:cJRUserWelcomeString] retain];

        if (!_welcomeString)
            _welcomeString = [[NSString stringWithFormat:@"Sign in as %@?", _preferredUsername] retain];

        NSError *error = nil;
        _deviceToken = [[SFHFKeychainUtils getPasswordForUsername:_providerName
                                                   andServiceName:[NSString stringWithFormat:@"%@.%@.",
                                                                   cJRKeychainIdentifier,
                                                                   applicationBundleDisplayNameAndIdentifier()]
                                                            error:&error] retain];

        if (error)
            ALog (@"Error retrieving device token in keychain: %@", [error localizedDescription]);

        /* For backwards compatibility */
        if (!_deviceToken)
            _deviceToken = [[coder decodeObjectForKey:@"device_token"] retain];
    }

//    if (!_providerName)
//        [self release], self = nil;

    return self;
}

- (void)removeDeviceTokenFromKeychain
{
    NSError *error = nil;
    [SFHFKeychainUtils deleteItemForUsername:_providerName
                              andServiceName:[NSString stringWithFormat:@"%@.%@.", cJRKeychainIdentifier, applicationBundleDisplayNameAndIdentifier()]
                                       error:&error];
    if (error)
        ALog (@"Error deleting device token from keychain: %@", [error localizedDescription]);
}

- (void)dealloc
{
    // Question to self: Are we ever going to be leaking these?  Assuming correct retain counting,
    // these should dealloc when the user is signed out.
    [self removeDeviceTokenFromKeychain];

    DLog (@"");

    [_providerName release];
    [_photo release];
    [_preferredUsername release];
    [_deviceToken release];
    [_welcomeString release];

    [super dealloc];
}
@end

#pragma mark JRProvider
@interface JRProvider ()
@property (readonly) BOOL      social;
@property (readonly) NSString *openIdentifier;
@property (readonly) NSString *url;
- (JRProvider*)initWithName:(NSString*)name andDictionary:(NSDictionary*)dictionary;
@end

@implementation JRProvider
@synthesize name                    = _name;
@synthesize friendlyName            = _friendlyName;
@synthesize placeholderText         = _placeholderText;
@synthesize openIdentifier          = _openIdentifier;
@synthesize url                     = _url;
@synthesize requiresInput           = _requiresInput;
@synthesize shortText               = _shortText;
@synthesize socialSharingProperties = _socialSharingProperties;
@synthesize social                  = _social;
@synthesize cookieDomains           = _cookieDomains;

- (NSString*)userInput { return _userInput; }
- (void)setUserInput:(NSString*)userInput
{
    [userInput retain], [_userInput release];
    _userInput = userInput;

 /* Save our dynamic variables, in case we ever need to re-initialize a provider object, the init... functions can pull these
    from the user defaults. */
    [[NSUserDefaults standardUserDefaults] setValue:_userInput
                                             forKey:[NSString stringWithFormat:cJRProviderUserInput, self.name]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)forceReauth { return _forceReauth; }
- (void)setForceReauth:(BOOL)forceReauth
{
    _forceReauth = forceReauth;

 /* Save our dynamic variables, in case we ever need to re-initialize a provider object, the init... functions can pull these
    from the user defaults. */
    [[NSUserDefaults standardUserDefaults] setBool:_forceReauth
                                            forKey:[NSString stringWithFormat:cJRProviderForceReauth, self.name]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/* For a number of reasons, we may need to reload the configuration information for our providers.  Because these variables
   are dynamic (i.e., not returned in the block of configuration code), we need to save them elsewhere and call them by our
   init... functions. */
- (void)loadDynamicVariables
{
    _userInput     = [[[NSUserDefaults standardUserDefaults]
                       stringForKey:[NSString stringWithFormat:cJRProviderUserInput, _name]] retain];
    _forceReauth   =  [[NSUserDefaults standardUserDefaults]
                       boolForKey:[NSString stringWithFormat:cJRProviderForceReauth, _name]];
}

- (JRProvider*)initWithName:(NSString*)name andDictionary:(NSDictionary*)dictionary
{
    DLog (@"New Provider: %@", name);

    if (name == nil || name.length == 0 || dictionary == nil)
    {
        [self release];
        return nil;
    }

    if ((self = [super init]))
    {
        _name = [name retain];

        _friendlyName    = [[dictionary objectForKey:@"friendly_name"] retain];
        _placeholderText = [[dictionary objectForKey:@"input_prompt"] retain];
        _openIdentifier  = [[dictionary objectForKey:@"openid_identifier"] retain];
        _url             = [[dictionary objectForKey:@"url"] retain];
        _cookieDomains   = [[dictionary objectForKey:@"cookie_domains"] retain];

        if ([[dictionary objectForKey:@"requires_input"] isEqualToString:@"YES"])
            _requiresInput = YES;

        if (_requiresInput)
        {
            NSArray *arr    = [[self.placeholderText stringByTrimmingCharactersInSet:
                                    [NSCharacterSet whitespaceCharacterSet]]
                                        componentsSeparatedByString:@" "];
            NSRange  subArr = {[arr count] - 2, 2};
            NSArray *newArr = [arr subarrayWithRange:subArr];

            _shortText = [[newArr componentsJoinedByString:@" "] retain];
        }
        else
        {
            _shortText = @"";
        }

        _socialSharingProperties = [[dictionary objectForKey:@"social_sharing_properties"] retain];

        if ([_socialSharingProperties count])
            _social = YES;

        [self loadDynamicVariables];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeObject:_name                    forKey:cJRProviderName];
    [coder encodeObject:_friendlyName            forKey:cJRProviderFriendlyName];
    [coder encodeObject:_placeholderText         forKey:cJRProviderPlaceholderText];
    [coder encodeObject:_shortText               forKey:cJRProviderShortText];
    [coder encodeObject:_openIdentifier          forKey:cJRProviderOpenIdentifier];
    [coder encodeObject:_url                     forKey:cJRProviderUrl];
    [coder encodeBool:_requiresInput             forKey:cJRProviderRequiresInput];
    [coder encodeObject:_socialSharingProperties forKey:cJRProviderSocialSharingProperties];
    [coder encodeObject:_cookieDomains           forKey:cJRProviderCookieDomains];
}

- (id)initWithCoder:(NSCoder*)coder
{
    if (self != nil)
    {
        _name                    = [[coder decodeObjectForKey:cJRProviderName] retain];
        _friendlyName            = [[coder decodeObjectForKey:cJRProviderFriendlyName] retain];
        _placeholderText         = [[coder decodeObjectForKey:cJRProviderPlaceholderText] retain];
        _shortText               = [[coder decodeObjectForKey:cJRProviderShortText] retain];
        _openIdentifier          = [[coder decodeObjectForKey:cJRProviderOpenIdentifier] retain];
        _url                     = [[coder decodeObjectForKey:cJRProviderUrl] retain];
        _requiresInput           =  [coder decodeBoolForKey:  cJRProviderRequiresInput];
        _socialSharingProperties = [[coder decodeObjectForKey:cJRProviderSocialSharingProperties] retain];
        _cookieDomains           = [[coder decodeObjectForKey:cJRProviderCookieDomains] retain];
    }
    [self loadDynamicVariables];

    return self;
}

- (BOOL)isEqualToReturningProvider:(NSString*)returningProvider
{
    if ([self.name isEqualToString:returningProvider])
        return YES;
    return NO;
}

- (void)dealloc
{
    [_name release];
    [_friendlyName release];
    [_placeholderText release];
    [_shortText release];
    [_openIdentifier release];
    [_url release];
    [_userInput release];
    [_socialSharingProperties release];
    [_cookieDomains release];

    [super dealloc];
}
@end

#pragma mark JRSessionData
@interface JRSessionData ()
@property (copy)   NSString *appId;
@property (retain) NSError  *error;
@property (retain) NSString *updatedEtag;
@property (retain) NSString *gitCommit;
@property (retain) NSString *savedConfigurationBlock;
- (NSError*)startGetConfiguration;
- (NSError*)finishGetConfiguration:(NSString*)dataStr;
- (void)startGetShortenedUrlsForActivity:(JRActivityObject*)theActivity;
@end

@implementation JRSessionData
@synthesize appId;
@synthesize tokenUrl;
@synthesize allProviders;
@synthesize basicProviders;
@synthesize socialProviders;
@synthesize currentProvider;
@synthesize returningSocialProvider;
@synthesize baseUrl;
@synthesize authenticatingDirectlyOnThisProvider;
@synthesize alwaysForceReauth;
@synthesize forceReauthJustThisTime;
@synthesize socialSharing;
@synthesize hidePoweredBy;
@synthesize error;
@synthesize updatedEtag;
@synthesize gitCommit;
@synthesize savedConfigurationBlock;
@synthesize canRotate;

#pragma mark singleton_methods
static JRSessionData* singleton = nil;
+ (JRSessionData*)jrSessionData
{
    return singleton;
}

+ (id)allocWithZone:(NSZone*)zone
{
    return [[self jrSessionData] retain];
}

- (id)copyWithZone:(NSZone*)zone
{
    return self;
}

- (id)retain                { return self; }
- (NSUInteger)retainCount   { return NSUIntegerMax; }
- (oneway void)release      { /* Do nothing... */ }
- (id)autorelease           { return self; }

#pragma mark accessors
- (NSString*)returningBasicProvider
{
// /* This is here so that when a calling application sets skipReturningUserLandingPage, the dialog always opens
//    to the providers list, and never opens to the returning user landing page. */
//    if (skipReturningUserLandingPage)
//        return nil;

    return returningBasicProvider;
}

- (BOOL)dialogIsShowing
{
    return dialogIsShowing;
}

- (void)setDialogIsShowing:(BOOL)isShowing
{/* If we found out that the configuration changed while a dialog was showing, we saved it until the dialog wasn't showing
    since the dialogs dynamically load our data. Now that the dialog isn't showing, load the saved configuration information. */
    if (!isShowing && savedConfigurationBlock)
        self.error = [self finishGetConfiguration:savedConfigurationBlock];

 /* If the dialog is going away, then we don't still need to shorten the urls */
    if (!isShowing)
        stillNeedToShortenUrls = NO;

    dialogIsShowing = isShowing;
}

- (JRActivityObject*)activity { return activity; }
- (void)setActivity:(JRActivityObject*)newActivity
{
    JRActivityObject *oldActivity = activity;
    activity = [newActivity copy];
    [oldActivity release];

    if (!activity)
        return;

    [self startGetShortenedUrlsForActivity:activity];
}

#pragma mark initialization
- (id)reconfigureWithAppId:(NSString*)newAppId tokenUrl:(NSString*)newTokenUrl
{
    self.appId = newAppId;
    self.tokenUrl = newTokenUrl;
    self.error = [self startGetConfiguration];

    return self;
}

- (id)initWithAppId:(NSString*)newAppId tokenUrl:(NSString*)newTokenUrl andDelegate:(id<JRSessionDelegate>)newDelegate
{
    DLog (@"");

    if ((self = [super init]))
    {
        singleton = self;

        delegates     = [[NSMutableArray alloc] initWithObjects:newDelegate, nil];
        self.appId    = newAppId;
        self.tokenUrl = newTokenUrl;

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            device = @"ipad";
        else
            device = @"iphone";

        /* First, we load all of the cached data (the list of providers, saved users, base url, etc.) */

        /* Load the dictionary of authenticated users */
        NSData *archivedUsers = [[NSUserDefaults standardUserDefaults] objectForKey:cJRAuthenticatedUsersByProvider];
        if (archivedUsers != nil)
        {
            NSDictionary *unarchivedUsers = [NSKeyedUnarchiver unarchiveObjectWithData:archivedUsers];
            if (unarchivedUsers != nil)
                authenticatedUsersByProvider = [[NSMutableDictionary alloc] initWithDictionary:unarchivedUsers];
        }

        /* And if there weren't any saved users, init the dictionary */
        if (!authenticatedUsersByProvider)
            authenticatedUsersByProvider = [[NSMutableDictionary alloc] initWithCapacity:1];

        /* Load the list of all providers */
        NSData *archivedProviders = [[NSUserDefaults standardUserDefaults] objectForKey:cJRAllProviders];
        if (archivedProviders != nil)
        {
            NSDictionary *unarchivedProviders = [NSKeyedUnarchiver unarchiveObjectWithData:archivedProviders];
            if (unarchivedProviders != nil)
                allProviders = [[NSMutableDictionary alloc] initWithDictionary:unarchivedProviders];
        }

        /* Load the list of basic providers */
        basicProviders = [[[NSUserDefaults standardUserDefaults] objectForKey:cJRBasicProviders] retain];

        /* Load the list of social providers */
        socialProviders = [[[NSUserDefaults standardUserDefaults] objectForKey:cJRSocialProviders] retain];

        /* Load the list of icons that the library should re-attempt to download, in case previous attempts failed for whatever reason */
        NSData *archivedIconsStillNeeded = [[NSUserDefaults standardUserDefaults] objectForKey:cJRIconsStillNeeded];
        if (archivedIconsStillNeeded != nil)
        {
            NSDictionary *unarchivedIconsStillNeeded = [NSKeyedUnarchiver unarchiveObjectWithData:archivedIconsStillNeeded];
            if (unarchivedIconsStillNeeded != nil)
                iconsStillNeeded = [[NSMutableDictionary alloc] initWithDictionary:unarchivedIconsStillNeeded];
        }

        /* Load the set of providers that already have all of their icons; checking this list is faster than checking for the icons themselves */
        NSData *archivedProvidersWithIcons = [[NSUserDefaults standardUserDefaults] objectForKey:cJRProvidersWithIcons];
        if (archivedProvidersWithIcons != nil)
        {
            NSSet *unarchivedProvidersWithIcons = [NSKeyedUnarchiver unarchiveObjectWithData:archivedProvidersWithIcons];
            if (unarchivedProvidersWithIcons != nil)
                providersWithIcons = [[NSMutableSet alloc] initWithSet:unarchivedProvidersWithIcons];
        }

        /* Load the base url and whether or not we need to hide the tagline */
        baseUrl = [[[NSUserDefaults standardUserDefaults] stringForKey:cJRBaseUrl] retain];
        if (!baseUrl) /* The we assume this is the first time running the library ever */
            hidePoweredBy = YES; /* And say that hidePoweredBy is 'YES' for our Pro/Enterprise customers */
        else
            hidePoweredBy = [[NSUserDefaults standardUserDefaults] boolForKey:cJRHidePoweredBy];

        /* And load the last used basic and social providers */
        returningSocialProvider = [[[NSUserDefaults standardUserDefaults] stringForKey:cJRLastUsedSocialProvider] retain];
        returningBasicProvider = [[[NSUserDefaults standardUserDefaults] stringForKey:cJRLastUsedBasicProvider] retain];

        /* As this information may have changed, we're going to ask rpx for this information anyway */
        self.error = [self startGetConfiguration];
    }

    return self;
}

+ (id)jrSessionDataWithAppId:(NSString*)newAppId tokenUrl:(NSString*)newTokenUrl andDelegate:(id<JRSessionDelegate>)newDelegate
{
    if(singleton)
        return [singleton reconfigureWithAppId:newAppId tokenUrl:newTokenUrl];

    return [[((JRSessionData*)[super allocWithZone:nil]) initWithAppId:newAppId tokenUrl:newTokenUrl andDelegate:newDelegate] autorelease];
}

- (void)tryToReconfigureLibrary
{
    ALog (@"Configuration error occurred. Trying to reconfigure the library.");

    self.error = [self startGetConfiguration];
}

#pragma mark dynamic_icon_handling
- (void)finishDownloadPicture:(NSData*)picture named:(NSString*)pictureName forProvider:(NSString*)provider
{
    DLog (@"Downloaded %@ for %@", pictureName, provider);

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:pictureName];
    [fileManager createFileAtPath:path contents:picture attributes:nil];

    NSMutableSet *iconsForProvider = [iconsStillNeeded objectForKey:provider];
    [iconsForProvider removeObject:pictureName];

    if ([iconsForProvider count] == 0)
    {
        [iconsStillNeeded removeObjectForKey:provider];
        [providersWithIcons addObject:provider];
    }

    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:iconsStillNeeded]
                                              forKey:cJRIconsStillNeeded];
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:providersWithIcons]
                                              forKey:cJRProvidersWithIcons];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)startDownloadPicture:(NSString*)picture forProvider:(NSString*)provider
{
    NSString *urlString = [NSString stringWithFormat:
                           @"%@/cdn/images/mobile_icons/%@/%@",
                           serverUrl, device, picture];

    DLog (@"Attempting to download icon for %@: %@", provider, urlString);

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];

    NSDictionary *tag = [[NSDictionary alloc] initWithObjectsAndKeys:picture, @"pictureName",
                         provider, @"providerName",
                         @"downloadPicture", @"action", nil];

    [JRConnectionManager createConnectionFromRequest:request forDelegate:self returnFullResponse:YES withTag:tag];
}

/* Download any icons that need to be downloaded */
- (void)downloadAnyIcons:(NSMutableDictionary*)neededIcons
{
    DLog ("Icons that are still needed:\n%@", [iconsStillNeeded description]);

    for (NSString *provider in [neededIcons allKeys])
    {
        NSMutableSet *icons = [neededIcons objectForKey:provider];
        for (NSString *icon in [icons allObjects])
        {
            [self startDownloadPicture:icon forProvider:provider];
        }
    }
}

- (void)checkForIcons:(NSString**)icons forProvider:(NSString*)providerName
{
//    DLog ("Checking providersWithIcons for %@:\n%@", providerName, [providersWithIcons description]);
//    DLog ("Icons needed so far:\n%@", [iconsStillNeeded description]);

 /* If we've already found this provider's icons, they should be in this list; just return. */
    if ([providersWithIcons containsObject:providerName])
        return;

 /* If the provider isn't in the list, either the provider's icons need to be downloaded or this is
    the first time this code was run (and no providers have been added to providersWithIcons yet).
    If it's the latter, both these saved lists will probably be nil, so init them. */
    if (!providersWithIcons)
        providersWithIcons = [[NSMutableSet alloc] initWithCapacity:4];

    if (!iconsStillNeeded)
        iconsStillNeeded = [[NSMutableDictionary alloc] initWithCapacity:4];

    NSMutableSet *iconsNeeded = [NSMutableSet setWithCapacity:4];

 /* Iterate our static arrays of standard image names, insert the provider name, and check if they're there */
    for (int i = 0; icons[i]; i++)
    {
        if (![UIImage imageNamed:[NSString stringWithFormat:icons[i], providerName]])
            [iconsNeeded addObject:[NSString stringWithFormat:icons[i], providerName]];
        else
            DLog ("Found icon: %@", [NSString stringWithFormat:icons[i], providerName]);
    }

    if ([iconsNeeded count]) /* And if there are icons that aren't there, add them to the list of icons */
        [iconsStillNeeded setObject:iconsNeeded forKey:providerName];   /*  that need to be downloaded. */
    else /* Otherwise, add the provider to the providersWithIcons list so that we can check these much  */
        [providersWithIcons addObject:providerName];                    /* quicker next time.           */
}

#pragma mark configuration
- (NSString*)appNameAndVersion
{   // TODO: Redo this
    NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
    NSString     *name      = [[[infoPlist objectForKey:@"CFBundleDisplayName"]
                                stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] URLEscaped];
    NSString     *ident     = [[[infoPlist objectForKey:@"CFBundleIdentifier"]
                                stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] URLEscaped];

    infoPlist = [NSDictionary dictionaryWithContentsOfFile:
                 [[[NSBundle mainBundle] resourcePath]
                  stringByAppendingPathComponent:@"/JREngage-Info.plist"]];

    NSString *version       = [[[infoPlist objectForKey:@"CFBundleShortVersionString"]
                                stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] URLEscaped];

    return [NSString stringWithFormat:@"appName=%@.%@3&version=%@_%@", name, ident, device, version];
}

- (NSError*)startGetConfiguration
{
    NSString *nameAndVersion = [self appNameAndVersion];
    NSString *urlString = [NSString stringWithFormat:
                           @"%@/openid/mobile_config_and_baseurl?device=%@&appId=%@&%@",
                           serverUrl, device, appId, nameAndVersion];

    ALog (@"Getting configuration for RP: %@", urlString);

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];

    NSString *tag = [[NSString alloc] initWithFormat:@"getConfiguration"];

    if (![JRConnectionManager createConnectionFromRequest:request forDelegate:self returnFullResponse:YES withTag:tag])
        return [JRError setError:@"There was a problem connecting to the Janrain server while configuring authentication."
                        withCode:JRUrlError];
    return nil;
}

- (NSError*)finishGetConfiguration:(NSString*)dataStr
{
    ALog (@"Configuration information needs to be updated.");

    NSDictionary *jsonDict = (NSDictionary*)[dataStr objectFromJSONString];

    /* Double-check the return value */
    if (!jsonDict)
    {
        DLog(@"%@", dataStr);
        return [JRError setError:@"There was a problem communicating with the Janrain server while configuring authentication."
                        withCode:JRJsonError];
    }

    if (![jsonDict objectForKey:@"baseurl"] || ![jsonDict objectForKey:@"provider_info"])
    {
        DLog(@"%@", dataStr);
        return [JRError setError:@"There was a problem communicating with the Janrain server while configuring authentication."
                        withCode:JRConfigurationInformationError];
    }

    [baseUrl release];
    baseUrl = [[[jsonDict objectForKey:@"baseurl"]
                stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]] retain];

    if (stillNeedToShortenUrls && activity)
        [self startGetShortenedUrlsForActivity:activity];
    stillNeedToShortenUrls = NO;

    /* Then save it */
    [[NSUserDefaults standardUserDefaults] setValue:baseUrl forKey:cJRBaseUrl];

    /* Get the providers out of the provider_info section.  These are most likely to have changed. */
    NSDictionary *providerInfo   = [NSDictionary dictionaryWithDictionary:[jsonDict objectForKey:@"provider_info"]];

    [allProviders release];
    allProviders = [[NSMutableDictionary alloc] initWithCapacity:[[providerInfo allKeys] count]];

    /* For each provider... */
    for (NSString *name in [providerInfo allKeys])
    {   /* Get its dictionary, */
        NSDictionary *dictionary = [providerInfo objectForKey:name];

        /* use this to create a provider object, */
        JRProvider *provider = [[[JRProvider alloc] initWithName:name
                                                   andDictionary:dictionary] autorelease];

        /* make sure we have this provider's icons, */
        [self checkForIcons:((provider.social) ? (NSString**)&iconNamesSocial : (NSString**)&iconNames) forProvider:name];

        /* and finally add the object to our dictionary of providers. */
        [allProviders setObject:provider forKey:name];
    }

    /* Save these now, in case the downloading of the icons gets interrupted for any reason */
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:iconsStillNeeded]
                                              forKey:cJRIconsStillNeeded];
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:providersWithIcons]
                                              forKey:cJRProvidersWithIcons];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [basicProviders release];
    [socialProviders release];

    /* Get the ordered list of basic providers */
    basicProviders = [[NSArray arrayWithArray:[jsonDict objectForKey:@"enabled_providers"]] retain];

    /* Get the ordered list of social providers */
    socialProviders = [[NSArray arrayWithArray:[jsonDict objectForKey:@"social_providers"]] retain];

    /* yippie, yahoo! */

    /* Then save our stuff */
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:allProviders]
                                              forKey:cJRAllProviders];
    [[NSUserDefaults standardUserDefaults] setObject:basicProviders forKey:cJRBasicProviders];
    [[NSUserDefaults standardUserDefaults] setObject:socialProviders forKey:cJRSocialProviders];

    /* Figure out if we need to hide the tag line */
    if ([[jsonDict objectForKey:@"hide_tagline"] isEqualToString:@"YES"])
        hidePoweredBy = YES;
    else
        hidePoweredBy = NO;

    /* And finally, save that too */
    [[NSUserDefaults standardUserDefaults] setBool:hidePoweredBy forKey:cJRHidePoweredBy];

    /* Once we know that everything is parsed and saved correctly, save the new etag */
    [[NSUserDefaults standardUserDefaults] setValue:updatedEtag forKey:@"jrengage.sessionData.configurationEtag"];

    [[NSUserDefaults standardUserDefaults] setValue:gitCommit forKey:@"jrengage.sessionData.engageCommit"];

    [[NSUserDefaults standardUserDefaults] synchronize];

    /* Now, download any missing icons */
    [self downloadAnyIcons:iconsStillNeeded];

    /* Then nullify our saved configuration information */
    self.savedConfigurationBlock = nil;
    self.updatedEtag = nil;

    return nil;
}

- (NSError*)finishGetConfiguration:(NSString*)dataStr withEtag:(NSString*)etag
{
    ALog (@"Configuration information downloaded: %@", dataStr);

    NSDictionary *infoPlist = [NSDictionary dictionaryWithContentsOfFile:
                               [[[NSBundle mainBundle] resourcePath]
                                stringByAppendingPathComponent:@"/JREngage-Info.plist"]];

    NSString *currentCommit = [infoPlist objectForKey:@"JREngage.GitCommit"];
    NSString *savedCommit = [[NSUserDefaults standardUserDefaults] stringForKey:@"jrengage.sessionData.engageCommit"];

    NSString *oldEtag = [[NSUserDefaults standardUserDefaults] stringForKey:@"jrengage.sessionData.configurationEtag"];

 /* If the downloaded configuration for this RP has changed, the http://mobile_config... URL's etag will have changed, and we need
    to update our current configuration information.  Or, any time the JREngage library's code has been changed and committed,
    the JREngage.GitCommit property in the JREngage-Info.plist will have changed to reflect the current commit.  Since code changes
    may affect the objects that get synchronized, we need to update our current configuration information when this occurs as well.
    We test for both of these cases by saving the last etag and commit string, and comparing the saved value to the current value.
    Almost always, these will be the same, and we are safe using our cached configuration data.  Lastly, if we are testing changes
    in the synchronization code, we can temporarily set the currentCommit (JREngage.GitCommit) to "1", forcing library to reconfigure
    itself every time. */
    if (![oldEtag isEqualToString:etag] || ![currentCommit isEqualToString:savedCommit] || [currentCommit isEqualToString:@"1"])
    {
        self.updatedEtag = etag;
        self.gitCommit = currentCommit;

     /* We can only update all of our data if the UI isn't currently using that information.  Otherwise, the library may
        crash/behave inconsistently.  If a dialog isn't showing, go ahead and update new configuration information.

        Or, in rare cases, there might not be any data at all (the lists of basic and social providers are nil), perhaps
        because this is the first time the library was used and the configuration information is still downloading.
        In these cases, the dialogs will display their view as greyed-out, with a spinning activity indicator and a
        loading message, as they wait for the lists of providers to download, so we can go ahead and update the
        configuration information here, too. The dialogs won't try and do anything until we're done updating the lists. */
        if (!dialogIsShowing)
            return [self finishGetConfiguration:dataStr];
        if ([basicProviders count] == 0 && !socialSharing)
            return [self finishGetConfiguration:dataStr];
        if ([socialProviders count] == 0 && socialSharing)
            return [self finishGetConfiguration:dataStr];

     /* Otherwise, we have to save all this information for later.  The UserInterfaceMaestro sends a
        signal to sessionData when the dialog closes (by setting the boolean dialogIsShowing to "NO".
        In the setter function, sessionData checks to see if there's anything stored in the
        savedConfigurationBlock, and updates it then. */
        self.savedConfigurationBlock = dataStr;
    }
    else
    {/* Even if we don't reconfigure, there may be icons that we still need to download.
        (This is also called at the end of the finishGetConfiguration method.) */
        [self downloadAnyIcons:iconsStillNeeded];
    }

    return nil;
}

#pragma mark user_management
- (BOOL)weShouldBeFirstResponder
{
 /* If we're authenticating with a provider for social publishing, then don't worry about the return experience for basic authentication. */
    if (socialSharing)
        return currentProvider.requiresInput;

 /* If we're authenticating with a basic provider, then we don't need to gather information if we're displaying return screen. */
    if ([currentProvider isEqualToReturningProvider:returningBasicProvider])
        return NO;

    return currentProvider.requiresInput;
}

- (JRAuthenticatedUser*)authenticatedUserForProvider:(JRProvider*)provider
{
    return [authenticatedUsersByProvider objectForKey:provider.name];
}

- (JRAuthenticatedUser*)authenticatedUserForProviderNamed:(NSString*)provider;
{
    return [authenticatedUsersByProvider objectForKey:provider];
}

- (void)forgetAuthenticatedUserForProvider:(NSString*)providerName
{
    DLog (@"");

 /* If you are explicitly signing out a user for a provider, you should explicitly force reauthentication. */
    JRProvider* provider = [allProviders objectForKey:providerName];
    provider.forceReauth = YES;

    [authenticatedUsersByProvider removeObjectForKey:providerName];
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:authenticatedUsersByProvider]
                                              forKey:cJRAuthenticatedUsersByProvider];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)forgetAllAuthenticatedUsers
{
    DLog (@"");

    for (NSString *providerName in [allProviders allKeys])
    {
        JRProvider *provider = [allProviders objectForKey:providerName];
        provider.forceReauth = YES;
    }

    [authenticatedUsersByProvider removeAllObjects];
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:authenticatedUsersByProvider]
                                              forKey:cJRAuthenticatedUsersByProvider];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark provider_management
- (JRProvider*)getProviderAtIndex:(NSUInteger)index fromArray:(NSArray*)array
{
    if (index < [array count])
    {
        return [allProviders objectForKey:[array objectAtIndex:index]];
    }

    return nil;
}

- (JRProvider*)getBasicProviderAtIndex:(NSUInteger)index
{
    return [self getProviderAtIndex:index fromArray:[self basicProviders]];
}

- (JRProvider*)getSocialProviderAtIndex:(NSUInteger)index
{
    return [self getProviderAtIndex:index fromArray:[self socialProviders]];
}

- (JRProvider*)getProviderNamed:(NSString*)name
{
    return [allProviders objectForKey:name];
}

#pragma mark authentication
- (void)saveLastUsedSocialProvider:(NSString*)providerName
{
    DLog (@"Saving last used social provider: %@", providerName);

    [returningSocialProvider release], returningSocialProvider = [providerName retain];

    [[NSUserDefaults standardUserDefaults] setObject:returningSocialProvider
                                              forKey:cJRLastUsedSocialProvider];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveLastUsedBasicProvider:(NSString*)providerName
{
    DLog (@"Saving last used basic provider: %@", providerName);

    [returningBasicProvider release], returningBasicProvider = [providerName retain];

    [[NSUserDefaults standardUserDefaults] setObject:returningBasicProvider
                                              forKey:cJRLastUsedBasicProvider];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setReturningBasicProviderToNil;
{
    [returningBasicProvider release];
    returningBasicProvider = nil;
}

- (NSString*)getWelcomeMessageFromCookie
{
    DLog (@"");

    // TODO: See about re-adding cookie code that manually sets the last used provider and see
    // if that means using rpx to log into site through Safari browser will also remember the user/provider

    NSHTTPCookieStorage *cookieStore = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookieStore cookiesForURL:[NSURL URLWithString:baseUrl]];

    for (NSHTTPCookie *savedCookie in cookies)
    {
        if ([savedCookie.name isEqualToString:@"welcome_info"])
        {
            NSString *cookieString = savedCookie.value;
            NSArray *strArr = [cookieString componentsSeparatedByString:@"%22"];

            if ([strArr count] <= 1)
                return nil;

            return [[[NSString stringWithFormat:@"Sign in as %@?", (NSString*)[strArr objectAtIndex:5]]
                     stringByReplacingOccurrencesOfString:@"+" withString:@" "]
                        stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
    }

    return nil;
}

- (void)deleteWebviewCookiesForDomains:(NSArray*)domains
{
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];

    NSArray* cookiesWithDomain;
    for (NSString *domain in domains)
    {
        /* http:// */
        cookiesWithDomain = [cookies cookiesForURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@", domain]]];
        for (NSHTTPCookie* cookie in cookiesWithDomain)
            [cookies deleteCookie:cookie];

        /* https:// */
        cookiesWithDomain = [cookies cookiesForURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://%@", domain]]];
        for (NSHTTPCookie* cookie in cookiesWithDomain)
            [cookies deleteCookie:cookie];
    }
}

- (void)deleteFacebookCookies
{
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* facebookCookies = [cookies cookiesForURL:[NSURL URLWithString:@"http://login.facebook.com"]];

    for (NSHTTPCookie* cookie in facebookCookies)
    {
        [cookies deleteCookie:cookie];
    }
}

- (void)deleteLiveCookies
{
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* liveCookies = [cookies cookiesForURL:[NSURL URLWithString:@"http://live.com"]];

    for (NSHTTPCookie* cookie in liveCookies)
    {
        [cookies deleteCookie:cookie];
    }
}

- (NSURL*)startUrlForCurrentProvider
{
    NSMutableString *oid;

    if (!currentProvider)
        return nil;

    if (currentProvider.openIdentifier)
    {
        oid = [NSMutableString stringWithFormat:@"openid_identifier=%@&", currentProvider.openIdentifier];

        if(currentProvider.requiresInput)
            [oid replaceOccurrencesOfString:@"%@"
                                 withString:[currentProvider.userInput
                                             stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                    options:NSLiteralSearch
                                      range:NSMakeRange(0, [oid length])];
    }
    else
    {
        oid = [NSMutableString stringWithString:@""];
    }

    NSString *str = nil;

    BOOL weNeedToForceReauth = (alwaysForceReauth ||
                                currentProvider.forceReauth ||
                                authenticatingDirectlyOnThisProvider ||
                                ![self authenticatedUserForProvider:currentProvider])
    ? YES : NO;

    // TODO: currentProvider => currentlyAuthenticatingProvider
    if (weNeedToForceReauth)
        [self deleteWebviewCookiesForDomains:currentProvider.cookieDomains];

    str = [NSString stringWithFormat:@"%@%@?%@%@device=%@&extended=true",
           baseUrl,
           currentProvider.url,
           oid,
           weNeedToForceReauth ? @"force_reauth=true&" : @"",
           device];

    currentProvider.forceReauth = NO;

    ALog (@"Starting authentication for %@:\n%@", currentProvider.name, str);
    return [NSURL URLWithString:str];
}

#pragma mark sharing
- (void)startShareActivityForUser:(JRAuthenticatedUser*)user
{
    // TODO: Better error checking in sessionData's share activity bit
    NSMutableDictionary *activityDictionary = [activity dictionaryForObject];

    if ([currentProvider.name isEqualToString:@"linkedin"])
    {
        [activityDictionary setObject:
                [[activity.resourceDescription substringToIndex:((activity.resourceDescription.length < 256) ?
                                                                  activity.resourceDescription.length : 256)] URLEscaped]
                               forKey:@"description"];
    }

    NSString *activityContent = [activityDictionary JSONString];
    NSString *deviceToken = user.deviceToken;

    DLog(@"activity json string \n %@" , activityContent);

    NSMutableData* body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"activity=%@", activityContent] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"&device_token=%@", deviceToken] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"&url_shortening=true"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"&device=%@", device] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"&provider=%@", currentProvider.name] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"&app_name=%@", applicationBundleDisplayName()] dataUsingEncoding:NSUTF8StringEncoding]];

    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:
                                     [NSURL URLWithString:
                                      [NSString stringWithFormat:@"%@/api/v2/activity", serverUrl]]];

    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:body];

    NSDictionary* tag = [[NSDictionary alloc] initWithObjectsAndKeys:
                         @"shareActivity", @"action",
                         activity, @"activity",
                         currentProvider.name, @"providerName", nil];

    ALog ("Sharing activity on %@:\n request=%@\nbody=%@", user.providerName, [[request URL] absoluteString],
          [NSString stringWithCString:body.bytes encoding:NSUTF8StringEncoding]);

    if (![JRConnectionManager createConnectionFromRequest:request forDelegate:self withTag:tag])
        [self triggerPublishingDidFailWithError:[JRError setError:@"There was a problem connecting to the Janrain server to share this activity"
                                                         withCode:JRPublishErrorBadConnection]];
}

- (void)startSetStatusForUser:(JRAuthenticatedUser*)user
{
    DLog (@"activity status: %@", [activity userGeneratedContent]);

    NSString *status = [activity userGeneratedContent];
    NSString *deviceToken = user.deviceToken;

    NSMutableData* body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"status=%@", status] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"&device_token=%@", deviceToken] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"&device=%@", device] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"&app_name=%@", applicationBundleDisplayName()] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"&provider=%@", currentProvider.name] dataUsingEncoding:NSUTF8StringEncoding]];

    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:
                                     [NSURL URLWithString:
                                      [NSString stringWithFormat:@"%@/api/v2/set_status", serverUrl]]];

    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:body];

    NSDictionary* tag = [[NSDictionary alloc] initWithObjectsAndKeys:
                         @"shareActivity", @"action",
                         activity, @"activity",
                         currentProvider.name, @"providerName", nil];

    ALog ("Sharing activity on %@:\n request=%@\nbody=%@", user.providerName, [[request URL] absoluteString],
          [NSString stringWithCString:body.bytes encoding:NSUTF8StringEncoding]);

    if (![JRConnectionManager createConnectionFromRequest:request forDelegate:self withTag:tag])
        [self triggerPublishingDidFailWithError:[JRError setError:@"There was a problem connecting to the Janrain server to share this activity"
                                                         withCode:JRPublishErrorBadConnection]];
}

- (void)shareActivityForUser:(JRAuthenticatedUser*)user
{
    [self startShareActivityForUser:user];
}

- (void)setStatusForUser:(JRAuthenticatedUser*)user
{
    [self startSetStatusForUser:user];
}

- (void)finishShareActivity:(JRActivityObject*)_activity forProvider:(NSString*)providerName withResponse:(NSString*)response
{
    ALog (@"Activity sharing response: %@", response);

    NSDictionary *responseDict = [response objectFromJSONString];

    if (!responseDict)
    {
        NSArray *delegatesCopy = [NSArray arrayWithArray:delegates];
        for (id<JRSessionDelegate> delegate in delegatesCopy)
        {
            if ([delegate respondsToSelector:@selector(publishingActivity:didFailWithError:forProvider:)])
                [delegate publishingActivity:_activity
                            didFailWithError:[JRError setError:[NSString stringWithString:response]
                                                      withCode:JRPublishFailedError]
                                 forProvider:providerName];
        }
        return;
    }

    if ([[responseDict objectForKey:@"stat"] isEqualToString:@"ok"])
    {
        [self saveLastUsedSocialProvider:providerName];
        NSArray *delegatesCopy = [NSArray arrayWithArray:delegates];
        for (id<JRSessionDelegate> delegate in delegatesCopy)
        {
            if ([delegate respondsToSelector:@selector(publishingActivityDidSucceed:forProvider:)])
                [delegate publishingActivityDidSucceed:_activity forProvider:providerName];
        }
    }
    else
    {
        NSDictionary *errorDict = [responseDict objectForKey:@"err"];
        NSError *publishError = nil;

        if (!errorDict)
        {
            publishError = [JRError setError:@"There was a problem publishing this activity"
                                    withCode:JRPublishFailedError];
        }
        else
        {
            int code;
            if (!CFNumberGetValue((void*)[errorDict objectForKey:@"code"], kCFNumberSInt32Type, &code))
                code = 1000;

            NSString *errorMessage = [errorDict objectForKey:@"msg"];
            switch (code)
            {
                case 0: /* "Missing parameter: ..." error */
                case 1: /* Invalid parameter: ..." error */

                 /* Missing apiKey; this error should prompt a reauthentication. */
                    if ([errorMessage isEqualToString:@"Missing parameter: apiKey"])
                        publishError = [JRError setError:errorMessage
                                                withCode:JRPublishErrorMissingApiKey];

                 /* Missing some other parameter: activity/url/etc." */
                    else
                        publishError = [JRError setError:errorMessage
                                                withCode:JRPublishErrorMissingParameter];
                    break;

                case 4: /* "Facebook Error: ..." */

                /* "Invalid OAuth 2.0 Access Token" or "Error validating access token: The session has been
                    invalidated because the user has changed the password" or TODO: THE SESSION EXPIRED ERROR;
                    these errors should prompt a reauthentication. */
                    if (([errorMessage rangeOfString:@"Invalid OAuth 2.0 Access Token"
                                             options:NSCaseInsensitiveSearch].location != NSNotFound) ||
                        ([errorMessage rangeOfString:@"Error validating access token"
                                             options:NSCaseInsensitiveSearch].location != NSNotFound) ||
                        ([errorMessage rangeOfString:@"Error validating access token"
                                             options:NSCaseInsensitiveSearch].location != NSNotFound))
                            publishError = [JRError setError:errorMessage
                                                    withCode:JRPublishErrorInvalidFacebookSession];

                 /* Bad image error: "One or more of your image records failed to include a valid 'href' field" */
                    else if ([errorMessage rangeOfString:@"image records failed"
                                                 options:NSCaseInsensitiveSearch].location != NSNotFound)
                        publishError = [JRError setError:errorMessage
                                                withCode:JRPublishErrorInvalidFacebookMedia];

                 /* Bad flash object error: "flash objects must have the 'source' and 'picture' attributes/etc." */
                    else if ([errorMessage rangeOfString:@"flash objects must"
                                                 options:NSCaseInsensitiveSearch].location != NSNotFound)
                        publishError = [JRError setError:errorMessage
                                                withCode:JRPublishErrorInvalidFacebookMedia];

                 /* Any other generic Facebook error */
                    else
                        publishError = [JRError setError:errorMessage
                                                withCode:JRPublishErrorFacebookGeneric];

                    break;

                case 6: /* Error interacting with a previously operational provider */
                 /* Twitter duplicate message error: "Twitter server error: Status is a duplicate." */
                    if ([errorMessage isEqualToString:@"Twitter server error: Status is a duplicate."])
                        publishError = [JRError setError:errorMessage
                                                withCode:JRPublishErrorDuplicateTwitter];
                 /* Any other error with code 6 */
                    else
                        publishError = [JRError setError:errorMessage
                                                withCode:JRPublishFailedError];
                    break;

                case 13: /* Twitter Error */
                    publishError = [JRError setError:errorMessage
                                            withCode:JRPublishErrorTwitterGeneric];
                    break;

                case 14: /* LinkedIn Error */
                    publishError = [JRError setError:errorMessage
                                            withCode:JRPublishErrorLinkedInGeneric];
                    break;

                case 16: /* MySpace Error */
                    publishError = [JRError setError:errorMessage
                                            withCode:JRPublishErrorMyspaceGeneric];
                    break;

                case 17: /* Yahoo Error */
                    publishError = [JRError setError:errorMessage
                                            withCode:JRPublishErrorYahooGeneric];
                    break;

                case 100: /* Character limit error?  Not documented on rpxnow.com. */
                 /* Formerly LinkedIn character limit error (JRPublishErrorLinkedInCharacterExceeded) */
                    publishError = [JRError setError:errorMessage
                                            withCode:JRPublishErrorCharacterLimitExceeded];
                    break;


                case 1000: /* Extracting code failed; Fall through. */
                default:   /* See below for list of ignored error codes. */
                    publishError = [JRError setError:@"There was a problem publishing this activity"
                                            withCode:JRPublishFailedError];
                    break;

            /* -1:  Service Temporarily Unavailable
                1:  Invalid parameter
                2:  Data not found
                3:  Authentication error
                5:  Mapping exists
                7:  Engage account upgrade needed to access this API
                8:  Missing third-party credentials for this identifier
                9:  Third-party credentials have been revoked
                10: Your application is not properly configured
                11: The provider or identifier does not support this feature
                12: Google Error
                13: Twitter Error
                14: LinkedIn Error
                15: LiveId Error
                16: MySpace Error
                18: Domain already exists
                19: App Id not found
                17: Yahoo Error
                20: Orkut Error */
            }
        }

        NSArray *delegatesCopy = [NSArray arrayWithArray:delegates];
        for (id<JRSessionDelegate> delegate in delegatesCopy)
        {
            if ([delegate respondsToSelector:@selector(publishingActivity:didFailWithError:forProvider:)])
                [delegate publishingActivity:_activity
                            didFailWithError:publishError
                                 forProvider:providerName];
        }
    }
}

- (void)startRecordActivitySharedBy:(NSString*)method
{
    ALog (@"");
    NSMutableData* body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"device=%@", device] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"&method=%@", method] dataUsingEncoding:NSUTF8StringEncoding]];

    NSString *urlString = [NSString stringWithFormat:
                           @"%@/social/record_activity?",
                           baseUrl];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];

    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:body];

    NSString *tag = [NSString stringWithFormat:@"%@Success", method];

    [JRConnectionManager createConnectionFromRequest:request forDelegate:self returnFullResponse:NO withTag:[tag retain]];
}

#pragma mark url_shortening
- (void)startGetShortenedUrlsForActivity:(JRActivityObject*)theActivity
{
    DLog(@"");

    if (!theActivity.url && ![theActivity.email.urls count] && ![theActivity.sms.urls count])
        return;

    /* In case there's an error, we'll just set the activity's shortened url to the
     * unshortened url for now, and update it only if we successfully shorten it. */
    theActivity.shortenedUrl = theActivity.url;

    /* If we haven't gotten the baseUrl back from the configuration yet, return, and get the shortened urls later */
    if (!baseUrl)
    {
        stillNeedToShortenUrls = YES;
        return;
    }

    NSMutableDictionary *urls = [NSMutableDictionary dictionaryWithCapacity:3];
    if (theActivity.email.urls) [urls setObject:theActivity.email.urls forKey:@"email"];
    if (theActivity.sms.urls)   [urls setObject:theActivity.email.urls forKey:@"sms"];
    if (theActivity.url)        [urls setObject:[NSArray arrayWithObject:theActivity.url] forKey:@"activity"];

    NSString *urlString = [NSString stringWithFormat:@"%@/openid/get_urls?urls=%@&app_name=%@&device=%@",
                           baseUrl, [[urls JSONString]/*JSONRepresentation]*/ stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                            [self appNameAndVersion], device];

    DLog (@"Getting shortened URLs: %@", urlString);

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];

    NSDictionary *tag = [[NSDictionary alloc] initWithObjectsAndKeys:theActivity, @"activity",
                                                                     @"shortenUrls", @"action", nil];

    [JRConnectionManager createConnectionFromRequest:request forDelegate:self withTag:tag];
}

- (void)finishGetShortenedUrlsForActivity:(JRActivityObject*)_activity withShortenedUrls:(NSString*)urls
{
    DLog ("Shortened Urls: %@", urls);

    NSDictionary *dict = [urls objectFromJSONString];

    if (!dict)
        goto CALL_DELEGATE_SELECTOR;

    if ([dict objectForKey:@"err"])
        goto CALL_DELEGATE_SELECTOR;

    NSDictionary *emailUrls    = [[dict objectForKey:@"urls"] objectForKey:@"email"];
    NSDictionary *smsUrls      = [[dict objectForKey:@"urls"] objectForKey:@"sms"];
    NSDictionary *activityUrls = [[dict objectForKey:@"urls"] objectForKey:@"activity"];

    for (NSString *key in [emailUrls allKeys])
    {
        _activity.email.messageBody = [_activity.email.messageBody
                                       stringByReplacingOccurrencesOfString:key
                                       withString:[emailUrls objectForKey:key]];
    }

    for (NSString *key in [smsUrls allKeys])
    {
        _activity.sms.message = [_activity.sms.message
                                 stringByReplacingOccurrencesOfString:key
                                 withString:[smsUrls objectForKey:key]];
    }

    for (NSString *key in [activityUrls allKeys])
    {
        if ([key isEqualToString:activity.url])
            [_activity setShortenedUrl:[activityUrls objectForKey:key]];
    }

CALL_DELEGATE_SELECTOR:
    for (id<JRSessionDelegate> delegate in [NSArray arrayWithArray:delegates])
        if ([delegate respondsToSelector:@selector(urlShortenedToNewUrl:forActivity:)])
            [delegate urlShortenedToNewUrl:[_activity shortenedUrl] forActivity:_activity];
}

#pragma mark token_url
- (void)startMakeCallToTokenUrl:(NSString*)_tokenUrl withToken:(NSString *)token forProvider:(NSString*)providerName
{
    ALog (@"Calling token URL for %@:\n%@", providerName, _tokenUrl);

    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"token=%@", token] dataUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_tokenUrl]];

    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:body];

    NSDictionary *tag = [[NSDictionary dictionaryWithObjectsAndKeys:_tokenUrl, @"tokenUrl",
                                                                    providerName, @"providerName",
                                                                    @"callTokenUrl", @"action", nil] retain];

    if (![JRConnectionManager createConnectionFromRequest:request forDelegate:self returnFullResponse:YES withTag:tag])
    {
        NSError *_error = [JRError setError:@"Problem initializing the connection to the token url"
                                   withCode:JRAuthenticationTokenUrlFailedError];

        NSArray *delegatesCopy = [NSArray arrayWithArray:delegates];
        for (id<JRSessionDelegate> delegate in delegatesCopy)
        {
            if ([delegate respondsToSelector:@selector(authenticationCallToTokenUrl:didFailWithError:forProvider:)])
                [delegate authenticationCallToTokenUrl:_tokenUrl didFailWithError:_error forProvider:providerName];
        }
    }
}

- (void)finishMakeCallToTokenUrl:(NSString*)_tokenUrl withResponse:(NSURLResponse*)fullResponse
                      andPayload:(NSData*)payload forProvider:(NSString*)providerName
{
    NSArray *delegatesCopy = [NSArray arrayWithArray:delegates];
    for (id<JRSessionDelegate> delegate in delegatesCopy)
    {
        if ([delegate respondsToSelector:@selector(authenticationDidReachTokenUrl:withResponse:andPayload:forProvider:)])
            [delegate authenticationDidReachTokenUrl:_tokenUrl
                                        withResponse:fullResponse
                                          andPayload:payload
                                         forProvider:providerName];
    }
}

#pragma mark connection_manager_delegate_protocol
- (void)connectionDidFinishLoadingWithFullResponse:(NSURLResponse*)fullResponse unencodedPayload:(NSData*)payload
                                           request:(NSURLRequest*)request andTag:(void*)userdata
{
    NSObject *tag = (NSObject*)userdata;

    NSDictionary      *headers      = nil;
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)fullResponse;
    if ([httpResponse respondsToSelector:@selector(allHeaderFields)])
        headers = [httpResponse allHeaderFields];

    if ([tag isKindOfClass:[NSDictionary class]])
    {
        NSString *action = [(NSDictionary*)tag objectForKey:@"action"];

        if ([action isEqualToString:@"callTokenUrl"])
        {
            [self finishMakeCallToTokenUrl:[(NSDictionary*)tag objectForKey:@"tokenUrl"]
                              withResponse:fullResponse
                                andPayload:payload
                               forProvider:[(NSDictionary*)tag objectForKey:@"providerName"]];
        }
        if ([action isEqualToString:@"downloadPicture"])
        {
            // TODO: Later, make this more dynamic, and not fixed to just pngs.
            if ([[fullResponse MIMEType] isEqualToString:@"image/png"])
                [self finishDownloadPicture:payload
                                      named:[(NSDictionary*)tag objectForKey:@"pictureName"]
                                forProvider:[(NSDictionary*)tag objectForKey:@"providerName"]];
            else
                ALog ("Not able to download the picture: %@", [[request URL] absoluteString]);
        }
    }
    else if ([tag isKindOfClass:[NSString class]])
    {
        //DLog (@"Connect did finish loading: %@", tag);

        if ([(NSString*)tag isEqualToString:@"getConfiguration"])
        {
            NSString *payloadString = [[[NSString alloc] initWithData:payload encoding:NSASCIIStringEncoding] autorelease];
            self.error = [self finishGetConfiguration:payloadString
                                             withEtag:[headers objectForKey:@"Etag"]];

        }
    }

    [tag release];
}

- (void)connectionDidFinishLoadingWithPayload:(NSString*)payload request:(NSURLRequest*)request andTag:(void*)userdata
{
    NSObject* tag = (NSObject*)userdata;

   // [payload retain];

    if ([tag isKindOfClass:[NSDictionary class]])
    {
        NSString *action = [(NSDictionary*)tag objectForKey:@"action"];
        DLog (@"Connect did finish loading: %@", action);

        if ([action isEqualToString:@"shareActivity"])
        {
            [self finishShareActivity:[(NSDictionary*)tag objectForKey:@"activity"]
                          forProvider:[(NSDictionary*)tag objectForKey:@"providerName"]
                         withResponse:payload];
        }
        else if ([action isEqualToString:@"shortenUrls"])
        {
            [self finishGetShortenedUrlsForActivity:[(NSDictionary*)tag objectForKey:@"activity"]
                                  withShortenedUrls:payload];
        }
    }
    else if ([tag isKindOfClass:[NSString class]])
    {
        DLog (@"Connect did finish loading: %@", tag);
        DLog (@"Response: %@", payload);
        if ([(NSString*)tag isEqualToString:@"emailSuccess"])
        {
            // Do nothing for now...
        }
        else if ([(NSString*)tag isEqualToString:@"smsSuccess"])
        {
            // Do nothing for now...
        }
        else
        {
            // Do nothing for now...
        }
    }

    [tag release];
}

- (void)connectionDidFailWithError:(NSError*)connectionError request:(NSURLRequest*)request andTag:(void*)userdata
{
    NSObject* tag = (NSObject*)userdata;

    if ([tag isKindOfClass:[NSString class]])
    {
        ALog (@"Connection for %@ failed with error: %@", tag, [connectionError localizedDescription]);

        if ([(NSString*)tag isEqualToString:@"getConfiguration"])
        {
            self.error = [JRError setError:@"There was a problem communicating with the Janrain server while configuring authentication."
                                  withCode:JRConfigurationInformationError];
        }
        else if ([(NSString*)tag isEqualToString:@"emailSuccess"])
        {
            // Do nothing for now...
        }
        else if ([(NSString*)tag isEqualToString:@"smsSuccess"])
        {
            // Do nothing for now...
        }
        else
        {
            // Do nothing for now...
        }
    }
    else if ([(NSDictionary*)tag isKindOfClass:[NSDictionary class]])
    {
        NSString *action = [(NSDictionary*)tag objectForKey:@"action"];
        ALog (@"Connection for %@ failed with error: %@", action, [connectionError localizedDescription]);

        if ([action isEqualToString:@"callTokenUrl"])
        {
            NSArray *delegatesCopy = [NSArray arrayWithArray:delegates];
            for (id<JRSessionDelegate> delegate in delegatesCopy)
            {
                if ([delegate respondsToSelector:@selector(authenticationCallToTokenUrl:didFailWithError:forProvider:)])
                    [delegate authenticationCallToTokenUrl:[(NSDictionary*)tag objectForKey:@"tokenUrl"]
                                          didFailWithError:connectionError
                                               forProvider:[(NSDictionary*)tag objectForKey:@"providerName"]];
            } // TODO: Perhaps update the error code to use a JRError enum?
        }
        else if ([action isEqualToString:@"shareActivity"])
        {
            NSArray *delegatesCopy = [NSArray arrayWithArray:delegates];
            for (id<JRSessionDelegate> delegate in delegatesCopy)
            {
                if ([delegate respondsToSelector:@selector(publishingActivity:didFailWithError:forProvider:)])
                    [delegate publishingActivity:activity
                                didFailWithError:connectionError
                                     forProvider:currentProvider.name];

            }
        }
        else if ([action isEqualToString:@"shortenUrls"])
        {
            /* Call with _activity.shortenedUrl (as opposed to newShortened) in case there was an error, as
             * _activity.shortenedUrl was previously set to fall back to the full url. */
            NSArray *delegatesCopy = [NSArray arrayWithArray:delegates];
            for (id<JRSessionDelegate> delegate in delegatesCopy)
                if ([delegate respondsToSelector:@selector(urlShortenedToNewUrl:forActivity:)])
                    [delegate urlShortenedToNewUrl:((JRActivityObject*)[(NSDictionary*)tag objectForKey:@"activity"]).shortenedUrl
                                       forActivity:((JRActivityObject*)[(NSDictionary*)tag objectForKey:@"activity"])];
        }
        else
        {
            // Do nothing for now...
        }
    }

    [tag release];
}

- (void)connectionWasStoppedWithTag:(void*)userdata
{
    DLog (@"Connection was stopped.");

    if ([(NSObject*)userdata isKindOfClass:[NSString class]])
        [(NSString*)userdata release];
    if ([(NSObject*)userdata isKindOfClass:[NSDictionary class]])
        [(NSDictionary*)userdata release];
}

#pragma mark delegate_management
- (void)addDelegate:(id<JRSessionDelegate>)delegateToAdd
{
    if (delegateToAdd)
        [delegates addObject:delegateToAdd];
}

- (void)removeDelegate:(id<JRSessionDelegate>)delegateToRemove
{
    [delegates removeObject:delegateToRemove];
}

#pragma mark trigger_methods
- (void)triggerAuthenticationDidCompleteWithPayload:(NSDictionary*)payloadDict
{
 /* This value will be nil if authentication was canceled after the user authenticated in the
    webview, but before the authentication call was completed, like in the case where the calling
    application issues the cancelAuthentication command. */
    if (!currentProvider)
        return;

    NSDictionary *goodies = [payloadDict objectForKey:@"rpx_result"];
    NSString *token = [goodies objectForKey:@"token"];
    NSMutableDictionary *auth_info = [NSMutableDictionary dictionaryWithDictionary:[goodies objectForKey:@"auth_info"]];

    [auth_info setObject:token forKey:@"token"];

    DLog (@"Authentication completed for user: %@", [goodies description]);

    JRAuthenticatedUser *user = [[[JRAuthenticatedUser alloc] initUserWithDictionary:goodies
                                                                    andWelcomeString:[self getWelcomeMessageFromCookie]
                                                                    forProviderNamed:currentProvider.name] autorelease];

    if (user)
    {
        [authenticatedUsersByProvider setObject:user forKey:currentProvider.name];
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:authenticatedUsersByProvider]
                                                  forKey:cJRAuthenticatedUsersByProvider];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        // TODO: There could be some kind of error initializing the user!
    }

    if ([[self basicProviders] containsObject:currentProvider.name] && !socialSharing)
        [self saveLastUsedBasicProvider:currentProvider.name];

    if ([[self socialProviders] containsObject:currentProvider.name])
        [self saveLastUsedSocialProvider:currentProvider.name];

    NSArray *delegatesCopy = [NSArray arrayWithArray:delegates];
    for (id<JRSessionDelegate> delegate in delegatesCopy)
    {
        if ([delegate respondsToSelector:@selector(authenticationDidCompleteForUser:forProvider:)])
            [delegate authenticationDidCompleteForUser:auth_info forProvider:currentProvider.name];
    }

    if (tokenUrl)
        [self startMakeCallToTokenUrl:tokenUrl withToken:token forProvider:currentProvider.name];

    [currentProvider release];
    currentProvider = nil;
}

- (void)triggerAuthenticationDidFailWithError:(NSError*)authError
{
    // TODO: Set force_reauth for the provider instead!!!
//    if ([currentProvider.name isEqualToString:@"facebook"])
//        [self deleteFacebookCookies];
//    else if ([currentProvider.name isEqualToString:@"live_id"])
//        [self deleteLiveCookies];

    NSArray *delegatesCopy = [NSArray arrayWithArray:delegates];
    for (id<JRSessionDelegate> delegate in delegatesCopy)
    {
        if ([delegate respondsToSelector:@selector(authenticationDidFailWithError:forProvider:)])
            [delegate authenticationDidFailWithError:authError forProvider:currentProvider.name];
    }

    [currentProvider release],         currentProvider         = nil;
    [returningBasicProvider release],  returningBasicProvider  = nil;
    [returningSocialProvider release], returningSocialProvider = nil;
}

- (void)triggerAuthenticationDidCancel
{
    DLog (@"");

    NSArray *delegatesCopy = [NSArray arrayWithArray:delegates];
    for (id<JRSessionDelegate> delegate in delegatesCopy)
    {
        if ([delegate respondsToSelector:@selector(authenticationDidCancel)])
            [delegate authenticationDidCancel];
    }

    [currentProvider release], currentProvider = nil;
}

- (void)triggerAuthenticationDidCancel:(id)sender
{
    [self triggerAuthenticationDidCancel];
}

- (void)triggerAuthenticationDidTimeOutConfiguration
{
    DLog (@"");

    NSArray *delegatesCopy = [NSArray arrayWithArray:delegates];
    for (id<JRSessionDelegate> delegate in delegatesCopy)
    {
        if ([delegate respondsToSelector:@selector(authenticationDidCancel)])
            [delegate authenticationDidCancel];
    }

    [currentProvider release], currentProvider = nil;
}

- (void)triggerAuthenticationDidStartOver:(id)sender
{
    DLog (@"");

    NSArray *delegatesCopy = [NSArray arrayWithArray:delegates];
    for (id<JRSessionDelegate> delegate in delegatesCopy)
    {
        if ([delegate respondsToSelector:@selector(authenticationDidRestart)])
            [delegate authenticationDidRestart];
    }
}

- (void)triggerPublishingDidCancel
{
    DLog (@"");

    NSArray *delegatesCopy = [NSArray arrayWithArray:delegates];
    for (id<JRSessionDelegate> delegate in delegatesCopy)
    {
        if ([delegate respondsToSelector:@selector(publishingDidCancel)])
            [delegate publishingDidCancel];
    }

    [currentProvider release], currentProvider = nil;
    socialSharing = NO;
}

- (void)triggerPublishingDidCancel:(id)sender
{
    [self triggerPublishingDidCancel];
}

- (void)triggerPublishingDidTimeOutConfiguration
{
    DLog (@"");

    NSArray *delegatesCopy = [NSArray arrayWithArray:delegates];
    for (id<JRSessionDelegate> delegate in delegatesCopy)
    {
        if ([delegate respondsToSelector:@selector(publishingDidCancel)])
            [delegate publishingDidCancel];
    }

    [currentProvider release], currentProvider = nil;
    socialSharing = NO;
}

- (void)triggerPublishingDidComplete
{
    NSArray *delegatesCopy = [NSArray arrayWithArray:delegates];
    for (id<JRSessionDelegate> delegate in delegatesCopy)
    {
        if ([delegate respondsToSelector:@selector(publishingDidComplete)])
            [delegate publishingDidComplete];
    }

    [currentProvider release], currentProvider = nil;
    socialSharing = NO;
}

- (void)triggerPublishingDidComplete:(id)sender
{
    [self triggerPublishingDidComplete];
}

- (void)triggerPublishingDidFailWithError:(NSError*)pubError
{
    NSArray *delegatesCopy = [NSArray arrayWithArray:delegates];
    for (id<JRSessionDelegate> delegate in delegatesCopy)
    {
        if ([delegate respondsToSelector:@selector(publishingActivity:didFailWithError:forProvider:)])
            [delegate publishingActivity:activity didFailWithError:pubError forProvider:currentProvider.name];
    }

    // TODO: Do we want to set currentProvider to nil?
}

- (void)triggerPublishingDidStartOver:(id)sender
{
    DLog (@"");

    NSArray *delegatesCopy = [NSArray arrayWithArray:delegates];
    for (id<JRSessionDelegate> delegate in delegatesCopy)
    {
        if ([delegate respondsToSelector:@selector(publishingDidRestart)])
            [delegate publishingDidRestart];
    }
}

- (void)triggerEmailSharingDidComplete
{
    DLog (@"");
    [self startRecordActivitySharedBy:@"email"];
}

- (void)triggerSmsSharingDidComplete
{
    DLog (@"");
    [self startRecordActivitySharedBy:@"sms"];
}
@end
