#import "KeyStroke.h"

@implementation KeyStroke

static void notifyProc(const MIDINotification *message, void *refCon) // if MIDI setup is changed
{
	KeyStroke *key = (KeyStroke *)refCon;   // create reference to the KeyStroke object that created the port
	[key rescanForSources];					// rescan all available midi sources
	[key setupSourcePopup];
}
static void readProc(const MIDIPacketList *pktlist, void *refCon, void *connRefCon)
{
	KeyStroke *key = (KeyStroke *)refCon; // creates reference for midiMe object from refCon created with Input Port creation method
	[key midiProcess:(MIDIPacketList *)pktlist endpoint:(MIDIPortRef *)connRefCon];
}

- (void)midiProcess:(MIDIPacketList *)pktlist endpoint:(MIDIPortRef *)connRefCon {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	MIDIPacket *packet = (MIDIPacket *)pktlist->packet; 
	NSString *type;
	
	int packetStart = packet->data[0];
	
	if ((packetStart>>4) == 0x09) { type = @"nOn"; }	// noteOn
	if ((packetStart>>4) == 0x08) { type = @"nOff"; }	// noteOff
	if ((packetStart>>4) == 0x0b) { type = @"cc"; }		// cc
	if ((packetStart>>4) == 0x0e) { type = @"pb"; }		// pitchbend
	if ((packetStart) == 0xfe)    { type = @"as"; }		// activeSensing
	if ((packetStart>>4) == 0x0c) { type = @"pgm"; }	// program change
		
	if ((type == @"nOn" && packet->data[2] != 0) || type == @"cc" || type == @"pgm") {
		[convert midiConvert:(MIDIPacket *)packet endpoint:(MIDIPortRef *)connRefCon];
	}
	
	[pool release];
}

- (void) awakeFromNib {
	connected = FALSE;

	[mainWindow setFrameUsingName:@"msWin"];
	
	MIDIClientCreate(CFSTR("midiMonitor"), notifyProc, self, &client);
    MIDIInputPortCreate(client, CFSTR("Input Port"), readProc, self, &inPort);	
	
	[self rescanForSources];          // rescan all available midi sources
	[self setupSourcePopup];
	
	defaults = [NSUserDefaults standardUserDefaults];
	[self loadDefaultSource];
}

-(void)rescanForSources
{
    MIDIEndpointRef *sources;
    int i, j;
    
    num_sources = MIDIGetNumberOfSources();
    sources = (MIDIEndpointRef *)malloc(sizeof(MIDIEndpointRef) * num_sources);
    j = 0;
    for (i = 0; i < num_sources; i++) {
        MIDIEndpointRef source;
        source = MIDIGetSource(i);
        sources[j++] = source;
    }
    sourcesArray = CFArrayCreate(NULL, (void *)sources, j, NULL);
    free(sources);
}

- (CFArrayRef) getSourcesArray { return sourcesArray; }

- (void)setupSourcePopup
{
    CFArrayRef sourceArray;
    int numSources, i;
	
	[sourcePopup removeAllItems];
	sourceArray = [self getSourcesArray];
    numSources = CFArrayGetCount(sourceArray);
    [sourcePopup addItemWithTitle:@"None"];
	
	for (i = 0; i < numSources; i++) {
		CFStringRef pName;
		CFStringRef pModel;
        MIDIEndpointRef source;
		
        source = (MIDIEndpointRef)CFArrayGetValueAtIndex(sourceArray, i);
		
		NSMutableString *mNum = [NSMutableString string];

        MIDIObjectGetStringProperty(source, kMIDIPropertyName, &pName);
		OSStatus modelCheck = MIDIObjectGetStringProperty(source, kMIDIPropertyModel, &pModel);
		if(modelCheck != kMIDIUnknownProperty && pModel != nil) {
			[mNum appendString:(NSString *)pModel];
			[mNum appendString:@" "];
		}
        if( pName != nil ) {
		  [mNum appendString:(NSString *)pName];
		  [sourcePopup insertItemWithTitle:mNum atIndex:i+1];
        }
	}
	CFRelease(sourceArray);
}

- (void) loadDefaultSource {
	NSString *src = [defaults stringForKey:@"MIDI Source"];
	if(src != nil) {
		int index = [sourcePopup indexOfItemWithTitle:src];
		if (index != -1) {														// if the source is found...
			if(index != 0) {													// ..and not equal to None...
				chosenInput1 = MIDIGetSource(index - 1);						// get the chosen source and store the endpoint ref
				MIDIPortConnectSource(inPort, chosenInput1, chosenInput1);
				connected = TRUE;
				[sourcePopup selectItemWithTitle:src];
			}
		}else{																	// last used midi source is not connected
			NSAlert *noPopup = [[NSAlert alloc] init];
			NSMutableString *msgString = [NSMutableString stringWithFormat :@"Your last selected MIDI source (%@) is unavailable. Please choose another MIDI input.", src];
			[noPopup setMessageText:msgString];
			[noPopup runModal];
			[noPopup release];	
		}
	}
}

- (IBAction)selectSource:(id)sender {   
	if ([sender indexOfSelectedItem] != 0) {					// if they have not chosen "none" in the popup window
		if(connected) {											// if there is already a source connected...
			MIDIPortDisconnectSource(inPort, chosenInput1);		// ... disconnect it
		}
        chosenInput1 = MIDIGetSource([sender indexOfSelectedItem]-1);	// get the chosen source and store the endpoint ref
        MIDIPortConnectSource(inPort, chosenInput1, chosenInput1);		// MIDIPortConnectSource(inPort, src, refCon);
		connected = TRUE;
		[defaults setObject:[sender titleOfSelectedItem] forKey:@"MIDI Source"];
	}else{																// if the user has selected "None" from the menu...
		if (connected) {												// ... and if there is a source connected...
			MIDIPortDisconnectSource(inPort, chosenInput1);				// ... disconnect it
			connected = FALSE;
			[defaults setObject:@"None" forKey:@"MIDI Source"];
		}
	}
}

- (void) dealloc {
	CFRelease(sourcesArray);
	[super dealloc];
}
@end
