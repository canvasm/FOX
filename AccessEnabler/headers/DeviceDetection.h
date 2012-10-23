/**
 * **********************************************************************
 * <p/>
 * ADOBE CONFIDENTIAL
 * ___________________
 * <p/>
 * Copyright 2011 Adobe Systems Incorporated
 * All Rights Reserved.
 * <p/>
 * NOTICE:  All information contained herein is, and remains
 * the property of Adobe Systems Incorporated and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Adobe Systems Incorporated and its
 * suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Adobe Systems Incorporated.
 * ************************************************************************
 */
#import <sys/utsname.h>
#import <Foundation/Foundation.h>

@interface DeviceDetection : NSObject

enum {
    MODEL_UNKNOWN = 0,          /**< unknown model */
    MODEL_IPHONE_SIMULATOR,     /**< iphone simulator */
    MODEL_IPAD_SIMULATOR,       /**< ipad simulator */
    MODEL_IPOD_TOUCH_GEN1,      /**< ipod touch 1st Gen */
    MODEL_IPOD_TOUCH_GEN2,      /**< ipod touch 2nd Gen */
    MODEL_IPOD_TOUCH_GEN3,      /**< ipod touch 3th Gen */
    MODEL_IPHONE,               /**< iphone  */
    MODEL_IPHONE_3G,            /**< iphone 3G */
    MODEL_IPHONE_3GS,           /**< iphone 3GS */
    MODEL_IPHONE_4,             /**< iphone 4 */
	MODEL_IPAD                  /** ipad  */
};

+ (uint) detectDevice;

+ (NSString *) returnDeviceName;

@end
