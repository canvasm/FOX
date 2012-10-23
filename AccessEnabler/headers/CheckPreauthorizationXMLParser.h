#import <Foundation/Foundation.h>

@interface CheckPreauthorizationXMLParser : NSObject<NSXMLParserDelegate> {

@private
    NSMutableDictionary *resourceDic;
    NSString *currentElementValue;
    NSString *resourceId;
    NSString *authorizationStatus;
}

@property (nonatomic, retain) NSMutableDictionary *resourceDic;

- (id) init;

@end
