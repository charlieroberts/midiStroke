#import "StartNote.h"

@implementation StartNote
- (id) init {

    if (self = [super init]) {
        NSArray * keys = [NSArray arrayWithObjects: @"number", @"channel", @"ccValue", nil];
        NSArray * values = [NSArray arrayWithObjects: @"45",@"1",@"", nil];
        properties = [[NSMutableDictionary alloc] initWithObjects: values forKeys: keys];
		endNotes = [[NSMutableArray alloc] init];
	}
    return self;
}

- (id) initWithCoder: (NSCoder *) coder {
	if (self = [super init])
    {
        [self setProperties: [coder decodeObjectForKey:@"properties"]];
        [self setEndNotes:     [coder decodeObjectForKey:@"endNotes"]];
    }
	return self;
}

- (void) encodeWithCoder: (NSCoder *) encoder { 
	[encoder encodeObject: properties forKey:@"properties"];
	[encoder encodeObject:endNotes forKey:@"endNotes"]; 
}
- (void) dealloc { [properties release];   [endNotes release];   [super dealloc]; }

- (NSMutableDictionary *) properties { return properties; }

- (void) setProperties: (NSDictionary *)newProperties {
    if (properties != newProperties) {
        [properties autorelease];
        properties = [[NSMutableDictionary alloc] initWithDictionary: newProperties];
    }
}

- (NSMutableArray *) endNotes;
{
    return endNotes;
}

- (void) setEndNotes: (NSArray *)newEndNotes
{
    if (endNotes != newEndNotes) {
        [endNotes autorelease];
        endNotes = [[NSMutableArray alloc] initWithArray: newEndNotes];
    }
}
@end
