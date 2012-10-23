/**
 * \mainpage FreeWheel AdManager Cocoa Touch SDK
 *
 *	The FreeWheel AdManager Cocoa Touch SDK is a static library for integrating
 *	your cocoa touch applications with FreeWheel MRM ad services.
 *
 *	The SDK supports iOS 3.0+ running on iPhone, iPod Touch and iPad. It is a
 *	universal binary bundle with armv6, armv7 and i386 architectures.
 *
 *	The SDK may utilize UIKit intensively, so invoke from main thread is highly preferred,
 *	otherwise crash may occur.
 *
 * To use the SDK,
 *	- Open "Project Info" window, select "Build" tab, add "-ObjC" in "Other Linker Flags".
 *	- Add libxml2.dylib, UIKit.framework, CoreGraphics.framework,
 *		QuartzCore.framework, MediaPlayer.framework, CoreLocation.framework
 *		to your project.
 *	- Add AdManager.framework to your project.
 *	- Add "#import <AdManager/FWSDK.h>" in your code.
 *	- Register the following built-in module class in MRM UI:
 *		FWVideoAdRenderer
 *		FWOverlayAdRenderer
 *		FWDisplayAdRenderer
 *		FWMRAIDAdRenderer
 *		FWNullAdRenderer
 *		FWVastTranslator
 *	- Add and register additional 3rd party renderer framework to your project (optional)
 *      Use the macro FW_LINK_RENDERER(<renderer class name>) in .m file outside any @implementation, eg:
 *      FW_LINK_RENDERER(FWSkeletonRenderer)
 */

#import "FWConstants.h"
#import "FWProtocols.h"
#import "FWVer.h"
