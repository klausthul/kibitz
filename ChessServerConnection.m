// icsinterface
// $Id$

#import "ChessServerConnection.h"
#import "Game.h"
#import "GameWindowController.h"

@implementation ChessServerConnection

- (void) processServerOutput
{
	printf("**%s\n", lineBuf);
	if (serverMainWindow == nil) {
		serverMainWindow = [[GameWindowController alloc] initWithServerConnection: self];
		[serverMainWindow showWindow: self];
	}
	if (strncmp(lineBuf,"<12>", 4) == 0) {
		NSArray *a = [[[NSString stringWithCString: lineBuf] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString: @" "];
		ChessMove *cm = [ChessMove moveFromStyle12: a];
		[cm print];
		[serverMainWindow setShowBoard: [cm positionAfter]];
//		int i, flip;
		
/*		enum RunningClock rc;
		
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
*/
	} else if (strncmp(lineBuf,"<s>", 3) == 0) {
		int num = 0;
		sscanf(lineBuf + 3, " %d", &num);
		printf("processing: %s\n", lineBuf);
		printf("  num = %d\n", num);
		[self newSeekFromServer: num description: lineBuf + 4];
	} else if (strncmp(lineBuf,"<sr>", 4) == 0) {
		NSArray *sr = [[[NSString stringWithCString:lineBuf + 4] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString: @" "];
		NSEnumerator *enumerator = [sr objectEnumerator];
		NSString *s;

		printf("processing: %s\n", lineBuf);		
		while (s = [enumerator nextObject]) {
			int num = [s intValue];
			NSLog(@"Removing string %d", num);
			[self removeSeekFromServer: num];
		}
	} else if (strncmp(lineBuf,"login:", 6) == 0) {
		printf("SERVER asking for login!!\n");
		if (currentServer != nil && sendNamePassword == YES) {
			const char *s;
			sendNamePassword = NO;
			if ([currentServer userName] && [currentServer userPassword]) {
				s = [[currentServer userName] UTF8String];
				[serverOS write:(unsigned const char *) s maxLength:strlen(s)];
				[serverOS write:(unsigned const char *) "\n" maxLength:1];
				s = [[currentServer userPassword] UTF8String];
				[serverOS write:(unsigned const char *) s maxLength:strlen(s)];
				[serverOS write:(unsigned const char *) "\n" maxLength:1];
			}
		}
	} else if (strncmp(lineBuf,"fics%", 5) == 0) {
		if (sendInit) {
			const char *s;
			sendInit = NO;
			if (s = [[currentServer initCommands] UTF8String]) {
				[serverOS write:(unsigned const char *) s maxLength:strlen(s)];
				[serverOS write:(unsigned const char *) "\n" maxLength:1];
			}
		}
	} else {
		[serverMainWindow addToServerOutput:[NSString stringWithUTF8String:(char *) lineBuf]];
		[serverMainWindow addToServerOutput:@"\n"];
	}
}

- (void) stream: (NSStream *) theStream handleEvent:(NSStreamEvent)event
{
	char c;
	int i;
	
	switch(event) {
	  case NSStreamEventHasBytesAvailable: {
		unsigned char buf[2048];
		unsigned int len = 0;
		while (len = [(NSInputStream *) theStream read:buf maxLength: 2048]) {
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
	  case NSStreamEventErrorOccurred:
		[errorHandler handleStreamError: [theStream streamError]];
		[self release];
		break;
	}
}

- (id) initWithChessServer: (ChessServer *) server {
	printf("Hallo!\n");
	self = [self init];
	if (self != nil) {
		[self retain];
		currentServer = server;
		NSHost *host = [NSHost hostWithName: [server serverAddress]];
		[NSStream getStreamsToHost:host port:5000 inputStream: &serverIS outputStream: &serverOS];
		[serverIS retain];
		[serverOS retain];
		[serverIS setDelegate: self];
		[serverOS setDelegate: self];
		[serverIS scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		[serverOS scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		[serverIS open];
		[serverOS open];
		sendNamePassword = YES;
		sendInit = YES;
		[self release];
	}
	return self;
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		game = [[Game alloc] init];
		seeks = [[NSMutableDictionary dictionaryWithCapacity:500] retain];
		lastChar = 0;
	}
	return self;
}

- (void) dealloc
{
	[game release];
	[serverIS close];
	[serverOS close];
	[serverIS release];
	[serverOS release];
	[seeks release];
	[super dealloc];
}

- (void) setErrorHandler: (id) eh
{
	[errorHandler release];
	errorHandler = eh;
	[eh retain];
}

- (void) write: (unsigned char *) data maxLength: (int) i
{
	[serverOS write: data maxLength:i ];
}

- (void) newSeekFromServer: (int) num description: (const char *) seekInfo
{
	NSEnumerator *keyEnumerator;
	NSNumber *key;
	Seek *s = [Seek seekFromSeekInfo: seekInfo];
	if (s != nil) {
		[seeks setObject: s forKey: [NSNumber numberWithInt: num]];
		keyEnumerator = [seeks keyEnumerator];
		while ((key = [keyEnumerator nextObject]) != nil) {
			s = [seeks objectForKey:key];
			printf("%d: %s\n", [key intValue], [[s nameFrom] cString]);
		}
		[serverMainWindow seekTableNeedsDisplay];
	} else
		NSLog(@"Error in Seek request");
}

- (void) removeSeekFromServer: (int) num
{
	[seeks removeObjectForKey: [NSNumber numberWithInt: num]];
	[serverMainWindow seekTableNeedsDisplay];
}

- (int) numSeeks
{
	return [seeks count];
}

- (id) dataForSeekTable: (NSString *) x row:(int)rowIndex;
{
	NSNumber *key = [[seeks allKeys] objectAtIndex: rowIndex];
	if ([x compare: @"#"] == 0) {
		return key;
	} else {
		Seek *s = [seeks objectForKey:key];
		if ([x compare: @"Name"] == 0) {
			return [s nameFrom];
		} else if ([x compare: @"Rating"] == 0) {
			return [NSNumber numberWithInt: [s ratingValue]];
		} else if ([x compare: @"Type"] == 0) {
			return [s typeOfPlay];
		} else
			return nil;
	}
}

@end
