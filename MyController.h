/* MyController */

#import <Cocoa/Cocoa.h>
#import <CoreMIDI/CoreMIDI.h>
#import <ApplicationServices/ApplicationServices.h>
#import "StartNote.h"
#import "EndNote.h"

@interface MyController : NSObject
{
    NSMutableArray * _startNotes;
}

- (NSString *) pathForDataFile;
- (void) saveDataToDisk;
- (void) loadDataFromDisk;
- (int) keyCodeForKeyString:(char *)keyString;
- (void) midiConvert: (MIDIPacket *)packet endpoint:(MIDIPortRef *)ep;

@end

