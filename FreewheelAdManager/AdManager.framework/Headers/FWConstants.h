/** 
 * \file FWConstants.h
 * \brief Constants in FreeWheel AdManager SDK
 */

#ifndef FW_EXTERN
#ifdef __cplusplus
#define FW_EXTERN           extern "C"
#define FW_PRIVATE_EXTERN   __private_extern__
#else
#define FW_EXTERN           extern
#define FW_PRIVATE_EXTERN   __private_extern__
#endif

#define FW_LINK_RENDERER(r) \
@class r; \
extern void FWAdManager_Force_Link_##r (void) __attribute__ ((constructor)); \
void FWAdManager_Force_Link_##r (void) { \
NSLog(@"AdManager: registering renderer class: %@", [r description]); \
}

#endif

typedef enum {
	FW_LOG_LEVEL_QUIET						=	0,
	FW_LOG_LEVEL_INFO
} FWLogLevel;

/**
 * Enumeration of non-temporal slot ad initial options
 */
typedef enum {
	/** Display an ad in the non-temporal slot */
	FW_SLOT_OPTION_INITIAL_AD_STAND_ALONE						=	0,
	/** Keep the original ad in the non-temporal slot */
	FW_SLOT_OPTION_INITIAL_AD_KEEP_ORIGINAL						=	1,	
	/** Use the non-temporal ad in the first companion ad package */
	FW_SLOT_OPTION_INITIAL_AD_FIRST_COMPANION_ONLY				=	2,
	/** Either FW_SLOT_OPTION_INITIAL_AD_FIRST_COMPANION_ONLY or FW_SLOT_OPTION_INITIAL_AD_STAND_ALONE  */
	FW_SLOT_OPTION_INITIAL_AD_FIRST_COMPANION_OR_STAND_ALONE	=	3
} FWInitialAdOption;

/**
 * Enumeration of capability status
 */
typedef enum {
	/** Capability status is off */
	FW_CAPABILITY_STATUS_OFF					=	0,
	/** Capability status is on */
	FW_CAPABILITY_STATUS_ON						=	1,	
	/** Capability status is default */
	FW_CAPABILITY_STATUS_DEFAULT				=	-1
} FWCapabilityStatus;

/**
 * Enumeration of id types
 */
typedef enum {
	/** Custom id provided by non-FreeWheel parties */
	FW_ID_TYPE_CUSTOM							=	0,
	/** Unique id provided by FreeWheel */
	FW_ID_TYPE_FW								=	1,	
	/** Unique group id provided by FreeWheel */
	FW_ID_TYPE_FWGROUP							=	2
} FWIdType;

/**
 * Enumeration of current video states
 */
typedef enum {
	/** Current video is playing */
	FW_VIDEO_STATE_PLAYING						=	1,	
	/** Current video is paused */
	FW_VIDEO_STATE_PAUSED						=	2,
	/** Current video is stopped */
	FW_VIDEO_STATE_STOPPED						=	3,
	/** Current video is completed */
	FW_VIDEO_STATE_COMPLETED					=	4
} FWVideoState;

/**
 * Enumeration of time position classes
 */
typedef enum {
	/** Time position class type: preroll */
	FW_TIME_POSITION_CLASS_PREROLL				=	1,	
	/** Time position class type: midroll */
	FW_TIME_POSITION_CLASS_MIDROLL				=	2,
	/** Time position class type: postroll */
	FW_TIME_POSITION_CLASS_POSTROLL				=	3,
	/** Time position class type: overlay */
	FW_TIME_POSITION_CLASS_OVERLAY				=	4,
	/** Time position class type: display */
	FW_TIME_POSITION_CLASS_DISPLAY				=	5
} FWTimePositionClass;

/**
 * Enumeration of slot types
 */
typedef enum {
	/** Type of slot: temporal slot */
	FW_SLOT_TYPE_TEMPORAL						=	1,	
	/** Type of slot: non-temporal slot in video player */
	FW_SLOT_TYPE_VIDEOPLAYER_NONTEMPORAL		=	2,
	/** Type of slot: non-temporal slot in site section */
	FW_SLOT_TYPE_SITESECTION_NONTEMPORAL		=	3
} FWSlotType;

/**
 * Enumeration of parameter level
 */
typedef enum {
	/** profile level param */
	FW_PARAMETER_LEVEL_PROFILE					=	0,	
	/** global level param */
	FW_PARAMETER_LEVEL_GLOBAL					=	1,	
	/** slot level param */
	FW_PARAMETER_LEVEL_SLOT						=	2,
	/** creative level param */
	FW_PARAMETER_LEVEL_CREATIVE					=	3,
	/** rendition level param */
	FW_PARAMETER_LEVEL_RENDITION				=	4,
	/** override level param, highest priority */
	FW_PARAMETER_LEVEL_OVERRIDE					=	5
} FWParameterLevel;

/**
 * Enumeration of FWRendererState types
 */
typedef enum {
	/** Renderer State started, if renderer actually started */
	FW_RENDERER_STATE_STARTED					=	3,
	/** Renderer State completed, if renderer done the clean up and ready to be disposed, should change to this state */
	FW_RENDERER_STATE_COMPLETED					=	5,
	/** Renderer State failed */
	FW_RENDERER_STATE_FAILED					=	6
} FWRendererStateType;

/**
 * Enumeration of RequestMode types
 */
typedef enum {
	/** Request Mode onDemand */
	FW_REQUEST_MODE_ON_DEMAND				=	1,	
	/** Request Mode live */
	FW_REQUEST_MODE_LIVE					=	2
} FWRequestMode;

/**
 * Enumeration of video asset duration types
 */
typedef enum {
	/** Video Asset duration type exact */
	FW_VIDEO_ASSET_DURATION_TYPE_EXACT				=	1,	
	/** Video Asset duration type variable for live mode */
	FW_VIDEO_ASSET_DURATION_TYPE_VARIABLE			=	2
} FWVideoAssetDurationType;

/**
 * Enumeration of video asset auto play types
 */
typedef enum {
    
	/** Video Asset auto play type none */
	FW_VIDEO_ASSET_AUTO_PLAY_TYPE_NONE	= 0,
	/** Video Asset auto play type attended*/
	FW_VIDEO_ASSET_AUTO_PLAY_TYPE_ATTENDED	=	1,	
	/** Video Asset auto play type unattended */
	FW_VIDEO_ASSET_AUTO_PLAY_TYPE_UNATTENDED =	2
} FWVideoAssetAutoPlayType;

/** 
 *	AdManager publishes notification of this topic after ad request completed with info:
 *	FW_INFO_KEY_ERROR		-	a NSArray of NSError, optional
 */
FW_EXTERN NSString *const FW_NOTIFICATION_REQUEST_COMPLETE;

/** 
 *	AdManager publishes notification of this topic before slot started with info:
 *	FW_INFO_KEY_CUSTOM_ID	-	slot custom id
 */
FW_EXTERN NSString *const FW_NOTIFICATION_SLOT_STARTED;

/** 
 *	AdManager publishes notification of this topic after slot ended with info:
 *	FW_INFO_KEY_CUSTOM_ID	-	slot custom id
 */
FW_EXTERN NSString *const FW_NOTIFICATION_SLOT_ENDED; 

/** 
 *	AdManager publishes notification of this topic when in-app view opened 
 */
FW_EXTERN NSString *const FW_NOTIFICATION_IN_APP_VIEW_OPEN;

/** 
 *	AdManager publishes notification of this topic when in-app view closed 
 */
FW_EXTERN NSString *const FW_NOTIFICATION_IN_APP_VIEW_CLOSE;
/** 
 *	AdManager publishes notification of this topic when in-app view will open media document 
 */
FW_EXTERN NSString *const FW_NOTIFICATION_IN_APP_VIEW_WILL_OPEN_MEDIA_DOCUMENT;

/** 
 *	AdManager publishes notification of this topic when ad needs to pause the main content video
 *	FW_INFO_KEY_CUSTOM_ID		-	slot
 */
FW_EXTERN NSString *const FW_NOTIFICATION_CONTENT_PAUSE_REQUEST;

/** 
 *	AdManager publishes notification of this topic when ad needs to resume the main content video
 *	FW_INFO_KEY_CUSTOM_ID		-	slot
 */
FW_EXTERN NSString *const FW_NOTIFICATION_CONTENT_RESUME_REQUEST;


/** 
 *	Player sends notification of this topic after video display base is changed by setVideoDisplayBase
 *	FW_INFO_KEY_VIDEO_DISPLAY_BASE		-	key of video display base object
 */
FW_PRIVATE_EXTERN NSString *FW_NOTIFICATION_VIDEO_DISPLAY_BASE_CHANGED;

/** 
 *	Player sends notification of this topic after size of video display base is changed
 *	FW_INFO_KEY_VIDEO_DISPLAY_BASE		-	key of video display base object
 */
FW_PRIVATE_EXTERN NSString *FW_NOTIFICATION_VIDEO_DISPLAY_BASE_FRAME_CHANGED;



/**
 * Predefined ad unit: preroll
 *
 * See Also:
 *	- FW_ADUNIT_MIDROLL
 *	- FW_ADUNIT_POSTROLL
 *	- FW_ADUNIT_OVERLAY
 *  - FW_ADUNIT_STREAM_PREROLL
 *  - FW_ADUNIT_STREAM_POSTROLL
 */
FW_EXTERN NSString *const FW_ADUNIT_PREROLL; 

/**
 * Predefined ad unit: midroll
 * 
 * See Also:
 *	- FW_ADUNIT_PREROLL
 *	- FW_ADUNIT_POSTROLL
 *	- FW_ADUNIT_OVERLAY
 *  - FW_ADUNIT_STREAM_PREROLL
 *  - FW_ADUNIT_STREAM_POSTROLL
 */
FW_EXTERN NSString *const FW_ADUNIT_MIDROLL; 

/**
 * Predefined ad unit: postroll
 *
 * See Also:
 *	- FW_ADUNIT_PREROLL
 *	- FW_ADUNIT_MIDROLL
 *	- FW_ADUNIT_OVERLAY
 *  - FW_ADUNIT_STREAM_PREROLL
 *  - FW_ADUNIT_STREAM_POSTROLL
 */
FW_EXTERN NSString *const FW_ADUNIT_POSTROLL; 

/**
 * Predefined ad unit: overlay
 *
 * See Also:
 *	- FW_ADUNIT_PREROLL
 *	- FW_ADUNIT_MIDROLL
 *	- FW_ADUNIT_POSTROLL
 *  - FW_ADUNIT_STREAM_PREROLL
 *  - FW_ADUNIT_STREAM_POSTROLL
 */
FW_EXTERN NSString *const FW_ADUNIT_OVERLAY;

/**
 *	Predefined ad unit: preroll of a STREAM
 *	
 *	See Also:
 *	- FW_ADUNIT_PREROLL
 *	- FW_ADUNIT_MIDROLL
 *	- FW_ADUNIT_POSTROLL
 *	- FW_ADUNIT_OVERLAY
 *  - FW_ADUNIT_STREAM_POSTROLL
 */
FW_EXTERN NSString *const FW_ADUNIT_STREAM_PREROLL;

/**
 *	Predefined ad unit: postroll of a STREAM
 *	
 *	See Also:
 *	- FW_ADUNIT_PREROLL
 *	- FW_ADUNIT_MIDROLL
 *	- FW_ADUNIT_POSTROLL
 *	- FW_ADUNIT_OVERLAY
 *  - FW_ADUNIT_STREAM_PREROLL
 */
FW_EXTERN NSString *const FW_ADUNIT_STREAM_POSTROLL;

/**
 *	Player expects template-based slots generated by ad server
 *	
 *	Note:
 *		This is on by default
 */
FW_EXTERN NSString *const FW_CAPABILITY_SLOT_TEMPLATE; 

/**
 *	Ad unit in multiple slots
 *
 *	Note:
 *		This is on by default
 */
FW_EXTERN NSString *const FW_CAPABILITY_ADUNIT_IN_MULTIPLE_SLOTS; 

/**
 * Bypass commercial ratio restriction
 */
FW_EXTERN NSString *const FW_CAPABILITY_BYPASS_COMMERCIAL_RATIO_RESTRICTION; 

/**
 *	Player expects ad server to check companion for candidate ads 
 *
 *	Note:
 *		This is on by default
 */
FW_EXTERN NSString *const FW_CAPABILITY_CHECK_COMPANION; 

/**
 *	Player expects ad server to check targeting for candidate ads 
 */
FW_EXTERN NSString *const FW_CAPABILITY_CHECK_TARGETING; 

/**
 *	SDK internal use
 */
FW_EXTERN NSString *const FW_CAPABILITY_REQUIRES_VIDEO_CALLBACK_URL; 

/**
 *	SDK internal use
 */
FW_EXTERN NSString *const FW_CAPABILITY_SLOT_CALLBACK; 

/**
 *	SDK internal use
 */
FW_EXTERN NSString *const FW_CAPABILITY_SKIP_AD_SELECTION; 

/**
 *	Whether or not video view will be recorded implicitly.
 */
FW_EXTERN NSString *const FW_CAPABILITY_RECORD_VIDEO_VIEW; 

/**
 *	Player expects ad server synchronize the request state between multiple request 
 */
FW_EXTERN NSString *const FW_CAPABILITY_SYNC_MULTI_REQUESTS;

/**
 *	Reset the exclusivity scope. Player can turn on/off this capability before making any request.
 *	
 *	    Notes:
 *	      Once you turn this capability ON, all following requests will carry this signal and reset the exclusivity scope.
 *	      So make sure to turn it off when exclusivity scope has been reset (the request has been submit).
 */
FW_EXTERN NSString *const FW_CAPABILITY_RESET_EXCLUSIVITY;

/**
 *	Player expects ad should have a list of fallback alternative ads.
 *	
 *	Note:
 *		This is on by default
 */
FW_EXTERN NSString *const FW_CAPABILITY_FALLBACK_ADS;

/**
*	Player expects multiple creative renditions for an ad.
*	
*	Note:
*		This is on by default
*/
FW_EXTERN NSString *const FW_CAPABILITY_MULTIPLE_CREATIVE_RENDITIONS;

/**
 *	Event name: slot impression
 */
FW_EXTERN NSString *const FW_EVENT_SLOT_IMPRESSION;

/**
 *	Event name: ad impression
 */
FW_EXTERN NSString *const FW_EVENT_AD_IMPRESSION;

/**
 *	Event name: ad quartile
 */
FW_EXTERN NSString *const FW_EVENT_AD_QUARTILE;

/**
 *	Event name: ad first quartile	
 */
FW_EXTERN NSString *const FW_EVENT_AD_FIRST_QUARTILE;

/**
 *	Event name: ad midroll 
 */
FW_EXTERN NSString *const FW_EVENT_AD_MIDPOINT;

/**
 *	Event name: ad third quartile	
 */
FW_EXTERN NSString *const FW_EVENT_AD_THIRD_QUARTILE;

/**
 *	Event name: ad complete
 */
FW_EXTERN NSString *const FW_EVENT_AD_COMPLETE;

/**
 *	Event name: ad click
 */
FW_EXTERN NSString *const FW_EVENT_AD_CLICK;

/**
 *	Event name: ad mute
 */
FW_EXTERN NSString *const FW_EVENT_AD_MUTE;

/**
 *	Event name: ad unmute
 */
FW_EXTERN NSString *const FW_EVENT_AD_UNMUTE;

/**
 *	Event name: ad collapse 
 */
FW_EXTERN NSString *const FW_EVENT_AD_COLLAPSE;

/**
 *	Event name: ad expand
 */
FW_EXTERN NSString *const FW_EVENT_AD_EXPAND;

/**
 *	Event name: ad pause
 */
FW_EXTERN NSString *const FW_EVENT_AD_PAUSE;

/**
 *	Event name: ad resume
 */
FW_EXTERN NSString *const FW_EVENT_AD_RESUME;

/**
 *	Event name: ad rewind
 */
FW_EXTERN NSString *const FW_EVENT_AD_REWIND;

/**
 *	Event name: ad accept invitation
 */
FW_EXTERN NSString *const FW_EVENT_AD_ACCEPT_INVITATION;

/**
 *	Event name: ad close
 */
FW_EXTERN NSString *const FW_EVENT_AD_CLOSE;

/**
 *	Event name: ad minimize
 */
FW_EXTERN NSString *const FW_EVENT_AD_MINIMIZE;

/**
 *	Event name: error
 */
FW_EXTERN NSString *const FW_EVENT_ERROR;

/**
 *	Event name: reseller_no_ad
 */
FW_EXTERN NSString *const FW_EVENT_RESELLER_NO_AD;

/**
 *	Event type: click tracking
 */
FW_EXTERN NSString *const FW_EVENT_TYPE_CLICK_TRACKING; 

/**
 *	Event type: impresssion
 */
FW_EXTERN NSString *const FW_EVENT_TYPE_IMPRESSION; 

/**
 *	Event type: click 
 */
FW_EXTERN NSString *const FW_EVENT_TYPE_CLICK; 

/**
 *	Event type: standard
 */
FW_EXTERN NSString *const FW_EVENT_TYPE_STANDARD;

/**
 *  The way of opening http(s) url: inside app or by external app. NSString "YES, NO" are valid. By default, it is YES.
 */
FW_EXTERN NSString *const FW_PARAMETER_OPEN_IN_APP;

/**
 *  The key of defaultClickFWViewWidth parameter, this parameter can only be set before the slot play, otherwise no effect
 */
FW_EXTERN NSString *const FW_PARAMETER_CLICK_VIEW_WIDTH;

/**
 *  The key of defaultClickFWViewHeight parameter, this parameter can only be set before the slot play, otherwise no effect
 */
FW_EXTERN NSString *const FW_PARAMETER_CLICK_VIEW_HEIGHT;

/**
 *  The key of display ad renderer HTML content click processing enabled parameter. NSString @"YES", @"NO" are valid. Default is @"NO".
 */
FW_EXTERN NSString *const FW_PARAMETER_DISPLAY_AD_HTML_CONTENT_CLICK_PROCESSING;

/**
 *  The key of inAppView close button enable delay time parameter, in seconds. Default is 3 secs.
 */
FW_EXTERN NSString *const FW_PARAMETER_IN_APP_VIEW_LOADING_TIMEOUT;

/**
 *  The key of InAppView ToolBar surface render parameter. \n
 *  The value of the parameter is a string of Html5 which will be injected into the surface web page of the ToolBar .\n
 *  The following template is suggested to use:\n
 *  \n
 *  \<div\>\n
 *       \<div style=\"\"\>\<img ID=\"<b>FW_IN_APP_VIEW_CONTROL_BAR_BACK_BUTTON</b>\"  src=\"data:image/png;base64,<b><i>PNG_BASE64_STRING</i></b>\" width=\"\" height=\"\"/\>\</div\>\n
 *       \<div style=\"\"\>\<img ID=\"<b>FW_IN_APP_VIEW_CONTROL_BAR_FORWARD_BUTTON</b>\"  src=\"data:image/png;base64,<b><i>PNG_BASE64_STRING</i></b>\" width=\"\" height=\"\"/\>\</div\>\n
 *       \<div style=\"\"\>\<img ID=\"<b>FW_IN_APP_VIEW_CONTROL_BAR_CLOSE_BUTTON</b>\"  src=\"data:image/png;base64,<b><i>PNG_BASE64_STRING</i></b>\" width=\"\" height=\"\"/\>\</div\>\n
 *  \</div\>\n
 *  \n
 *  The <b>FW_IN_APP_VIEW_CONTROL_BAR_BACK_BUTTON</b>, <b>FW_IN_APP_VIEW_CONTROL_BAR_FORWARD_BUTTON</b> and <b>FW_IN_APP_VIEW_CONTROL_BAR_CLOSE_BUTTON</b> IDs have to be kept as such for handling event.\n
 *  The all three <b><i>PNG_BASE64_STRING</i></b>s are replaced one by one with each png's base64 string.\n
 *  The size of img tag and alignment of div tag have to be set properly, e.g. div style can make the close button right aligned.\n
 *  All Safari mobile compatible html5 tag used in body tag are supported, e.g. utilizing table tag to manage layout instead of div tag.
 */
FW_EXTERN NSString *const FW_PARAMETER_IN_APP_VIEW_TOOLBAR_SURFACE_RENDER;

/**
 *  The key of inAppView navigation bar background color. The value of this property is a NSString in the range 0 to 0xffffff. Both integer and hexadecimal are accpeted, for example 256, 0xffffff
 */
FW_EXTERN NSString *const FW_PARAMETER_IN_APP_VIEW_NAVIGATION_BAR_BACKGROUND_COLOR;

/**
 *  The key of inAppView navigation bar alpha parameter. The value of this property is a NSString in the range 0.0 to 1.0, where 0.0 represents totally transparent and 1.0 represents totally opaque. Default is 1.0
 */
FW_EXTERN NSString *const FW_PARAMETER_IN_APP_VIEW_NAVIGATION_BAR_ALPHA;

/**
 *  The key of inAppView navigation bar height. The value of this property is a NSString in the range 0% to 100%, comparing to screen height. 
 */
FW_EXTERN NSString *const FW_PARAMETER_IN_APP_VIEW_NAVIGATION_BAR_HEIGHT;

/**
 *  The key of inAppView webview background color. The value of this property is a NSString in the range 0 to 0xffffff. Default is 0xffffff. Both integer and hexadecimal are accpeted, for example 256, 0xffffff
 */
FW_EXTERN NSString *const FW_PARAMETER_IN_APP_VIEW_WEB_VIEW_BACKGROUND_COLOR;

/**
 *  The key of inAppView webview alpha parameter. The value of this property is a NSString in the range 0.0 to 1.0, where 0.0 represents totally transparent and 1.0 represents totally opaque. Default is 1.0
 */
FW_EXTERN NSString *const FW_PARAMETER_IN_APP_VIEW_WEB_VIEW_ALPHA;

/**
 *	Parameter key. The value of FW_PARAMETER_VIDEO_AD_SCALING_MODE is one of: 
 *	- FW_PARAMETER_VIDEO_AD_SCALING_MODE_NONE
 *	- FW_PARAMETER_VIDEO_AD_SCALING_MODE_ASPECT_FIT
 *	- FW_PARAMETER_VIDEO_AD_SCALING_MODE_ASPECT_FILL
 *	- FW_PARAMETER_VIDEO_AD_SCALING_MODE_FILL
 */
FW_EXTERN NSString *const FW_PARAMETER_VIDEO_AD_SCALING_MODE;
FW_EXTERN NSString *const FW_PARAMETER_VIDEO_AD_SCALING_MODE_NONE;
FW_EXTERN NSString *const FW_PARAMETER_VIDEO_AD_SCALING_MODE_ASPECT_FIT;
FW_EXTERN NSString *const FW_PARAMETER_VIDEO_AD_SCALING_MODE_ASPECT_FILL;
FW_EXTERN NSString *const FW_PARAMETER_VIDEO_AD_SCALING_MODE_FILL;

/**
 * The key of using application audio session for video ad renderer. NSString @"YES", @"NO" are valid. Default is @"NO". 
 */
FW_EXTERN NSString *const FW_PARAMETER_VIDEO_AD_USE_APPLICATION_AUDIO_SESSION;

/**
 *  The key of countdownTimer display parameter. NSString @"YES", @"NO" are valid. Default is @"NO". This parameter can only be set before the slot play, otherwise no effect
 */
FW_EXTERN NSString *const FW_PARAMETER_COUNTDOWN_TIMER_DISPLAY;

/**
 *  The key of countdownTimer refresh interval parameter, in milliseconds, should be under 1000(included). The value of this parameter is a NSString. Default is 300. This parameter can only be set before the slot play, otherwise no effect
 */
FW_EXTERN NSString *const FW_PARAMETER_COUNTDOWN_TIMER_REFRESH_INTERVAL;

/**
 *  The key of countdownTimer js update callback function name parameter. The value of this parameter is a NSString. Default is "updateTimer". This parameter can only be set before the slot play, otherwise no effect
 *		Notes :
 The javascript update callback function should be responsible for displaying countdownTimer content. It can recieve two parameters: playheadTime, duration. They are calculated in seconds.
 */
FW_EXTERN NSString *const FW_PARAMETER_COUNTDOWN_TIMER_UPDATE_CALLBACK;

/**
 *  The key of countdownTimer position parameter. NSString "bottom", "top", "x,y" are valid. This parameter can only be set before the slot play, otherwise no effect
 *		Notes :
 *			If you want fix the countdownTimer at a point relative to the player, you can set this parameter to "x,y" which means a point, such as "20, 20".
 */
FW_EXTERN NSString *const FW_PARAMETER_COUNTDOWN_TIMER_POSITION;

/**
 *  The key of countdownTimer alpha parameter. The value of this property is a NSString in the range 0.0 to 1.0, where 0.0 represents totally transparent and 1.0 represents totally opaque. Default is 1.0. This parameter can only be set before the slot play, otherwise no effect
 */
FW_EXTERN NSString *const FW_PARAMETER_COUNTDOWN_TIMER_ALPHA;

/**
 *  The key of countdownTimer height parameter. The value of this property is a NSString bigger than 0. Default is 20. This parameter can only be set before the slot play, otherwise no effect
 */
FW_EXTERN NSString *const FW_PARAMETER_COUNTDOWN_TIMER_HEIGHT;

/**
 *  The key of countdownTimer width parameter. The value of this property is a NSString. Default is equal to the screen width. This parameter can only be set before the slot play, otherwise no effect
 */
FW_EXTERN NSString *const FW_PARAMETER_COUNTDOWN_TIMER_WIDTH;

/**
 *  The key of countdownTimer text size parameter. The value of this property is a NSString. Default is "medium". This parameter can only be set before the slot play, otherwise no effect
 */
FW_EXTERN NSString *const FW_PARAMETER_COUNTDOWN_TIMER_TEXT_SIZE;

/**
 *  The key of countdownTimer background color parameter. The value of this property is a NSString in the range 0 to 0xffffff. Both integer and hexadecimal are accpeted, for example 256, 0xffffff. Default is 0x4a4a4a. This parameter can only be set before the slot play, otherwise no effect
 */
FW_EXTERN NSString *const FW_PARAMETER_COUNTDOWN_TIMER_BG_COLOR;

/**
 *  The key of countdownTimer font color parameter. The value of this property is a NSString in the range 0 to 0xffffff. Default is 0xffffff. This parameter can only be set before the slot play, otherwise no effect
 */
FW_EXTERN NSString *const FW_PARAMETER_COUNTDOWN_TIMER_FONT_COLOR;

/**
 *  The key of countdownTimer text font parameter. The value of this property is a NSString. Default is "Arial". This parameter can only be set before the slot play, otherwise no effect
 */
FW_EXTERN NSString *const FW_PARAMETER_COUNTDOWN_TIMER_TEXT_FONT;

/**
 *  The key of countdownTimer html parameter. The value of this property is a NSString. We will provide a default timer display html by default. This parameter can only be set before the slot play, otherwise no effect
 *		Notes:
 *			If you set this parameter by yourself, it should contains a javascript method used to display the countdownTimer content. 
 *			You need to set this javascript function name to the parameter FW_PARAMETER_COUNTDOWN_TIMER_UPDATE_CALLBACK.
 */
FW_EXTERN NSString *const FW_PARAMETER_COUNTDOWN_TIMER_HTML;

/**
 *  Transparency of nontemporal slot background. NSString "YES, NO" are valid values. By default, it is NO (opaque).
 */
FW_EXTERN NSString *const FW_PARAMETER_TRANSPARENT_BACKGROUND;

/**
 *  Track the visibility of nontemporal slot automatically. When a nontemporal slot is visible, it will be played immediately. 
 *  NSString "YES, NO" are valid values. By default, it is NO.
 */
FW_EXTERN NSString *const FW_PARAMETER_NONTEMPORAL_SLOT_VISIBILITY_AUTO_TRACKING;

/**
 *  Key of FW_NOTIFICATION_REQUEST_COMPLETE notification's userInfo dictionary.
 */
FW_EXTERN NSString *const FW_INFO_KEY_ERROR;

/**
 *  Key of FW_NOTIFICATION_SLOT_STARTED & FW_NOTIFICATION_SLOT_ENDED notification's userInfo dictionary. Its value is slot's custom id.
 */
FW_EXTERN NSString *const FW_INFO_KEY_CUSTOM_ID;

/**
 *  Key of the dictionary returned by -[FWRenderer moduleInfo]. Its value is FW_MODULE_TYPE_*
 */
FW_EXTERN NSString *const FW_INFO_KEY_MODULE_TYPE;

/**
 *  Key of the dictionary returned by =[FWRenderer moduleInfo]. 
 *  optional, if present, its value should be the lowest SDK API version the renderer can compatible
 *  e.g. 0x02060000 for v2.6
 */
FW_EXTERN NSString *const FW_INFO_KEY_REQUIRED_API_VERSION;

/**
 *  Value for key FW_INFO_KEY_MODULE_TYPE 
 */
FW_EXTERN NSString *const FW_MODULE_TYPE_RENDERER;

/**
 *  Value for key FW_INFO_KEY_MODULE_TYPE 
 */
FW_EXTERN NSString *const FW_MODULE_TYPE_TRANSLATOR;

/**
 *  Key of the info dictionary in -[FWRendererController handleStateTransition:FW_RENDERER_STATE_FAILED info:details]. 
 *  Its value is FW_ERROR_*
 */
FW_EXTERN NSString *const FW_INFO_KEY_ERROR_CODE;

/**
 *  Key of the info dictionary in -[FWRendererController handleStateTransition:FW_RENDERER_STATE_FAILED info:details]. 
 *  Its value is the error's detailed description message. 
 */
FW_EXTERN NSString *const FW_INFO_KEY_ERROR_INFO;

/**
 *  Key of the info dictionary in -[FWRendererController handleStateTransition:FW_RENDERER_STATE_FAILED info:details]. 
 *  Its value is FW_MODULE_TYPE_*
 */
FW_EXTERN NSString *const FW_INFO_KEY_ERROR_MODULE;

/**
 *  Value for key FW_INFO_KEY_ERROR_CODE
 */
FW_EXTERN NSString *const FW_ERROR_IO;

/**
 *  Value for key FW_INFO_KEY_ERROR_CODE
 */
FW_EXTERN NSString *const FW_ERROR_TIMEOUT;

/**
 *  Value for key FW_INFO_KEY_ERROR_CODE
 */
FW_EXTERN NSString *const FW_ERROR_NULL_ASSET;

/**
 *  Value for key FW_INFO_KEY_ERROR_CODE
 */
FW_EXTERN NSString *const FW_ERROR_ADINSTANCE_UNAVAILABLE;

/**
 *  Value for key FW_INFO_KEY_ERROR_CODE
 */
FW_EXTERN NSString *const FW_ERROR_UNKNOWN;

/**
 *  Value for key FW_INFO_KEY_ERROR_CODE
 */
FW_EXTERN NSString *const FW_ERROR_MISSING_PARAMETER;

/**
 *  Value for key FW_INFO_KEY_ERROR_CODE
 */
FW_EXTERN NSString *const FW_ERROR_NO_AD_AVAILABLE;

/**
 *  Value for key FW_INFO_KEY_ERROR_CODE
 */
FW_EXTERN NSString *const FW_ERROR_PARSE;

/**
 *  Value for key FW_INFO_KEY_ERROR_CODE
 */
FW_EXTERN NSString *const FW_ERROR_INVALID_VALUE;

/**
 *  Value for key FW_INFO_KEY_ERROR_CODE
 */
FW_EXTERN NSString *const FW_ERROR_INVALID_SLOT;

/**
 *  Value for key FW_INFO_KEY_ERROR_CODE
 */
FW_EXTERN NSString *const FW_ERROR_NO_RENDERER;

/**
 *  Value for key FW_INFO_KEY_ERROR_CODE
 */
FW_EXTERN NSString *const FW_ERROR_IN_APP_VIEW;

/**
 *  Value for key FW_ERROR_3P_COMPONENT
 */
FW_EXTERN NSString *const FW_ERROR_3P_COMPONENT;

/**
 *  Value for key FW_ERROR_UNSUPPORTED_3P_FEATURE
 */
FW_EXTERN NSString *const FW_ERROR_UNSUPPORTED_3P_FEATURE;

/**
 *  Key of the details dictionary passed to -[FWRendererController processEvent::]. Its value is the custom event name to be processed.
 */
FW_EXTERN NSString *const FW_INFO_KEY_CUSTOM_EVENT_NAME; 

/**
 *  Key of the details dictionary passed to -[FWRendererController processEvent::]. Its value is @"YES" or @"NO".
 */
FW_EXTERN NSString *const FW_INFO_KEY_SHOW_BROWSER;

/**
 *  Key of FW_NOTIFICATION_VIDEO_DISPLAY_BASE_CHANGED & FW_NOTIFICATION_VIDEO_DISPLAY_BASE_FRAME_CHANGED notification's userInfo dictionary. Its value is the videoDisplayBase object set by API [FWContext setVideoDisplayBase:]. 
 */
FW_EXTERN NSString *const FW_INFO_KEY_VIDEO_DISPLAY_BASE;

/**
 *  Specify the postal code of the user for targeting passthrough to 3rd party component.
 */
FW_EXTERN NSString *const FW_PARAMETER_POSTAL_CODE;

/**
 *  Specify the area code of the user's phone for targeting passthrough to 3rd party component.
 */
FW_EXTERN NSString *const FW_PARAMETER_AREA_CODE;

/**
 *  Specify the user's date of birth for targeting passthrough to 3rd party component.
 */
FW_EXTERN NSString *const FW_PARAMETER_DATE_OF_BIRTH;

/**
 *  Specify the user's gender for targeting passthrough to 3rd party component.
 */
FW_EXTERN NSString *const FW_PARAMETER_GENDER;

/**
 *  Specify a list of keywords for targeting passthrough to 3rd party component.
 */
FW_EXTERN NSString *const FW_PARAMETER_KEYWORDS;

/**
 *  Specify the area code of the user’s phone for targeting passthrough to 3rd party component.
 */
FW_EXTERN NSString *const FW_PARAMETER_SEARCH_STRING;

/**
 *  Specify the user's marital status for targeting passthrough to 3rd party component.
 */
FW_EXTERN NSString *const FW_PARAMETER_MARITAL;

/**
 *  Specify the user's ethnicity for targeting passthrough to 3rd party component.
 */
FW_EXTERN NSString *const FW_PARAMETER_ETHNICITY;

/**
 *  Specify the user's orientation for targeting passthrough to 3rd party component.
 */
FW_EXTERN NSString *const FW_PARAMETER_ORIENTATION;

/**
 *  Specify the user's income for targeting passthrough to 3rd party component.
 */
FW_EXTERN NSString *const FW_PARAMETER_INCOME;

/**
 *	Specify the whether AdManager handle temporal ad click. value should 'true'/'false' or 'on'/'off' or 'yes'/'no' 
 *	if the value is set to no/false/off, app should handle the ad click by a UIView.
 */
FW_EXTERN NSString *const FW_PARAMETER_CLICK_DETECTION;

/**
 *  The key of available desired bitrate limitation.\n 
 *  The value of this property is a NSString with positive decimal floating point number.The default value of the key is \@\"1000.0\".\n
 *  The value is used to select best creative rendition.\n
 */
FW_EXTERN NSString *const FW_PARAMETER_DESIRED_BITRATE;

/**
 *  The key of available desired orientation of rendition selection algorithm. It only takes effect in full screen mode.\n 
 *  The value of this property is a NSString.\n
 *  <ul><li>If it is not set, the application status bar orientation is used.
 *  	<li>It can be set to one of \@\"portrait\" and \@\"landscape\".
 *  	<ul><li> If it is set to \@\"portrait\", the smaller of UIScreen width and height will be selected as width and the bigger of UIScreen width and height will be selected as height.
 *          <li> The \@\"landscape\" is opposite to \@\"portrait\".
 *      </ul>
 *  </ul>    
 */
FW_EXTERN NSString *const FW_PARAMETER_DESIRED_ORIENTATION;
