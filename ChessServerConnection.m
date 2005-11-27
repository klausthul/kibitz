// icsinterface
// $Id$

#import "ChessServerConnection.h"
#import "Game.h"

@implementation ChessServerConnection

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

- (ChessServerConnection *) initWithChessServer: (ChessServer *) server {
	self = [self init];
	if (self != nil) {
		currentServer = server;
		NSHost *host = [NSHost hostWithName: server->serverAddress];
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
	return self;
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		game = [[Game alloc] init];
		seekGraph = [[Seek Graph alloc] init];
		lastChar = 0;
	}
	return self;
}

- (void) dealloc
{
	[game release];
	[seekGraph release];
	[serverIS close];
	[serverOS close];
	[serverIS release];
	[serverOS release];
}

@end
