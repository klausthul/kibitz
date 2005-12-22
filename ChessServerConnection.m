// icsinterface
// $Id$

#import "ChessServerConnection.h"
#import "Game.h"
#import "GameWindowController.h"
#import "PatternMatching.h"
#import "Sound.h"
#import "OutputLine.h"
#import "ChessMove.h"

#define USERNAME_REGEX "[A-z]{3,17}"
#define TITLES_REGEX "\\([A-Z\\*\\(\\)]*\\)"

@implementation ChessServerConnection

- (void) serverGameEnd: (NSNumber *) game result: (NSString *) result reason: (NSString *) reason
{
	NSLog(@"Game end\n");
	Game *g = [activeGames objectForKey: game]; 
	if (g != nil) {
		[g setResult: result reason: reason];
		[activeGames removeObjectForKey: game];
		[activeGames setObject: g forKey: [NSNumber numberWithInt: --storedGameCounter]]; 
		[self setGameLists];
		[gSounds gameEnd: [g gameRelationship]];
	}
}

- (void) serverIllegalMove: (NSString *) why
{
	NSEnumerator *enumerator = [serverWindows objectEnumerator];
	GameWindowController *gwc;
   
	while (gwc = [enumerator nextObject])
		[gwc showMessage: why];
}

- (void) processServerOutput
{
	NSInvocation *invoc;
	if (strncmp(lineBuf,"<12>", 4) == 0) {
		NSArray *a = [[[NSString stringWithCString: lineBuf] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString: @" "];
		NSNumber *n = [NSNumber numberWithInt: [[a objectAtIndex: 16] intValue]];
		Game *g = [activeGames objectForKey: n];
		if (g == nil) {
			if (g = [infoGames objectForKey: n]) {
				[[g retain] autorelease];
				[infoGames removeObjectForKey: n];
				[g updateWithStyle12: a];
			} else {
				g = [[[Game alloc] initWithStyle12: a] autorelease];
			}
			[activeGames setObject: g forKey: n];
			[self setGameLists];
			NSEnumerator *enumerator = [serverWindows objectEnumerator];
			GameWindowController *gwc;
			while (gwc = [enumerator nextObject])
				[gwc setActiveGame: g];
			[gSounds newGame: [g gameRelationship]];
			[g newMove: [ChessMove moveFromStyle12: a]];
			[g setDefaultBoardOrientation];
		} else {
			ChessMove *m = [ChessMove moveFromStyle12: a];
			[gSounds move: [m gameRelationship]];
			[g newMove: m];
		}
		[self updateGame: g];
	} else if (strncmp(lineBuf,"<g1>", 4) == 0) {
		NSArray *a = [[[NSString stringWithCString: lineBuf] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString: @" "];
		NSNumber *n = [NSNumber numberWithInt: [[a objectAtIndex: 1] intValue]];
		printf("%d: %s\n", [n intValue], lineBuf);
		Game *g;
		if ((g = [activeGames objectForKey: n]) == nil) {
			if ((g = [infoGames objectForKey: n]) == nil) {
				g = [[Game alloc] initWithGameInfo: a];
				[infoGames setObject: g forKey: n];
			} else
				[g updateWithGameInfo: a];
		} else {
			[g updateWithGameInfo: a];
			[self setGameLists];
		}
	} else if (strncmp(lineBuf,"<s>", 3) == 0) {
		int num = 0;
		sscanf(lineBuf + 3, " %d", &num);
		[self newSeekFromServer: num description: lineBuf + 4];
	} else if (strncmp(lineBuf,"<sr>", 4) == 0) {
		NSArray *sr = [[[NSString stringWithCString:lineBuf + 4] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString: @" "];
		NSEnumerator *enumerator = [sr objectEnumerator];
		NSString *s;
		
		while (s = [enumerator nextObject]) {
			int num = [s intValue];
			[self removeSeekFromServer: num];
		}
	} else if (strncmp(lineBuf,"<sc>", 4) == 0) {
		[self removeAllSeeks];
	} else if (invoc = [patternMatcher parseLine: lineBuf toTarget: self]) {
		[invoc invoke];
	} else {
		NSString *s = [NSString stringWithUTF8String:(char *) lineBuf];
		if (s != nil)
			[self addOutputLine: [NSString stringWithUTF8String:(char *) lineBuf] type: OTHER info: 0];
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
			for (i = 0; i < len; i++) {
				switch (c = buf[i]) {
				  case 10: 
					lineBuf[lastChar] = 0;
					if (lastChar > 0)
						[self processServerOutput];
					lastChar = 0;
					break;
				  case 13:
					break;
				  default:
					lineBuf[lastChar++] = c;
					break;
				}
			}
			if (len < 2048) {
				lineBuf[lastChar] = 0;
				break;
			}
		}
		if (lastChar > 0) {
			if (strncmp(lineBuf,"fics%", 5) == 0) {
				if (sendInit) {
					const char *s;
					sendInit = NO;
					if (s = [[currentServer initCommands] UTF8String]) {
						[serverOS write:(unsigned const char *) s maxLength:strlen(s)];
						[serverOS write:(unsigned const char *) "\n" maxLength:1];
					}
					lastChar = 0;
					lineBuf[0] = 0;
				} 
			} else if (strncmp(lineBuf,"login:", 6) == 0) {
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
						lastChar = 0;
						lineBuf[0] = 0;	
					}
				}			
			}
			if (lastChar > 0)
				[self addOutputLine: [NSString stringWithUTF8String:(char *) lineBuf] type: LINE_PARTIAL info: 0];
		}
		break;
	  }
	  case NSStreamEventErrorOccurred:
		[errorHandler handleStreamError: [theStream streamError]];
		[self release];
		break;
	}
}

- (ChessServerConnection *) initWithChessServer: (ChessServer *) server {
	struct ServerPattern serverPatterns[] = {
		{ "^\\{Game ([0-9]+) \\((" USERNAME_REGEX ") vs\\. (" USERNAME_REGEX ")\\) ([^\\}]+)\\} (.*)", @selector(serverGameEnd:result:reason:), "1I54" },
		{ "^Illegal move \\((.*)\\)\\.(.*)", @selector(serverIllegalMove:), "0" },
		{ "^(It is not your move\\.)$", @selector(serverIllegalMove:), "0" },
		{ "^(The clock is paused, use \"unpause\" to resume\\.)$", @selector(serverIllegalMove:), "0" },
		{ "^(You are not playing or examining a game\\.)$", @selector(serverIllegalMove:), "0" },
		{ 0, 0, 0 }
	};
/*	
	[LOGIN_PATTERN] = "^\\*\\*\\*\\* Starting FICS session as ("+USERNAME_REGEX+")("+TITLES_REGEX+")? \\*\\*\\*\\*",
	[WRONG_PASSWORD_PATTERN] = "^\\*\\*\\*\\* Invalid password! \\*\\*\\*\\*",
	[PERSONAL_TELL_PATTERN] = "^("+USERNAME_REGEX+")("+TITLES_REGEX+")? tells you: (.*)",
	[SAY_PATTERN] = "^("+USERNAME_REGEX+")("+TITLES_REGEX+")?(\\[(\\d+)\\])? says: (.*)"),
	[PTELL_PATTERN] = "^("+USERNAME_REGEX+")("+TITLES_REGEX+")? \\(your partner\\) tells you: (.*)",
	[CHANNEL_TELL_REGEX] = "^("+USERNAME_REGEX+")("+TITLES_REGEX+")?\\((\\d+)\\): (.*)"
	[KIBITZ_REGEX] = "^("+USERNAME_REGEX+")("+TITLES_REGEX+")?\\( {,3}([\\-0-9]+)\\)\\[(\\d+)\\] kibitzes: (.*)"
	WHISPER_REGEX "^("+USERNAME_REGEX+")("+TITLES_REGEX+")?\\( {,3}([\\-0-9]+)\\)\\[(\\d+)\\] whispers: (.*)"
	QTELL_REGEX = new Pattern("^:(.*)")
	SHOUT_REGEX "^("+USERNAME_REGEX+")("+TITLES_REGEX+")? shouts: (.*)"
	ISHOUT_REGEX "^--> ("+USERNAME_REGEX+")("+TITLES_REGEX+")? ?(.*)"
	TSHOUT_REGEX "^:("+USERNAME_REGEX+")("+TITLES_REGEX+")? t-shouts: (.*)"
	CSHOUT_REGEX "^("+USERNAME_REGEX+")("+TITLES_REGEX+")? c-shouts: (.*)"
	ANNOUNCEMENT_REGEX "^    \\*\\*ANNOUNCEMENT\\*\\* from ("+USERNAME_REGEX+"): (.*)"
	STOPPED_OBSERVING_REGEX "^Removing game (\\d+) from observation list\\.$"
	STOPPED_EXAMINING_REGEX "^You are no longer examining game (\\d+)\\.$"
	ENTERING_SETUP "^Entering setup mode.$"
	LEAVING_SETUP "Game is validated - entering examine mode."
	OFFER_PARSER "^(\\d+) w=("+USERNAME_REGEX+") t=(\\S+) p=(.*)"
	OFFER_REGEX = new Pattern("^<p([tf])> (.*)")
	PLAYER_OFFERED_DRAW_REGEX "^Game (\\d+): ("+USERNAME_REGEX+") offers a draw\\.$"
	PLAYER_OFFERED_ABORT_REGEX "^Game (\\d+): ("+USERNAME_REGEX+") requests to abort the game\\.$"
	PLAYER_OFFERED_ADJOURN_REGEX "^Game (\\d+): ("+USERNAME_REGEX+") requests to adjourn the game\\.$"
	PLAYER_OFFERED_TAKEBACK_REGEX "^Game (\\d+): ("+USERNAME_REGEX+") requests to take back (\\d+) half move\\(s\\)\\.$"
	PLAYER_DECLINED_REGEX "^Game (\\d+): ("+USERNAME_REGEX+") declines the (\\w+) request\\.$"
	PLAYER_WITHDREW_REGEX "^Game (\\d+): ("+USERNAME_REGEX+") withdraws the (\\w+) request\\.$"
	PLAYER_COUNTER_TAKEBACK_OFFER_REGEX "^Game (\\d+): ("+USERNAME_REGEX+") proposes a different number \\((\\d+)\\) of half-move\\(s\\) to take back\\.$"
	AT_BOARD_REGEX = "^You are now at ("+USERNAME_REGEX+")'s board \\(game (\\d+)\\)\\.$"
	PRIMARY_GAME_CHANGED_REGEX = "^Your primary game is now game (\\d+)\\.$"
*/

	if ((self = [super init]) != nil) {
		[self retain];
		currentServer = [server retain];
		NSHost *host = [NSHost hostWithName: [server serverAddress]];
		[NSStream getStreamsToHost:host port:[[server serverPort] intValue] inputStream: &serverIS outputStream: &serverOS];
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
		patternMatcher = [[PatternMatching alloc] initWithPatterns: serverPatterns];
		activeGames = [[NSMutableDictionary alloc] init];
		infoGames = [[NSMutableDictionary alloc] init];
		seeks = [[NSMutableDictionary dictionaryWithCapacity:500] retain];
		serverWindows = [[NSMutableArray arrayWithCapacity: 20] retain];
		lastChar = 0;
		outputLines = [[NSMutableArray arrayWithCapacity: 1000] retain];
		GameWindowController *gwc = [[[GameWindowController alloc] initWithServerConnection: self] autorelease];
		[serverWindows addObject: gwc];
		[gwc showWindow: self];
	}
	return self;
}

- (void) dealloc
{
	[serverIS close];
	[serverOS close];
	[serverIS release];
	[serverOS release];
	[seeks release];
	[currentServer release];
	[errorHandler release];
	[patternMatcher release];
	[serverWindows release];
	[outputLines release];
	[activeGames release];
	[infoGames release];
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
	Seek *s = [Seek seekFromSeekInfo: seekInfo];
	if (s != nil) {
		[seeks setObject: s forKey: [NSNumber numberWithInt: num]];
		[self redisplaySeekTables];
	} else
		NSLog(@"Error in Seek request");
}

- (void) removeSeekFromServer: (int) num
{
	[seeks removeObjectForKey: [NSNumber numberWithInt: num]];
	[self redisplaySeekTables];
}

- (void) removeAllSeeks
{
	[seeks removeAllObjects];
	[self redisplaySeekTables];	
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

- (void) userMoveFrom: (struct ChessField) from to: (struct ChessField) to
{
	[self userMoveFrom: from to: to promotion: 0];
}

- (void) userMoveFrom: (struct ChessField) from to: (struct ChessField) to promotion: (int) promotionPiece
{
	unsigned char move[10];
	
	move[0] = from.line + 'a' - 1;
	move[1] = from.row + '1' - 1;
	move[2] = '-';
	move[3] = to.line  + 'a' - 1;
	move[4] = to.row + '1' - 1;
	if ((promotionPiece < 2) || (promotionPiece > 5)) {
		move[5] = '\n';
		move[6] = 0;
	} else {
		move[5] = '=';
		move[6] = "  NBRQ"[promotionPiece];
		move[7] = '\n';
		move[8] = 0;
	}
	[serverOS write: move maxLength: strlen((char *) move)];
} 

- (NSString *) description
{
	return [currentServer serverName];
}

- (void) sendSeek: (Seek *) s
{
	NSLog([self description]);
	NSLog([s seekDescriptionLine]);
	[self sendToServer: [s seekCommand]];
}

- (void) sendToServer: (NSString *) s
{
	const char *cs = [s UTF8String];
	[serverOS write: (unsigned char *) cs maxLength: strlen(cs)];
	[serverOS write: (unsigned char *) "\n" maxLength: 1];	
}

- (void) sendUserInputToServer: (NSString *) s
{
	if ((s == nil) || ([s length] == 0))
		return;
	[self sendToServer: s];
	[self addOutputLine: s type: LINE_USER_INPUT info: 0];
}

- (void) redisplaySeekTables
{
	NSEnumerator *enumerator = [serverWindows objectEnumerator];
	GameWindowController *gwc;
   
	while (gwc = [enumerator nextObject])
		[gwc seekTableNeedsDisplay];
}

- (void) setGameLists
{
	NSEnumerator *enumerator = [serverWindows objectEnumerator];
	GameWindowController *gwc;
   
	while (gwc = [enumerator nextObject])
		[gwc setGameList: activeGames];
}

- (void) updateGame: (Game *) g
{
	NSEnumerator *enumerator = [serverWindows objectEnumerator];
	GameWindowController *gwc;
   
	while (gwc = [enumerator nextObject])
		[gwc updateGame: g];
}

- (void) newPlayWindow
{
	GameWindowController *gwc = [[[GameWindowController alloc] initWithServerConnection: self] autorelease];
	[serverWindows addObject: gwc];
	[gwc showWindow: self];
	[gwc setGameList: activeGames];
	NSEnumerator *enumerator = [activeGames objectEnumerator];
	Game *g;  
	while (g = [enumerator nextObject])
		[gwc updateGame: g];
}

- (void) addOutputLine: (NSString *) tx type: (enum OutputLineType) ty info: (int) i
{
	[self willChangeValueForKey: @"outputLines"];
	if (lastLinePartial) {
		if (ty == LINE_USER_INPUT) {
			NSString *lt = [[outputLines lastObject] text];
			i = [lt length];
			tx = [NSString stringWithFormat: @"%@%@", lt, tx];
		}
		[outputLines replaceObjectAtIndex: [outputLines count] - 1 withObject: [OutputLine newOutputLine: tx type: ty info: i]];
		lastLinePartial = NO;
	} else {
		if (([outputLines count] > 0) && [[[outputLines lastObject] text] compare: @"fics% "] == 0)
			[outputLines replaceObjectAtIndex: [outputLines count] - 1 withObject: [OutputLine newOutputLine: tx type: ty info: i]];
		else
			[outputLines addObject: [OutputLine newOutputLine: tx type: ty info: i]];
	}
	if (ty == LINE_PARTIAL)
		lastLinePartial = YES;
	[self didChangeValueForKey: @"outputLines"];
}

+ (NSString *) findTag: (NSString *) tag in: (NSArray *) array
{
	NSEnumerator *e = [array objectEnumerator];
	NSString *s = s;
	while ((s = [e nextObject]) != 0) {
		if ([s hasPrefix: tag])
			return [s substringFromIndex: [tag length]];
	}
	return nil;
}

- (int) lengthOutput
{
	return [outputLines count];
}

@end
