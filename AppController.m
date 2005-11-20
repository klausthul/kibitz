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
	printf("**%s\n", lineBuf);
	if (strncmp(lineBuf,"<12>", 4) == 0) {
		NSMutableArray *a = [[NSMutableArray alloc] initWithCapacity: 40];
		char *cp1, *cp2;
		int i, flip;
		enum RunningClock rc;
		
		[a autorelease];
		for (cp1 = cp2 = lineBuf; *cp1; cp1++) {
			if (*cp1 == ' ') {
				[a addObject: [NSString stringWithCString:cp2 length:cp1 - cp2]];
				cp2 = cp1 + 1;
			}
		}
		for (i = 0; i < [a count]; i++)
			printf("%d: %s\n", i, [[a objectAtIndex:i] UTF8String]);
//		flip = atoi([[a objectAtIndex: 30] UTF8String]);
		switch ([[a objectAtIndex:9] UTF8String][0]) {
		  case 'b': case 'B':
		    rc = BLACK_CLOCK_RUNS;
			break;
		  case 'w': case 'W':
		    rc = WHITE_CLOCK_RUNS;
			break;
		  default:
			rc = NO_CLOCK_RUNS;
		}
		[game setBoardFromString: lineBuf + 5 flip: flip];
		[game setClocksWhite: atoi([[a objectAtIndex:24] UTF8String]) black: atoi([[a objectAtIndex:25] UTF8String]) running: rc];
	} else if (strncmp(lineBuf,"<s>", 3) == 0) {
		int num = 0;
		sscanf(lineBuf + 3, " %d", &num);
		printf("processing: %s\n", lineBuf);
		printf("  num = %d\n", num);
		[seekGraph newSeekFromServer: num description: lineBuf + 4];
	} else if (strncmp(lineBuf,"<sr>", 4) == 0) {
		int num = 0;
		printf("processing: %s\n", lineBuf);
		sscanf(lineBuf + 4, " %d", &num);
		[seekGraph removeSeekFromServer: num];
	} else if (strncmp(lineBuf,"login:", 6) == 0) {
		printf("SERVER asking for login!!\n");
		if (currentServer != nil && sendNamePassword == YES) {
			const char *s;
			sendNamePassword = NO;
			if (currentServer->userName && currentServer->userPassword) {
				s = [currentServer->userName UTF8String];
				[serverOS write:(unsigned const char *) s maxLength:strlen(s)];
				[serverOS write:(unsigned const char *) "\n" maxLength:1];
				s = [currentServer->userPassword UTF8String];
				[serverOS write:(unsigned const char *) s maxLength:strlen(s)];
				[serverOS write:(unsigned const char *) "\n" maxLength:1];
			}
		}
	} else if (strncmp(lineBuf,"fics%", 5) == 0) {
		if (sendInit) {
			const char *s;
			sendInit = NO;
			if (s = [currentServer->initCommands UTF8String]) {
				[serverOS write:(unsigned const char *) s maxLength:strlen(s)];
				[serverOS write:(unsigned const char *) "\n" maxLength:1];
			}
		}
	} else {
		[self addToServerOutput:[NSString stringWithUTF8String:(char *) lineBuf]];
		[self addToServerOutput:@"\n"];
	}
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)event
{
	char c;
	int i;
	
	switch(event) {
	  case NSStreamEventHasBytesAvailable: {
		unsigned char buf[2048];
		unsigned int len = 0;
		while (len = [(NSInputStream *) stream read:buf maxLength: 2048]) {
			printf("LEN = %d, lastChar = %d\n", len, lastChar);
			for (i = 0; i < len; i++) {
				switch (c = buf[i]) {
				  case 10: 
					lineBuf[lastChar] = 0;
					lastChar = 0;
					[self processServerOutput];
					break;
				  case 13:
					break;
				  default:
					lineBuf[lastChar++] = c;
					break;
				}
			}
			if (len < 2048) { // !!! dirty code
				if (lastChar > 0) {
					lineBuf[lastChar] = 0;
					lastChar = 0;
					[self processServerOutput];
				}
				break;
			}
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

- (IBAction) selectServer: (id) sender
{
	[NSApp beginSheet:serverSelect modalForWindow:mainWindow modalDelegate:self didEndSelector:NULL contextInfo:NULL];
}

- (IBAction) finishServerSelection: (id) sender
{
	printf("Finish ServerSelect\n");
	[serverSelect orderOut:sender];
	if ([(NSButton *) sender tag] == 2) {
		currentServer = [chessServerListControl currentServer];
		NSHost *host = [NSHost hostWithName: currentServer->serverAddress];
		[NSStream getStreamsToHost:host port:5000 inputStream: &serverIS outputStream: &serverOS];
		[serverIS retain];
		[serverOS retain];
		[serverIS setDelegate:self];
		[serverOS setDelegate:self];
		[serverIS scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		[serverOS scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		[serverIS open];
		[serverOS open];
		sendNamePassword = YES;
		sendInit = YES;
	}
	[NSApp endSheet:serverSelect returnCode: 1];
}

- (void) awakeFromNib
{
	lastChar = 0;
	timer = [[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateClock:) userInfo:nil repeats:YES] retain];
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
	if (strlen(s) > 0)
		[serverOS write:(unsigned char *) s maxLength:strlen(s)];
	[serverOS write:(unsigned char *) "\n\r" maxLength:2];
}

- (void) userMoveFrom: (ChessField) from to: (ChessField) to
{
	move[0] = from.line + 'a' - 1;
	move[1] = from.row + '1' - 1;
	move[2] = '-';
	move[3] = to.line  + 'a' - 1;
	move[4] = to.row + '1' - 1;
	move[5] = '\n';
	move[6] = 0;
	if ([game moveValidationFrom: from to: to] == REQUIRES_PROMOTION) {
		[NSApp beginSheet:promotionPiece modalForWindow:mainWindow modalDelegate:self didEndSelector:NULL contextInfo:NULL];
	} else {
		[serverOS write:(unsigned char *) move maxLength:6 ];
	}
} 

- (IBAction) selectedPromotionPiece: (id) sender
{
	[promotionPiece orderOut:sender];
	move[5] = '=';
	move[6] = " QRNB"[[(NSButton *) sender tag]];
	move[7] = '\n';
	move[8] = 0;
	[NSApp endSheet:promotionPiece returnCode: 1];
	printf("USERMOVE: %s\n", move);
	[serverOS write:(unsigned char *) move maxLength:8 ];
}

- (IBAction) toggleSeekDrawer: (id) sender
{
	[seekDrawer toggle:sender];
}

+ (void) initialize
{
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	ChessServerList *defaultServers = [[ChessServerList alloc] init];
	NSData *serverData;
	[defaultServers addNewServerName: @"Free Internet Chess Server (FICS)" Address: @"69.36.243.188" port: 5000 userName: nil userPassword: nil 
	 initCommands: @"iset seekremove 1\niset seekinfo 1\n"];
	[defaultValues setObject:@"Hallo\n" forKey:@"Test"];
	serverData = [NSKeyedArchiver archivedDataWithRootObject:defaultServers];
	[defaultValues setObject:serverData forKey:@"ICSChessServers"];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}

- (void) updateClock: (NSTimer *) aTimer
{
	[game updateClocks];
}

@end
