#import "AppController.h"
#define min(a, b) (((a) < (b)) ? (a) : (b))

@implementation AppController

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)proposedFrameSize
{
	NSSize s = [sender frame].size;
	float delta = min(proposedFrameSize.width - s.width, proposedFrameSize.height - s.height);
	s.width += delta;
	s.height += delta;
	return s;
}

- (void) addToServerOutput: (NSString *) s
{
	NSRange r = { [[serverOutput string] length], 0 };
	[serverOutput replaceCharactersInRange:r withString:s];	
}

- (void) processServerOutput
{
	if (strncmp(lineBuf,"<12>", 4) == 0) {
		NSMutableArray *a = [[NSMutableArray alloc] initWithCapacity: 40];
		char *cp1, *cp2;
		int i, flip;
		
		[a autorelease];
		for (cp1 = cp2 = lineBuf; *cp1; cp1++) {
			if (*cp1 == ' ') {
				[a addObject: [NSString stringWithCString:cp2 length:cp1 - cp2]];
				cp2 = cp1 + 1;
			}
		}
		printf("processing: %s\n", lineBuf);
		for (i = 0; i < [a count]; i++)
			printf("%d: %s\n", i, [[a objectAtIndex:i] UTF8String]);
		flip = atoi([[a objectAtIndex: 30] UTF8String]);
		[game setBoardFromString: lineBuf + 5 flip: flip];
	}
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)event
{
	char c;
	int i;
	
	switch(event) {
	  case NSStreamEventHasBytesAvailable: {
		unsigned char buf[1024];
		unsigned int len = 0;
		while (len = [(NSInputStream *) stream read:buf maxLength:1023]) {
			buf[len] = 0;
			[self addToServerOutput:[NSString stringWithUTF8String:(char *) buf]];
			for (i = 0; i < len; i++) {
				switch (c = buf[i]) {
				  case '\n':
					lineBuf[lastChar] = 0;
					[self processServerOutput];
					lastChar = 0;
					break;
				  case '\r':
					break;
				  default:
					lineBuf[lastChar++] = c;
					break;
				}
			}
			if (len < 1023) // !!! dirty code
				break;
		}
		break;
	  }
	  case NSStreamEventErrorOccurred: {
		NSError *theError = [stream streamError];
		NSAlert *theAlert = [[NSAlert alloc] init]; 

		NSLog([theError localizedDescription]);
		[theAlert setMessageText:@"Error reading stream!"];
		[theAlert setInformativeText:[NSString stringWithFormat:@"Error %i: %@", [theError code], [theError localizedDescription]]];
		[theAlert addButtonWithTitle:@"OK"];
        [theAlert beginSheetModalForWindow:[NSApp mainWindow] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
		 contextInfo:nil];
		[stream close];
		[stream release];
		}
		break;
	}
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
}

- (void) awakeFromNib
{
	NSHost *host = [NSHost hostWithName: @"69.36.243.188"];
//	NSHost *host = [NSHost hostWithName: @"chess.unix-ag.uni-kl.de"];
	NSLog([host address]);
	
	[NSStream getStreamsToHost:host port:5000 inputStream: &serverIS outputStream: &serverOS];
	[serverIS retain];
	[serverOS retain];
	[serverIS setDelegate:self];
	[serverOS setDelegate:self];
	[serverIS scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[serverOS scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[serverIS open];
	[serverOS open];
	lastChar = 0;
}

- (void) dealloc
{
	[serverIS release];
	[serverOS release];
	[super dealloc];
}

- (void) controlTextDidEndEditing:(NSNotification *)aNotification
{
	NSString *input = [serverInput stringValue];
	const char *s = [input UTF8String];
	NSLog([serverInput stringValue]);
	[serverOS write:(unsigned char *) s maxLength:strlen(s)];
	[serverOS write:(unsigned char *) "\n" maxLength:1];
}

- (void) userMoveFrom: (ChessField) from to: (ChessField) to
{
	unsigned char m[8];
	m[0] = from.line + 'a' - 1;
	m[1] = from.row + '1' - 1;
	m[2] = '-';
	m[3] = to.line  + 'a' - 1;
	m[4] = to.row + '1' - 1;
	m[5] = '\n';
	m[6] = 0;
	printf("USERMOVE: %s\n", m);
	[serverOS write:(unsigned char *) m maxLength:6];
} 

@end
