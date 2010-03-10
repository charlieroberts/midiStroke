#import "MyController.h"

@implementation MyController

#pragma mark -
#pragma mark Startup and Shutdown

- (id) init
{
    if (self = [super init])
    {
        _startNotes = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) dealloc
{
    [_startNotes release];
    
    [super dealloc];
}


// added for "Saving Application Data" tutorial
// http://cocoadevcentral.com/articles/000084.php

- (void) awakeFromNib
{
    [NSApp setDelegate: self];
    [self loadDataFromDisk];
}


// added for "Saving Application Data" tutorial
// http://cocoadevcentral.com/articles/000084.php

- (void) applicationWillTerminate: (NSNotification *)note
{
    [self saveDataToDisk];
}



#pragma mark -
#pragma mark Simple Accessors

- (NSMutableArray *) startNotes
{
    return _startNotes;
}

- (void) setStartNotes: (NSArray *)newStartNotes
{
    if (_startNotes != newStartNotes)
    {
        [_startNotes autorelease];
        _startNotes = [[NSMutableArray alloc] initWithArray: newStartNotes];
    }
}


// added for "Saving Application Data" tutorial
// http://cocoadevcentral.com/articles/000084.php

- (NSString *) pathForDataFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *folder = @"~/Library/Application Support/midiStroke/";
    folder = [folder stringByExpandingTildeInPath];
    
    if ([fileManager fileExistsAtPath: folder] == NO)
    {
        [fileManager createDirectoryAtPath: folder attributes: nil];
    }
    
    NSString *fileName = @"midiStroke.cdcmidistroke";
    return [folder stringByAppendingPathComponent: fileName];
}


// added for "Saving Application Data" tutorial
// http://cocoadevcentral.com/articles/000084.php

- (void) saveDataToDisk
{
    NSString * path = [self pathForDataFile];

    NSMutableDictionary * rootObject;
    rootObject = [NSMutableDictionary dictionary];
    
    [rootObject setValue: [self startNotes] forKey:@"startNotes"];
    [NSKeyedArchiver archiveRootObject: rootObject toFile: path];
}


// added for "Saving Application Data" tutorial
// http://cocoadevcentral.com/articles/000084.php

- (void) loadDataFromDisk
{
    NSString     * path         = [self pathForDataFile];
    NSDictionary * rootObject;
    
    rootObject = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    [self setStartNotes: [rootObject valueForKey:@"startNotes"]];
}

- (void) midiConvert: (MIDIPacket *)packet endpoint:(MIDIPortRef *)ep {	
	int i, j;
	BOOL cc = false;
	int pcktStart = packet->data[0];
	int channel = (pcktStart &= 15) + 1;
	
	int packetStart = packet->data[0];		// remembers original type and channel of message before altering
	if ((packetStart>>4) == 0x0b) { cc = true; }
	
	//printf("the channel is: %i \n", channel);
	//printf("the note is: %i \n", packet->data[1]);
	
	for (i=0; i<[_startNotes count]; i++) {	
		StartNote *sn = [_startNotes objectAtIndex:i];						// creates a startNote object for each item in list
		NSDictionary *sp = [sn properties];									// creates a dictionary of startNote properties
		NSMutableArray *se = [sn endNotes];
		if ([[sp objectForKey:@"number"] intValue] == packet->data[1]) {	// if note / pgm / or cc number is the same as the received midi message
			if ([[sp objectForKey:@"channel"] intValue] == channel || [[sp objectForKey:@"channel"] intValue] ==0) {	// if channel is the same or we're looking for all channels
				if (cc == false || packet->data[2] == [[sp objectForKey:@"ccValue"] intValue] || [[sp objectForKey:@"ccValue"] intValue] == -1) { // optionally looking for specific cc values
					for (j=0; j<[se count]; j++) {
						EndNote *en = [se objectAtIndex:j];
						NSDictionary *eprop = [en properties];
						char *charString = [(NSString *)[eprop objectForKey: @"keystroke"] UTF8String];
						int theLetter = [self keyCodeForKeyString:charString];
						
						if ([[eprop objectForKey: @"apple"] intValue] == 1) {
							CGPostKeyboardEvent( (CGCharCode)0, (CGKeyCode)55, true ); // command > down
						}
						if ([[eprop objectForKey: @"shift"] intValue] == 1) {
							CGPostKeyboardEvent( (CGCharCode)0, (CGKeyCode)56, true ); // shift > down
						}
						if ([[eprop objectForKey: @"option"] intValue] == 1) {
							CGPostKeyboardEvent( (CGCharCode)0, (CGKeyCode)58, true ); // option > down
						}
						if ([[eprop objectForKey: @"control"] intValue] == 1) {
							CGPostKeyboardEvent( (CGCharCode)0, (CGKeyCode)59, true ); // control > down
						}
						
						CGPostKeyboardEvent( (CGCharCode)0, (CGKeyCode)theLetter, true); 
						CGPostKeyboardEvent( (CGCharCode)0, (CGKeyCode)theLetter, false);
						
						if ([[eprop objectForKey: @"apple"] intValue] == 1) {
							CGPostKeyboardEvent( (CGCharCode)0, (CGKeyCode)55, false ); // command > up
						}
						if ([[eprop objectForKey: @"shift"] intValue] == 1) {
							CGPostKeyboardEvent( (CGCharCode)0, (CGKeyCode)56, false ); // shift > up
						}
						if ([[eprop objectForKey: @"option"] intValue] == 1) {
							CGPostKeyboardEvent( (CGCharCode)0, (CGKeyCode)58, false ); // option > up
						}
						if ([[eprop objectForKey: @"control"] intValue] == 1) {
							CGPostKeyboardEvent( (CGCharCode)0, (CGKeyCode)59, false ); // control > up
						}
					}
				}
			}
		}
	}
}

- (int) keyCodeForKeyString:(char *)keyString
{
	if (strcmp(keyString, "a") == 0) return 0;
	if (strcmp(keyString, "s") == 0) return 1;
	if (strcmp(keyString, "d") == 0) return 2;
	if (strcmp(keyString, "f") == 0) return 3;
	if (strcmp(keyString, "h") == 0) return 4;
	if (strcmp(keyString, "g") == 0) return 5;
	if (strcmp(keyString, "z") == 0) return 6;
	if (strcmp(keyString, "x") == 0) return 7;
	if (strcmp(keyString, "c") == 0) return 8;
	if (strcmp(keyString, "v") == 0) return 9;
	if (strcmp(keyString, "`") == 0) return 10;
	if (strcmp(keyString, "b") == 0) return 11;
	if (strcmp(keyString, "q") == 0) return 12;
	if (strcmp(keyString, "w") == 0) return 13;
	if (strcmp(keyString, "e") == 0) return 14;
	if (strcmp(keyString, "r") == 0) return 15;
	if (strcmp(keyString, "y") == 0) return 16;
	if (strcmp(keyString, "t") == 0) return 17;
	if (strcmp(keyString, "1") == 0) return 18;
	if (strcmp(keyString, "2") == 0) return 19;
	if (strcmp(keyString, "3") == 0) return 20;
	if (strcmp(keyString, "4") == 0) return 21;
	if (strcmp(keyString, "6") == 0) return 22;
	if (strcmp(keyString, "5") == 0) return 23;
	if (strcmp(keyString, "=") == 0) return 24;
	if (strcmp(keyString, "9") == 0) return 25;
	if (strcmp(keyString, "7") == 0) return 26;
	if (strcmp(keyString, "-") == 0) return 27;
	if (strcmp(keyString, "8") == 0) return 28;
	if (strcmp(keyString, "0") == 0) return 29;
	if (strcmp(keyString, "]") == 0) return 30;
	if (strcmp(keyString, "o") == 0) return 31;
	if (strcmp(keyString, "u") == 0) return 32;
	if (strcmp(keyString, "[") == 0) return 33;
	if (strcmp(keyString, "i") == 0) return 34;
	if (strcmp(keyString, "p") == 0) return 35;
	if (strcmp(keyString, "RETURN") == 0) return 36;
	if (strcmp(keyString, "l") == 0) return 37;
	if (strcmp(keyString, "j") == 0) return 38;
	if (strcmp(keyString, "'") == 0) return 39;
	if (strcmp(keyString, "k") == 0) return 40;
	if (strcmp(keyString, ";") == 0) return 41;
	if (strcmp(keyString, "\\") == 0) return 42;
	if (strcmp(keyString, ",") == 0) return 43;
	if (strcmp(keyString, "/") == 0) return 44;
	if (strcmp(keyString, "n") == 0) return 45;
	if (strcmp(keyString, "m") == 0) return 46;
	if (strcmp(keyString, ".") == 0) return 47;
	if (strcmp(keyString, "TAB") == 0) return 48;
	if (strcmp(keyString, "SPACE") == 0) return 49;
	if (strcmp(keyString, "`") == 0) return 50;
	if (strcmp(keyString, "DELETE") == 0) return 51;
	if (strcmp(keyString, "ENTER") == 0) return 52;
	if (strcmp(keyString, "ESCAPE") == 0) return 53;
	//54?
	if (strcmp(keyString, "CMD") == 0) return 55;
	if (strcmp(keyString, "SHIFT") == 0) return 56;
	if (strcmp(keyString, "CAPSLOCK") == 0) return 57;
	if (strcmp(keyString, "OPTION") == 0) return 58;
	if (strcmp(keyString, "CONTROL") == 0) return 59;
	
	if (strcmp(keyString, "NUM.") == 0) return 65;
	
	if (strcmp(keyString, "*") == 0) return 67;
	
	if (strcmp(keyString, "+") == 0) return 69;
	
	if (strcmp(keyString, "CLEAR") == 0) return 71;
	
	if (strcmp(keyString, "NUM/") == 0) return 75;
	if (strcmp(keyString, "NUMENTER") == 0) return 76;  // numberpad on full kbd
	
	if (strcmp(keyString, "NUM-") == 0) return 78;
	
	if (strcmp(keyString, "NUM=") == 0) return 81;
	if (strcmp(keyString, "NUM0") == 0) return 82;
	if (strcmp(keyString, "NUM1") == 0) return 83;
	if (strcmp(keyString, "NUM2") == 0) return 84;
	if (strcmp(keyString, "NUM3") == 0) return 85;
	if (strcmp(keyString, "NUM4") == 0) return 86;
	if (strcmp(keyString, "NUM5") == 0) return 87;
	if (strcmp(keyString, "NUM6") == 0) return 88;
	if (strcmp(keyString, "NUM7") == 0) return 89;
	
	if (strcmp(keyString, "NUM8") == 0) return 91;
	if (strcmp(keyString, "NUM9") == 0) return 92;
	if (strcmp(keyString, "F5") == 0) return 96;
	if (strcmp(keyString, "F6") == 0) return 97;
	if (strcmp(keyString, "F7") == 0) return 98;
	if (strcmp(keyString, "F3") == 0) return 99;
	if (strcmp(keyString, "F8") == 0) return 100;
	if (strcmp(keyString, "F9") == 0) return 101;
	
	if (strcmp(keyString, "F11") == 0) return 103;
	
	if (strcmp(keyString, "F13") == 0) return 105;
	
	if (strcmp(keyString, "F14") == 0) return 107;
	
	if (strcmp(keyString, "F10") == 0) return 109;
	
	if (strcmp(keyString, "F12") == 0) return 111;
	
	if (strcmp(keyString, "F15") == 0) return 113;
	if (strcmp(keyString, "HELP") == 0) return 114;
	if (strcmp(keyString, "HOME") == 0) return 115;
	if (strcmp(keyString, "PGUP") == 0) return 116;
	if (strcmp(keyString, "DELETE") == 0) return 117;
	if (strcmp(keyString, "F4") == 0) return 118;
	if (strcmp(keyString, "END") == 0) return 119;
	if (strcmp(keyString, "F2") == 0) return 120;
	if (strcmp(keyString, "PGDN") == 0) return 121;
	if (strcmp(keyString, "F1") == 0) return 122;
	if (strcmp(keyString, "LEFT") == 0) return 123;
	if (strcmp(keyString, "RIGHT") == 0) return 124;
	if (strcmp(keyString, "DOWN") == 0) return 125;
	if (strcmp(keyString, "UP") == 0) return 126;

	return 0;
}

@end
