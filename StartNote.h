#import <Foundation/Foundation.h>


@interface StartNote : NSObject {
	NSMutableDictionary * properties;
	NSMutableArray * endNotes;
}
- (NSMutableDictionary *) properties;
- (void) setProperties: (NSDictionary *)newProperties;
- (NSMutableArray *) endNotes;
- (void) setEndNotes: (NSArray *) newEndNotes;
@end
