//
//  FSPLogging.h
//  FoxSports
//
//  Created by Chase Latta on 3/4/12.
//  Copyright (c) 2012 Übermind. All rights reserved.
//

/*
 Logging in this applicaiton is built on a per component basis.
 When compiling the application you can turn on specific components
 that are defined in this file or you can turn on all logging.
 By default, logging is not turned on.
 A plain NSLog statement in source code should be treated as a
 critical log statement that should run no matter what.
*/


/**
 - FSP_LOG_ALL
    If defined, all of the modules in this file will be turned on.
 - FSP_LOG_DATA_COORDINATION
    If defined, information relating to data coordination will be logged.
 - FSP_LOG_VALIDATION
    If defined, information relating to data validation will be logged.
 - FSP_LOG_FETCHING
    If defined, information from AFNetworking requests will be logged.
 - FSP_LOG_CORE_DATA
    If defined, information from Core Data will be logged.
 - FSP_LOG_VIDEO
    If defined, information regarding videos will be logged.
 - FSP_LOG_TVE
    If defined, information regarding TV Everywhere will be logged.
 - FSP_LOG_GAME_DICTIONARY
    If defined, information in game dictionaries will be logged just before they are saved.
 - FSP_ALL_EVENTS_PREGAME
    If defined, all event will be set to pregame status. Useful for testing.
 */

#if (defined(FSP_LOG_ALL) || defined(FSP_LOG_DATA_COORDINATION))
    #define FSPLogDataCoordination(...) NSLog(__VA_ARGS__)
#else
    #define FSPLogDataCoordination(...) /* */
#endif // FSP_LOG_DATA_COORDINATION

#if (defined(FSP_LOG_ALL) || defined(FSP_LOG_VALIDATION))
    #define FSPLogValidation(...) NSLog(__VA_ARGS__)
#else
    #define FSPLogValidation(...) /* */
#endif // FSP_LOG_VALIDATION

#if (defined(FSP_LOG_ALL) || defined(FSP_LOG_CORE_DATA))
    #define FSPLogCoreData(...) NSLog(__VA_ARGS__)
#else
    #define FSPLogCoreData(...) /* */
#endif // FSP_LOG_CORE_DATA

#if (defined(FSP_LOG_ALL) || defined(FSP_LOG_FETCHING))
    #define FSPLogFetching(...) NSLog(__VA_ARGS__)
#else
    #define FSPLogFetching(...) /* */
#endif 

#if (defined(FSP_LOG_ALL) || defined(FSP_LOG_VIDEO))
    #define FSPLogVideo(...) NSLog(__VA_ARGS__)
#else
    #define FSPLogVideo(...) /* */
#endif // FSP_LOG_VIDEO

#if (defined(FSP_LOG_ALL) || defined(FSP_LOG_TVE))
    #define FSPLogTve(...) NSLog(__VA_ARGS__)
#else
    #define FSPLogTve(...) /* */
#endif // FSP_LOG_TVE

#if (defined(FSP_LOG_ALL) || defined(FSP_LOG_GAME_DICTIONARY))
    #define FSPLogGameDictionary(...) NSLog(__VA_ARGS__)
#else
    #define FSPLogGameDictionary(...) /* */
#endif // FSP_LOG_GAME_DICTIONARY

#if (defined(FSP_LOG_ALL) || defined(FSP_LOG_PBP))
#define FSPLogPlayByPlay(...) NSLog(__VA_ARGS__)
#else
#define FSPLogPlayByPlay(...) /* */
#endif // FSP_LOG_VALIDATION
