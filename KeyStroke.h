/* KeyStroke */

#import <Cocoa/Cocoa.h>
#import <ApplicationServices/ApplicationServices.h>
#import <CoreMIDI/CoreMIDI.h>
#import "MyController.h"

@interface KeyStroke : NSObject
{	
	IBOutlet id convert;
	IBOutlet id mainWindow;
	IBOutlet id sourcePopup;
	BOOL connected;
	CFStringRef source1;
	MIDIClientRef client;
    MIDIPortRef inPort;
    MIDIEndpointRef applicationInput;
    MIDIEndpointRef chosenInput1; // selectable output #1
    ItemCount num_sources;
	CFArrayRef sourcesArray;
	NSUserDefaults *defaults;
}
- (void)midiProcess:(MIDIPacketList *)pktlist endpoint:(MIDIPortRef *)connRefCon;
- (void)rescanForSources;
- (CFArrayRef) getSourcesArray;
- (void)setupSourcePopup;
- (IBAction)selectSource:(id)sender;
- (void) loadDefaultSource;
@end
