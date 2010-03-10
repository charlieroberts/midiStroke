#import <Foundation/Foundation.h>


@interface EndNote : NSObject {
	NSMutableDictionary * properties;
}

- (NSMutableDictionary *) properties;
- (void) setProperties: (NSDictionary *) newProperties;
@end
