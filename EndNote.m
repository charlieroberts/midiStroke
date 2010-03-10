#import "EndNote.h"

@implementation EndNote
- (id) init {
    if (self = [super init]) {
        NSArray * keys      = [NSArray arrayWithObjects: @"keystroke", @"apple", @"shift", @"option", @"control",nil];
        NSArray * values    = [NSArray arrayWithObjects: @"Z", @"TRUE", @"FALSE", @"FALSE", @"FALSE",nil];
        properties = [[NSMutableDictionary alloc] initWithObjects: values forKeys: keys];
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *)coder { [coder encodeObject: properties forKey:@"properties"]; } // must have for every array

- (id) initWithCoder: (NSCoder *) coder { // initializes from file
	if (self = [super init])
    {
        [self setProperties: [coder decodeObjectForKey:@"properties"]];
    }
    return self;
}

- (void) dealloc { [properties release]; [super dealloc]; }

- (NSMutableDictionary *) properties {
    return properties;
}

- (void) setProperties: (NSDictionary *)newProperties {
    if (properties != newProperties) {
        [properties autorelease];
        properties = [[NSMutableDictionary alloc] initWithDictionary: newProperties];
    }
}

@end
