/**
 * \file FWProtocols.h
 * \brief Protocols in FreeWheel AdManager SDK
 */
@class UIView;
@class CLLocation;
@class MPMoviePlayerController;
@class UIViewController;

@protocol FWAdManager;
@protocol FWContext;
@protocol FWSlot;
@protocol FWAdInstance;
@protocol FWCreativeRendition;
@protocol FWCreativeRenditionAsset;
@protocol FWRendererController;
@protocol FWRenderer;

/** 
 *	\fn id<FWAdManager> newAdManager()
 *	Create a new AdManager instance
 *	\return	an id<FWAdManager>
 */
FW_EXTERN id<FWAdManager> newAdManager(void);

/** 
 *	\fn void FWSetLogLevel(FWLogLevel value); 
 *	Set log level
 *	\param value
 *		-	FW_LOG_LEVEL_INFO	Default value
 *		-	FW_LOG_LEVEL_QUIET
 */
FW_EXTERN void FWSetLogLevel(FWLogLevel value);

/**
 *	\fn void FWSetUncaughtExceptionHandler(NSUncaughtExceptionHandler *handler)
 *	AdManager registers NSSetUncaughtExceptionHandler() to report uncaught exception.
 *	If app need to perform last-minute logging before the program terminates, use this function instead of NSSetUncaughtExceptionHandler.
 *	\param handler
 */
FW_EXTERN void FWSetUncaughtExceptionHandler(NSUncaughtExceptionHandler *handler);

/** 
 *	\fn void FWClearCookie();
 *	Clear All cookies from fwmrm.net domains.
 */
FW_EXTERN void FWClearCookie(void);

/** 
 *	\fn void FWSetCookieOptOutState(BOOL value);
 *	Opt-out cookies from fwmrm.net domains.
 */
FW_EXTERN void FWSetCookieOptOutState(BOOL value);

/** 
 *	\fn BOOL FWGetCookieOptOutState();
 *	Get MRM cookie opt-out state.
 */
FW_EXTERN BOOL FWGetCookieOptOutState(void);

/**
 *	Protocol for AdManager
 *
 *	Use newAdManager() to create a new id<FWAdManager> instance
 */
@protocol FWAdManager <NSObject>
/**
 *	Set application's current view controller. This value is REQUIRED. Application must be view controller based.
 *	This value is retained by FWAdManager. 
 *
 *	\param value
 */
- (void)setCurrentViewController:(UIViewController *)value;

/**
 *	Set the FreeWheel ad server http address. This value will be used by FWContext objects created from this FWAdManager object.
 *	\param	value	url of the FreeWheel Ad Server
 */
- (void)setServerUrl:(NSString *)value;

/**
 *	Set the network id of the distributor. This value will be used by FWContext objects created from this FWAdManager object.
 *	\param	value	network id of the distributor
 */
- (void)setNetworkId:(NSUInteger)value;

/**
 *	Set the current location of device. This value will be used by FWContext objects created from this FWAdManager object for geo targeting.
 *	\param	value	value of the location to be set. nil has no effect.
 */
- (void)setLocation:(CLLocation *)value;

/**
 *	Get major version of AdManager
 *	\return	version of AdManager, e.g. 0x02060000 for v2.6
 */
- (NSUInteger)version;

/**
 *	Create a new context 
 *	A Context instance is used to set ad request information for a particular ad or ad set.  Multiple contexts can be created throughout the lifecycle of the FreeWheel AdManager and may exist siumultaneously without consequence. Multiple simultaneous contexts are useful to optimize user experience in the network-resource limited environment.
 *	\return	an id<FWContext>
 */
- (id<FWContext>)newContext;

/**
 *	Create a new context from the given context. The new context copies internal state of the old one for submitting new ad request.
 *		
 *	Following methods are called automatically on the new context with values of the old one.
 *	These methods DO NOT NEED to call again on the new context: 
 *		-	-[FWContext setRequestMode:]
 *		-	-[FWContext setCapability:]
 *		-	-[FWContext setVisitor:]
 *		-	-[FWContext setVisitorHttpHeader:]
 *		-	-[FWContext setSiteSection:]
 *		-	-[FWContext setVideoAsset:]
 *		-	-[FWContext setProfile:]
 *		-	-[FWContext startSubsession:]
 *		-	-[FWContext setRequestDuration:]
 *		-	-[FWContext setVideoDisplayCompatibleSizes:]
 *		-	-[FWContext setVideoState:]
 *		-	-[FWContext setNotificationCenter:]
 *		-	-[FWContext setMoviePlayerController:]
 *		-	-[FWContext setMoviePlayerFullscreen:]
 *
 *	Following methods are REQUIRED to call again on the new context:
 *		-	-[NSNotificationCeneter addObserver:selector:name:object:] 	(add notification observer for the new context)
 *		-	-[FWContext submitRequest:]
 *		
 */
- (id<FWContext>)newContextWithContext:(id<FWContext>)context;
@end


/**
 *	Protocol for AdManager context
 */
@protocol FWContext <NSObject>
/**
 *	Set context level temporal slot base. Video ad are rendererd upon the base view with the same size.
 *	If video display base view changes, app needs to invoke this method again, renderer will display video ad on the updated base; if video display base view does not change but its frame changes, app does not need to invoke this method again, renderer re-layout video ad according to to the new frame automatically.
 *	Prior to AdManager 3.8, renderer assume main video's MPMoviePlayerController view is the video display base. Starting from AdManager 3.8, for iOS>=3.2, app must invoke this method to speicify video display base explicitly. For iOS3.0-3.1, app does not need to invoke this method since the legacy MPMoviePlayerController is always played in fullscreen.
 */
- (void)setVideoDisplayBase:(UIView *)value;

/**
 *	Set the main video's movie player controller for rendering video ad.
 *
 *	\param	value	the player which plays main video
 *
 */
- (void)setMoviePlayerController:(MPMoviePlayerController *)value;

/**
 *	Set the main video's movie player fullscreen mode for rendering video ad.
 *	If application sets main video's MPMoviePlayerController fullscreen as YES or 
 *	present MPMoviePlayerViewController as a modal view, this value should be
 *	set as YES.
 *	
 *	\param	value	default behavior is non-fullscreen
 *
 *	Availability: iOS >= 3.2 
 */
- (void)setMoviePlayerFullscreen:(BOOL)value;

/**
 *	Set the capabilities supported by the player
 *	\param	capability capability name, should be one of FW_CAPABILITY_* in FWConstants.h
 *	\param	status indicates whether to enable this capability, should be one of:
 *	 	- FW_CAPABILITY_STATUS_ON: enable
 *	 	- FW_CAPABILITY_STATUS_OFF: disable
 *	 	- FW_CAPABILITY_STATUS_DEFAULT: leave it unset, follow the network settings
 *	\return Boolean value, indicating whether the capability is set successfully
 */
- (BOOL)setCapability:(NSString *)capability :(FWCapabilityStatus)status;

/**
 *	Add the key-value pair, if add different values with the same key, they will both the values for the key
 *	\param	key		key name of the key-value pair to be set, nil or empty string will no effect
 *	\param	value	value of the key to be set. nil has no effect.
 */
- (void)addKeyValue:(NSString *)key :(NSString *)value;

/**
 *	Set the profiles which describes the player and slots
 *	\param	playerProfile					name of the global profile
 *	\param	defaultTemporalSlotProfile		name of the temporal slot default profile, nil for default
 *	\param	defaultVideoPlayerSlotProfile	name of the video player slot default profile, nil for default
 *	\param	defaultSiteSectionSlotProfile	name of the site section slot default profile, nil for default
 */
- (void)setProfile:(NSString *)playerProfile :(NSString *)defaultTemporalSlotProfile :(NSString *)defaultVideoPlayerSlotProfile :(NSString *)defaultSiteSectionSlotProfile;

/**
 *	Set the attributes of the visitor
 *	\param	customId		custom id of the visitor
 *	\param	ipV4Address		ip address of the visitor
 *	\param	bandwidth		bandwidth of the visitor
 *	\param	bandwidthSource	bandwidth source of the visitor
 */
- (void)setVisitor:(NSString *)customId :(NSString *)ipV4Address :(NSUInteger)bandwidth :(NSString *)bandwidthSource;

/**
 *	Set the HTTP headers of the visitor
 *	\param	name	name of the header to be set
 *	\param	value	value of the header to be set, nil to remove
 */
- (void)setVisitorHttpHeader:(NSString *)name :(NSString *)value;

/**
 *	Set the attributes of current video asset to play
 *	\param	videoAssetId	id of the video
 *	\param	duration		duration of the video in seconds
 *	\param	location		location of the video, nil for default
 *	\param	autoPlayType	whether the video begins to play automatically without user interaction
 *								-	FW_VIDEO_ASSET_AUTO_PLAY_TYPE_NONE
 *								-	FW_VIDEO_ASSET_AUTO_PLAY_TYPE_ATTENDED		default
 *								-	FW_VIDEO_ASSET_AUTO_PLAY_TYPE_UNATTENDED
 *	\param	videoPlayRandom	random number that is generated each time a user watches this video asset.
 *	\param	networkId		id of the network the video belongs to, 0 for default
 *	\param	idType			type of video id above, should be one of
 *								-	FW_ID_TYPE_CUSTOM
 *								-	FW_ID_TYPE_FW
 *								-	FW_ID_TYPE_FWGROUP
 *	\param	fallbackId		video id to fallback, if id specified by the 1st parameter is not found, 0 for default
 *	\param	durationType	type of duration, should be one of
 *								-	FW_VIDEO_ASSET_DURATION_TYPE_EXACT		default
 *								-	FW_VIDEO_ASSET_DURATION_TYPE_VARIABLE	for live video
 */
- (void)setVideoAsset:(NSString *)videoAssetId :(NSTimeInterval)duration :(NSString *)location :(FWVideoAssetAutoPlayType)autoPlayType :(NSUInteger)videoPlayRandom :(NSUInteger)networkId :(FWIdType)idType :(NSUInteger)fallbackId :(FWVideoAssetDurationType)durationType;

/**
 *	Set the current logical time position of the content asset.
 *	\param	timePosition	time position value in seconds.
 *	
 *	Notes:
 *			  If the stream is broken into multiple distinct files, this should be the time position within the asset as a whole.
 */
- (void)setVideoAssetCurrentTimePosition:(NSTimeInterval)timePosition;
/**
 *	Set the attributes of the site section
 *	\param	siteSectionId	id of the site section
 *	\param	pageViewRandom	unique id for current playing
 *	\param	networkId		id of the network the site section belongs to, 0 for default
 *	\param	idType			type of the id above, should be one of
 *								-	FW_ID_TYPE_CUSTOM
 *								-	FW_ID_TYPE_FW
 *								-	FW_ID_TYPE_FWGROUP
 *	\param	fallbackId		site section id to fallback, if id specified by the 1st parameter is not found, 0 for default
 */
- (void)setSiteSection:(NSString *)siteSectionId :(NSUInteger)pageViewRandom :(NSUInteger)networkId :(FWIdType)idType :(NSUInteger)fallbackId;

/**
 *	Add candidate ads for the request to FreeWheel Ad Server
 *	\param	candidateAdId	id of the candidate ad
 */
- (void)addCandidateAd:(NSUInteger)candidateAdId;

/**
 *	Add a temporal slot
 *	\param	customId					custom id of the slot, add a slot with an identical name as existing slot will be ignored
 *	\param	adUnit						ad unit supported by the slot
 *	\param	timePosition				time position of the slot
 *	\param	slotProfile					profile name of the slot, nil for default
 *	\param	cuePointSequence			sequence of the cuePoint of the slot
 *	\param	maxDuration					maximum duration of the slot allowed, 0 for default
 *	\param	acceptPrimaryContentType	accepted primary content types, use "," as delimiter, nil for default
 *	\param	acceptContentType			accepted content types, use "," as delimiter, nil for default
 *	\param	minDuration					minimum duration of the slot allowed, 0 for default
 */
- (void)addTemporalSlot:(NSString *)customId :(NSString *)adUnit :(NSTimeInterval)timePosition :(NSString *)slotProfile :(NSUInteger)cuePointSequence :(NSTimeInterval)maxDuration :(NSString *)acceptPrimaryContentType :(NSString *)acceptContentType :(NSTimeInterval)minDuration;

/**
 *	Add a video player non-temporal slot.
 *	\param	customId					custom id of the slot, add a slot with an identical name as existing slot will be ignored
 *	\param	adUnit						ad unit supported by the slot
 *	\param	width						width of the slot
 *	\param	height						height of the slot
 *	\param	slotProfile					profile name of the slot, nil for default
 *	\param	acceptCompanion				whether to accept companion ads on this slots
 *	\param	initialAdOption				choice of the initial ad of this slot, should be one of
 *		- FW_SLOT_OPTION_INITIAL_AD_STAND_ALONE: Display a new ad in this slot
 *		- FW_SLOT_OPTION_INITIAL_AD_KEEP_ORIGINAL: Keep the original ad in this slot
 *		- FW_SLOT_OPTION_INITIAL_AD_FIRST_COMPANION_ONLY: Ask ad server to fill this slot with the first companion ad, or keep the original ad if there is no companion ad
 *		- FW_SLOT_OPTION_INITIAL_AD_FIRST_COMPANION_OR_STAND_ALONE: Ask ad server to fill this slot with the first companion ad, or display a new ad if there is no companion ad
 *	\param	acceptPrimaryContentType	accepted primary content types, use "," as delimiter, nil for default
 *	\param	acceptContentType			accepted content types, use "," as delimiter, nil for default
 *	\param	compatibleDimensions	an array of compatible dimensions, The dimension must be a NSDictionary object with key 'width' and key 'height', the value of key is int. examples:
 *		-	NSArray *keys = [NSArray arrayWithObjects:@"width", @"height", nil];
 *		-	NSArray *dimension1 = [NSArray arrayWithObjects:[NSNumber numberWithInt:1980], [NSNumber numberWithInt:1080], nil];
 *		-	NSArray *dimension2 = [NSArray arrayWithObjects:[NSNumber numberWithInt:1280], [NSNumber numberWithInt:720], nil];
 *		-	NSArray *myDimensions = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjects:dimension1 forKeys:keys], [NSDictionary dictionaryWithObjects:dimension2 forKeys:keys], nil];
 */
- (void)addVideoPlayerNonTemporalSlot:(NSString *)customId :(NSString *)adUnit :(NSUInteger)width :(NSUInteger)height :(NSString *)slotProfile :(BOOL)acceptCompanion :(FWInitialAdOption)initialAdOption :(NSString *)acceptPrimaryContentType :(NSString *)acceptContentType :(NSArray *)compatibleDimensions;

/**
 *	Add a site section non-temporal slot
 *	\param	customId					custom id of the slot, adding a slot with an identical name as existing slot will be ignored
 *	\param	adUnit						ad unit supported by the slot
 *	\param	width						width of the slot
 *	\param	height						height of the slot
 *	\param	slotProfile					profile name of the slot, nil for default
 *	\param	acceptCompanion				whether to accept companion ads on this slots
 *	\param	initialAdOption				choice of the initial ad of this slot, should be one of
 *		- FW_SLOT_OPTION_INITIAL_AD_STAND_ALONE: Display a new ad in this slot
 *		- FW_SLOT_OPTION_INITIAL_AD_KEEP_ORIGINAL: Keep the original ad in this slot
 *		- FW_SLOT_OPTION_INITIAL_AD_FIRST_COMPANION_ONLY: Ask ad server to fill this slot with the first companion ad, or keep the original ad if there is no companion ad
 *		- FW_SLOT_OPTION_INITIAL_AD_FIRST_COMPANION_OR_STAND_ALONE: Ask ad server to fill this slot with the first companion ad, or display a new ad if there is no companion ad
 *	\param	acceptPrimaryContentType	accepted primary content types, use "," as delimiter, nil for default
 *	\param	acceptContentType			accepted content types, use "," as delimiter, nil for default
 *	\param	compatibleDimensions	an array of compatible dimensions, The dimension must be a NSDictionary object with key 'width' and key 'height', the value of key is int. examples:
 *		-	NSArray *keys = [NSArray arrayWithObjects:@"width", @"height", nil];
 *		-	NSArray *dimension1 = [NSArray arrayWithObjects:[NSNumber numberWithInt:1980], [NSNumber numberWithInt:1080], nil];
 *		-	NSArray *dimension2 = [NSArray arrayWithObjects:[NSNumber numberWithInt:1280], [NSNumber numberWithInt:720], nil];
 *		-	NSArray *myDimensions = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjects:dimension1 forKeys:keys], [NSDictionary dictionaryWithObjects:dimension2 forKeys:keys], nil];
 */
- (void)addSiteSectionNonTemporalSlot:(NSString *)customId :(NSString *)adUnit :(NSUInteger)width :(NSUInteger)height :(NSString *)slotProfile :(BOOL)acceptCompanion :(FWInitialAdOption)initialAdOption :(NSString *)acceptPrimaryContentType :(NSString *)acceptContentType :(NSArray *)compatibleDimensions;

/**
 *	Set the video play status
 *	\param	videoState	the type of the state, should be one of:
 *		-	FW_VIDEO_STATE_PLAYING
 *		-	FW_VIDEO_STATE_PAUSED
 *		-	FW_VIDEO_STATE_STOPPED
 *		-	FW_VIDEO_STATE_COMPLETED
 */
- (void)setVideoState:(FWVideoState)videoState;

/**
 *	Get all the temporal slots
 *	\return An Array of id<FWSlot> objects
 */
- (NSArray * /* id<FWSlot> */)temporalSlots;

/**
 *	Get all the video player non-temporal slots
 *	\return An Array of id<FWSlot> objects
 */
- (NSArray * /* id<FWSlot> */)videoPlayerNonTemporalSlots;  

/**
 *	Get all the site section non-temporal slots
 *	\return An Array of id<FWSlot> objects
 */
- (NSArray * /* id<FWSlot> */)siteSectionNonTemporalSlots;  

/**
 *	Get all slots in specified time position class
 *	\param	timePositionClass	the value indicating time position class
 *	\return An Array of id<FWSlot> objects
 */
- (NSArray * /* id<FWSlot> */)getSlotsByTimePositionClass:(FWTimePositionClass)timePositionClass;

/**
 *	Get a slot by its customId
 *	\param	customId	custom id of the slot
 *	\return An id<FWSlot> object, or nil if not found
 */
- (id<FWSlot>)getSlotByCustomId:(NSString *)customId;

/**
 *	Set a nofication center which will receive notifiations published from AdManager.
 *	If this method is not applied, player can receive notifications with [NSNotificationCenter defaultCenter] from AdManager.
 *	For FW_NOTIFICATION_REQUEST_COMPLETE, if request fails, [notification userInfo] dictionary will contain an error object.
 */
- (void)setNotificationCenter:(NSNotificationCenter *)nc;

/**
 *	Submit the request to FreeWheel Ad Server
 *	\param	timeoutInterval	time out time in second for this request. 3 secs by default.
 */
- (void)submitRequest:(NSTimeInterval)timeoutInterval;

- (void)addRendererClass:(NSString *)className forContentType:(NSString *)contentType creativeAPI:(NSString *)creativeAPI slotType:(NSString *)slotType baseUnit:(NSString *)baseAdUnit adUnit:(NSString *)soldAsAdUnit withParameters:(NSDictionary *)parameters;

/**
 *	Set the parameters for a special level. 
 *	
 *	\param	name	key of the parameter to be set
 *	\param	value	value for the key
 *	\param	level	level of the parameters, must be one of:
 *					-	FW_PARAMETER_LEVEL_GLOBAL
 *					-	FW_PARAMETER_LEVEL_OVERRIDE					
 */
- (void)setParameter:(NSString *)name withValue:(id)value forLevel:(FWParameterLevel)level;

/**
 *	Retrieve a parameter
 *  \param  name  The name of the parameter need to retrieve
 */
- (id)getParameter:(NSString *)name;

/**
 *	Set a list of acceptable alternative dimensions
 *	
 *	\param	compatibleDimensions	an array of compatible dimensions, The dimension must be a NSDictionary object with key 'width' and key 'height', the value of key is int. examples:
 *					-	NSArray *keys = [NSArray arrayWithObjects:@"width", @"height", nil];
 *					-	NSArray *dimension1 = [NSArray arrayWithObjects:[NSNumber numberWithInt:1980], [NSNumber numberWithInt:1080], nil];
 *					-	NSArray *dimension2 = [NSArray arrayWithObjects:[NSNumber numberWithInt:1280], [NSNumber numberWithInt:720], nil];
 *					-	NSArray *myDimensions = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjects:dimension1 forKeys:keys], [NSDictionary dictionaryWithObjects:dimension2 forKeys:keys], nil];
 *					-	[context setVideoDisplayCompatibleSizes:myDimensions];
 */
- (void)setVideoDisplayCompatibleSizes:(NSArray *)compatibleDimensions;

/**
 *	Set request mode of AdManager.
 *	\param	mode	a string indicates the request mode, must be one of:
 *					- FW_REQUEST_MODE_ON_DEMAND
 *					- FW_REQUEST_MODE_LIVE
 *			
 *	Notes:
 *		AdManager runs in On-Demand mode(_FW_REQUEST_MODE_ON_DEMAND) by default, invoke this method to set a player to a different mode.
 *		Invocation of this method is required right after a player gets a new AdManager instance.
 *		AdManager will reset some capabilities during the invocation.
 *	
 */
- (void)setRequestMode:(FWRequestMode)mode;

/**
 *	Set the duration for which the player is requesting ads. Player isn't required to set this value.
 *	\param	requestDuration		requesting duration value, in seconds.
 */
- (void)setRequestDuration:(NSTimeInterval)requestDuration;

/**
 *	Reset the exclusivity scope
 */
- (void)resetExclusivity;

/**
 *	Start a subsession. Following requests will be in this subsession, until this method is called again with a different token.
 *	\param	subsessionToken		a token to identify the subsession. Use a differnt token to start a new subsession.
 *	    
 *	Note:
 *		It is not supported to use a previously used token to reuse a previous subsession.
 *		Subsession only works when FW_CAPABILITY_SYNC_MULTI_REQUESTS is on, calling this method will turn on this capability.
 */
- (void)startSubsession:(NSUInteger)subsessionToken;

/**
 *	Get video asset's url location
 *
 *	\return A String set by API setVideoAsset's location parameter, or nil if not set
 */
- (NSString *)getVideoLocation;

/**
 *  Get the AdManager instance which create the current Context
 *
 *  \return A id<FWAdManager> instance
 */
- (id<FWAdManager>)getAdManager;

/**
 *	Return the nofication center object passed to id<FWContext>#setNotificationCenter:(NSNotificationCenter *), or [NSNotificationCenter defaultCenter]
 */
- (NSNotificationCenter *)notificationCenter;
@end


/**
 *	Protocol for slot 
 */
@protocol FWSlot <NSObject>

/**
 *	Get custom id of the slot
 *	\return Custom id of the slot
 */
- (NSString *)customId;  

/**
 *	Get type of the slot
 *	\return Type of the slot, the value can be one of:
 *		-	FW_SLOT_TYPE_TEMPORAL
 *		-	FW_SLOT_TYPE_VIDEOPLAYER_NONTEMPORAL
 *		-	FW_SLOT_TYPE_SITESECTION_NONTEMPORAL
 */
- (FWSlotType)type;				

/**
 *	Get time position of the slot
 *	\return Time position of the slot
 */
- (NSTimeInterval)timePosition;     

/**
 *	Get time position class
 *	\return Time position class of the slot, the value can be one of:
 *		-	FW_TIME_POSITION_CLASS_PREROLL
 *		-	FW_TIME_POSITION_CLASS_MIDROLL
 *		-	FW_TIME_POSITION_CLASS_POSTROLL
 *		-	FW_TIME_POSITION_CLASS_OVERLAY
 *		-	FW_TIME_POSITION_CLASS_DISPLAY
 */
- (FWTimePositionClass)timePositionClass;	   

/**
 *	Get ad instances in the slot
 *	\return An array of id<FWAdInstance>
 */
- (NSArray * /* <id>FWAdInstance */)adInstances;

/**
 *	Get width of the slot
 *	\return Width in pixels
 */
- (NSUInteger)width;

/**
 *	Get height of the slot
 *	\return Height in pixels
 */
- (NSUInteger)height;

/**
 *	Process slot event
 *	\param	eventName Event to be processed, one of FW_EVENT_SLOT_* in FWConstants.h
 */
- (void)processEvent:(NSString *)eventName;

/**
 *	Play the slot.
 *
 *	Note: MPMoviePlayerController supports only one active stream at one time.  If app uses MPMoviePlayerController for content, 
 *	For preroll/postroll, this limitation has no impact.  
 *	For midroll, recommended way is: release the content MPMoviePlayerController before midroll start, create a new 
 *	MPMoviePlayerController & reconnect content stream after midroll ends.  
 *	AVPlayer does not have this limitation. If app uses AVPlayer for content, content can be paused before midroll start and resumed after midroll end.
 */
- (void)play;

/**
 *	Stop the slot
 */
- (void)stop;

/**
 *	Get visibility of nontemporal slot. visible is YES by default.
 */
- (BOOL)visible;

/**
 *	Set the visibility for nontemporal slot. 
 *
 *	If a nontemporal slot base view is not visible on screen when playing the slot, 
 *	user should invoke setVisible(NO) before invoke play(). At the momement, ad impression does not send.
 *
 *	Once the nontemporal slot base view is visible on screen, user should invoke setVisible(YES) to send ad impression.
 *
 *	Note:
 *		Calling this method for temporal slot or after invoking play() have no effect.
 *
 *  \param  value	YES or NO
 */
- (void)setVisible:(BOOL)value;

/**
 *	Get slot base UIView object.
 *	For nontemporal slot, return value should be added as other UIView object's child.
 *	For temporal slot, return value is the object passed from -[FWContext setVideoDisplayBase:].
 */
- (UIView *)slotBase;

/**
 *	Set the parameters at slot level
 *	\param	name	key of the parameter to be set
 *	\param	value	value for the key
 */
- (void)setParameter:(NSString *)name withValue:(id)value;

/**
 *	Retrieve a parameter
 *  \param  name  The name of the parameter need to retrieve
 */
- (id)getParameter:(NSString *)name;

/**
 *	Get the total duration of all the ads
 */
- (NSTimeInterval)totalDuration;

/**
 *	Get current playback time of the slot
 */
- (NSTimeInterval)playheadTime;

/**
 *	Get current playinng AdInstance
 *	\return the AdInstance object of current playing ad in this slot. if no ad is playing on the slot when it invoked, nil will be returned.
 */
- (id<FWAdInstance>)currentAdInstance;
@end


/**
 *	Protocol for ad instance
 */
@protocol FWAdInstance <NSObject>

/**
 *	Get ad id of the ad instance
 *	This is the ad id value associated with this ad. This value can also be found in the advertising module of the FreeWheel MRM UI.
 *	\return Ad id as an unsigned int
 */
- (NSUInteger)adId;

/**
 *	Get creative id of the ad instance
 *	This is the creative id associated with this ad. The value can also be found in the advertising module of the FreeWheel MRM UI.
 *	\return Creative id as an unsigned int
 */
- (NSUInteger)creativeId;

/**
 *	Get primary rendition of the ad instance
 *	\return An id<FWCreativeRendition>
 */
- (id<FWCreativeRendition>)primaryCreativeRendition;

/**
 *	Get callback urls for specific event
 *
 *	\param	eventName	name of event, FW_EVENT_AD_*
 *	\param	eventType	type of event, FW_EVENT_TYPE_*
 *	Valid eventName/evetType pairs:
 *		- (FW_EVENT_AD_IMPRESSION,        FW_EVENT_TYPE_IMPRESSION)	-	ad impression
 *		- (FW_EVENT_AD_FIRST_QUARTILE,	  FW_EVENT_TYPE_IMPRESSION) -	firstQuartile
 *		- (FW_EVENT_AD_MIDPOINT,		  FW_EVENT_TYPE_IMPRESSION) -	midPoint
 *		- (FW_EVENT_AD_THIRD_QUARTILE,	  FW_EVENT_TYPE_IMPRESSION) -	thirdQuartile
 *		- (FW_EVENT_AD_COMPLETE,          FW_EVENT_TYPE_IMPRESSION)	-	complete
 *		- (FW_EVENT_AD_CLICK,             FW_EVENT_TYPE_CLICK)		-	click through
 *		- (FW_EVENT_AD_CLICK,             FW_EVENT_TYPE_CLICKTRACKING)	-	click tracking
 *		- ("custom_click_name",           FW_EVENT_TYPE_CLICK)			-	custom click
 *		- ("custom_click_tracking_name",  FW_EVENT_TYPE_CLICKTRACKING)	-	custom click tracking
 *		- (FW_EVENT_AD_PAUSE,             FW_EVENT_TYPE_STANDARD)		-	IAB metric, pause
 *		- (FW_EVENT_AD_RESUME,            FW_EVENT_TYPE_STANDARD)		-	IAB metric, resume
 *		- (FW_EVENT_AD_REWIND,            FW_EVENT_TYPE_STANDARD)		-	IAB metric, rewind
 *		- (FW_EVENT_AD_MUTE,              FW_EVENT_TYPE_STANDARD)		-	IAB metric, mute
 *		- (FW_EVENT_AD_UNMUTE,            FW_EVENT_TYPE_STANDARD)		-	IAB metric, unmute
 *		- (FW_EVENT_AD_COLLAPSE,          FW_EVENT_TYPE_STANDARD)		-	IAB metric, collapse
 *		- (FW_EVENT_AD_EXPAND,            FW_EVENT_TYPE_STANDARD)		-	IAB metric, expand
 *		- (FW_EVENT_AD_MINIMIZE,          FW_EVENT_TYPE_STANDARD)		-	IAB metric, minimize
 *		- (FW_EVENT_AD_CLOSE,             FW_EVENT_TYPE_STANDARD)		-	IAB metric, close
 *		- (FW_EVENT_AD_ACCEPT_INVITATION, FW_EVENT_TYPE_STANDARD)		-	IAB metric, accept invitation
 *	
 *	\return: Array of url strings
 *	
 */
- (NSArray *)getEventCallbackUrls:(NSString *)eventName :(NSString *)eventType;

/**
 *	Set callback urls for specific event
 *
 *	\param	eventName	name of event, FW_EVENT_AD_*
 *	\param	eventType	type of event, FW_EVENT_TYPE_*
 *	\param	urls		external urls to ping 
 *	Valid eventName/evetType pairs:
 *		- (FW_EVENT_AD_IMPRESSION,        FW_EVENT_TYPE_IMPRESSION)	-	ad impression
 *		- (FW_EVENT_AD_FIRST_QUARTILE,    FW_EVENT_TYPE_IMPRESSION)	-	1st quartile
 *		- (FW_EVENT_AD_MIDPOINT,          FW_EVENT_TYPE_IMPRESSION)	-	midpoint
 *		- (FW_EVENT_AD_THIRD_QUARTILE,    FW_EVENT_TYPE_IMPRESSION)	-	3rd quartile
 *		- (FW_EVENT_AD_COMPLETE,          FW_EVENT_TYPE_IMPRESSION)	-	complete
 *		- (FW_EVENT_AD_CLICK,             FW_EVENT_TYPE_CLICK)		-	click through
 *		- ("custom_click_name",           FW_EVENT_TYPE_CLICK)			-	custom click
 *		- (FW_EVENT_AD_PAUSE,             FW_EVENT_TYPE_STANDARD)		-	IAB metric, pause
 *		- (FW_EVENT_AD_RESUME,            FW_EVENT_TYPE_STANDARD)		-	IAB metric, resume
 *		- (FW_EVENT_AD_REWIND,            FW_EVENT_TYPE_STANDARD)		-	IAB metric, rewind
 *		- (FW_EVENT_AD_MUTE,              FW_EVENT_TYPE_STANDARD)		-	IAB metric, mute
 *		- (FW_EVENT_AD_UNMUTE,            FW_EVENT_TYPE_STANDARD)		-	IAB metric, unmute
 *		- (FW_EVENT_AD_COLLAPSE,          FW_EVENT_TYPE_STANDARD)		-	IAB metric, collapse
 *		- (FW_EVENT_AD_EXPAND,            FW_EVENT_TYPE_STANDARD)		-	IAB metric, expand
 *		- (FW_EVENT_AD_MINIMIZE,          FW_EVENT_TYPE_STANDARD)		-	IAB metric, minimize
 *		- (FW_EVENT_AD_CLOSE,             FW_EVENT_TYPE_STANDARD)		-	IAB metric, close
 *		- (FW_EVENT_AD_ACCEPT_INVITATION, FW_EVENT_TYPE_STANDARD)		-	IAB metric, accept invitation
 */
- (void)setEventCallbackUrls:(NSString *)eventName :(NSString *)eventType :(NSArray *)urls;

/**
 *	Add a creative rendition to the ad instance 
 *	\return the FWCreativeRendition object added to the ad instance
 */
- (id<FWCreativeRendition>)addCreativeRendition;

/**
 *	Get renderer controller of the ad instance
 *	\return An id<FWRendererController>
 */
- (id<FWRendererController>)rendererController;


/**
 *	Get the companion slots of the ad instance
 * \return an array of id<FWSlot>
 */
- (NSArray *)companionSlots;

/**
 * Get all creative renditions of the ad instance
 */
- (NSArray* /*id<FWCreativeRendition>*/)creativeRenditions;

/**
 * Set the primary creative rendition
 * \param  primaryCreativeRendition     a pointer to the primary creative rendition
 */
- (void)setPrimaryCreativeRendition:(id<FWCreativeRendition>)primaryCreativeRendition;

/**
 *	Get rendering slot
 */
- (id<FWSlot>)slot;
@end


/**
 *	Protocol for creative rendition
 */
@protocol FWCreativeRendition <NSObject>

/**
 *	Get content type of the rendition
 *	\return  Content type in a string
 */
- (NSString *)contentType;

/**
 *	Set content type of the rendition
 */
- (void)setContentType:(NSString *)value;

/**
 *	Get wrapper type of the rendition
 *	\return  Wrapper type in a string
 */
- (NSString *)wrapperType;

/**
 *	Set wrapper type of the rendition
 */
- (void)setWrapperType:(NSString *)value;

/**
 *	Get wrapper url of the rendition
 *	\return  Wrapper url in a string
 */
- (NSString *)wrapperUrl;

/**
 *	Set wrapper url of the rendition
 */
- (void)setWrapperUrl:(NSString *)value;

/**
 *	Get creativeAPI of the rendition
 *	\return  creativeAPI in a string
 */
- (NSString *)creativeAPI;

/**
 *	Set creativeAPI of the rendition
 */
- (void)setCreativeAPI:(NSString *)value;

/**
 *	Get base unit of the rendition
 *	\return Base unit in a string
 */
- (NSString *)baseUnit;

/**
 *	Get preference of the rendition
 *	\return A number, the higher is preferred among all renditions in the creative
 */
- (int)preference;

/**
 *	Set preference of the rendition
 */
- (void)setPreference:(int)value;

/**
 *	Get width of the rendition
 *	\return Width in pixels
 */
- (NSUInteger)width;

/**
 *	Set width of the rendition
 */
- (void)setWidth:(NSUInteger)value;

/**
 *	Get height of the rendition
 *	\return Height in pixels
 */
- (NSUInteger)height;

/**
 *	Set height of the rendition
 */
- (void)setHeight:(NSUInteger)value;

/**
 *	Get duration of the rendition
 *	\return Duration in seconds
 */
- (NSTimeInterval)duration;

/**
 *	Set duration of the rendition
 *	\return Duration in seconds
 */
- (void)setDuration:(NSTimeInterval)value;

/**
 *	Set parameter of the rendition
 */
- (void)setParameter:(NSString *)name :(NSString *)value;

/**
 *	Get primary asset of the rendition
 *	\return An id<FWCreativeRenditionAsset>
 */
- (id<FWCreativeRenditionAsset>)primaryCreativeRenditionAsset;

/**
 *	Get all non-primary assets of the rendition
 *	\return An array of id<FWCreativeRenditionAsset>
 */
- (NSArray * /* <id>FWCreativeRenditionAsset */)otherCreativeRenditionAssets;

/**
 *	Add an asset to the rendition
 */
- (id<FWCreativeRenditionAsset>)addCreativeRenditionAsset;
@end


/**
 *	Protocol for creative rendition asset
 */
@protocol FWCreativeRenditionAsset <NSObject>
/**
 *	Get name of the asset
 *	\return Name in a string
 */
- (NSString *)name;

/**
 *	Set name of the asset
 */
- (void)setName:(NSString *)value;

/**
 *	Get URL of the asset
 *	\return URL in a string
 */
- (NSString *)url;

/**
 *	Set URL of the asset
 */
- (void)setUrl:(NSString *)value;

/**
 *	Get content of the asset
 *	\return Content in a string
 */
- (NSString *)content;

/**
 *	Set the content of the asset
 */
- (void)setContent:(NSString *)value;

/**
 *	Get mime type of the asset
 *	\return Mime type in a string
 */
- (NSString *)mimeType;

/**
 *	Set mime type of the asset
 */
- (void)setMimeType:(NSString *)value;

/**
 *	Get content type of the asset
 *	\return Content type in a string
 */
- (NSString *)contentType;

/**
 *	Set content type of the asset
 */
- (void)setContentType:(NSString *)value;

/**
 *	Get size of the asset
 *	\return Size in bytes, or -1 if unknown
 */
- (NSInteger)bytes;

/**
 *	Set size of the asset
 *	\return Size in bytes, or -1 if unknown
 */
- (void)setBytes:(NSInteger)value;
@end


/**
 *	Protocol for a renderer to send information
 *	The FWRendererController provides methods that can be used to indicate the occurrence of metric events and change renderer state.
 */
@protocol FWRendererController <NSObject>

/**
 *  Return the current location of FWAdManager objects for geo targeting.
 *  Player sets it via -[FWAdManager setLocation:].
 */
- (CLLocation *)location;

/**
 *	Return application's current view controller for presenting fullscreen ad views. Player sets it via -[FWAdManager setCurrentViewController:].
 *
 */
- (UIViewController *)currentViewController;

/**
 *	Return the main video's MPMoviePlayerController object. Player sets it via -[FWContext setMoviePlayerController:].
 *	Video ad renderer renderers upon it.
 *
 *	Availability: iOS >= 3.2 
 */
- (MPMoviePlayerController *)moviePlayerController;

/**
 *	Return the main video's fullscreen state. Player sets it via -[FWContext setMoviePlayerFullscreen:].
 *
 *	Availability: iOS >= 3.2 
 */
- (BOOL)moviePlayerFullscreen;

/**
 *	Process renderer event
 *	\param	eventName Event to be processed, one of FW_EVENT_AD_* in FWConstants.h
 *  \param  details  The addtional infomation need to be processed by AdManager. Available keys:
 * 					- FW_INFO_KEY_CUSTOM_EVENT_NAME Optional. 
 * 					When eventName is FW_EVENT_AD_CLICK, renderer tells the custom click event to be processed via this key.
 * 					- FW_INFO_KEY_SHOW_BROWSER Optional. 
 * 					Force opening/not openning the event callback url in new app.
 * 					If this key is not provided, AdManager use the setting booked in MRM UI (recommanded).
 */
- (void)processEvent:(NSString *)eventName info:(NSDictionary *)details;

/**
 *	Declare capability of the renderer
 *	\param	eventCapability One of FW_EVENT_AD_* (NOT including FW_EVENT_AD_FIRST_QUARTILE, FW_EVENT_AD_THIRD_QUARTILE, FW_EVENT_AD_IMPRESSION) in FWConstants.h
 *	\param	status True if renderer has specified capability or is able to send specified event
 *
 *	Note: \n
 *	Changing renderer capability after renderer starts playing may result undefined behaviour
 */
- (void)setCapability:(NSString *)eventCapability :(FWCapabilityStatus)status;

/**
 *	Renturn the Major version of AdManager, e.g. 0x02060000 for v2.6
 */
- (NSUInteger)version;

/**
 *	Retrieve a parameter
 *  \param  name  The name of the parameter need to retrieve
 */
- (id)getParameter:(NSString *)name;

/**
 * Get rendering ad instance
 */
- (id<FWAdInstance>)adInstance;

/**
 * Change state for current renderer
 * \param  state	target transition state demanded, available values:
 * 					- FW_RENDERER_STATE_STARTED
 * 					- FW_RENDERER_STATE_COMPLETED
 * 					- FW_RENDERER_STATE_FAILED
 * \param  details	detail info to be passed
 * 					- For FW_RENDERER_STATE_FAILED:FW_INFO_KEY_ERROR_CODE are required. FW_INFO_KEY_ERROR_INFO is optional.
 */
- (void)handleStateTransition:(FWRendererStateType)state info:(NSDictionary *)details;

/**
 *	Return id<FWContext> object, which can be used to listen notification using it's notificationCenter
 *  and as the sender of any notification which renderer need to post
 *
 *	Note: \n
 *	for post a notification: \n
 *	[[[rendererController notificationContext] notificationCenter] postNotificationName:EVENT_NAME object:[_rendererController notificationContext] userInfo:nil]; \n
 *	for listen a notification: \n
 *	[[[rendererController notificationContext] notificationCenter] addObserver:self selector:@selector(handler) name:EVENT_NAME object:nil];
 */
- (id<FWContext>)notificationContext;

/**
 *	Schedule ad instances for the given slots.
 */
- (NSArray * /* id<FWAdInstance> */)scheduleAdInstances:(NSArray * /* id<FWSlot> */)slots;

/**
 *	Renderer can use this to request main video to pause or resume, the notification sender is current FWContext object
 */
- (void)requestContentStateChange:(BOOL)pause;

/**
 *  Renderer should use this API to trace all logs
 */
- (void)log:(NSString *)msg;
@end


/**
 *	Protocol for FWRenderer
 */
@protocol FWRenderer <NSObject>
/**
 *	Notify the renderer to initialize.
 *	
 *	\param	rendererController	reference to id<FWRendererController>
 *		
 *	Note:
 *		Typically the renderer will declare all available capabilities and events when receive this notification.
 */
- (id)initWithRendererController:(id<FWRendererController>)rendererController;

/**
 *	Notify the renderer to start ad playback.
 *	
 *	Note:
 *		The renderer should start the ad playback when receive this notification,
 *		and transit to FW_RENDERER_STATE_STARTED state as soon as ad is actually playing.
 *		
 *		When an ad stops either by user action or just for it ends, the renderer should
 *		transit to FW_RENDERER_STATE_COMPLETED state as soon as ad is actually stopped.
 */
- (void)start;

/**
 *	Notify the renderer to stop.
 *
 *	Note:
 *		Typically the renderer will dispose playing images/videos from screen when receive this notificaiton.
 */
- (void)stop;

/**
 *	Get module info. The returned dictionary should contain key FW_INFO_KEY_MODULE_TYPE with FW_MODULE_TYPE_* value,
 *  and should contain key FW_INFO_KEY_REQUIRED_API_VERSION with the FreeWheel RDK version when the component compiled.
 */
- (NSDictionary *)moduleInfo;


/**
 *	Get the ad duration
 */
- (NSTimeInterval)duration;

/**
 *	Get the ad current playback time
 */
- (NSTimeInterval)playheadTime;
@end

