/*
	$Id$

	Copyright 2006 Klaus Thul (klaus.thul@mac.com)
	This file is part of kibitz.

	kibitz is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by 
	the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

	kibitz is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of 
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License along with kibitz; if not, write to the 
	Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/

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
	Game *g = [activeGames objectForKey: game]; 
	if (g != nil) {
		[g setResult: result reason: reason];
		[activeGames removeObjectForKey: game];
		[activeGames setObject: g forKey: [NSNumber numberWithInt: --storedGameCounter]]; 
		[self setGameLists];
		if ([g playSound])
			[gSounds gameEnd: [g gameRelationship]];
	}
}

- (void) serverIllegalMove: (NSString *) why
{
	NSEnumerator *enumerator = [serverWindows objectEnumerator];
	GameWindowController *gwc;
   
	while ((gwc = [enumerator nextObject]) != nil)
		[gwc showMessage: why];
}

- (void) passedPiecesGame: (NSNumber *) game white: (NSString *) white black: (NSString *) black
{
	Game *g = [activeGames objectForKey: game];
	if (g != nil) {
		[g passedPiecesWhite: white black: black];
		[self updateGame: g];
	}
}

- (void) processServerOutput
{
	NSInvocation *invoc;
	if (strncmp(lineBuf,"<12>", 4) == 0) {
		NSArray *a = [[[NSString stringWithCString: lineBuf] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString: @" "];
		NSNumber *n = [NSNumber numberWithInt: [[a objectAtIndex: 16] intValue]];
		Game *g = [activeGames objectForKey: n];
		if (g == nil) {
			if ((g = [infoGames objectForKey: n]) != nil) {
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
			while ((gwc = [enumerator nextObject]) != nil)
				[gwc setActiveGame: g];
			if ([g playSound])
				[gSounds newGame: [g gameRelationship]];
			[g newMove: [ChessMove moveFromStyle12: a]];
			[g setDefaultBoardOrientation];
		} else {
			ChessMove *m = [ChessMove moveFromStyle12: a];
			if ([g playSound])
				[gSounds move: [m gameRelationship]];
			[g newMove: m];
		}
		[self updateGame: g];
	} else if (strncmp(lineBuf,"<g1>", 4) == 0) {
		NSArray *a = [[[NSString stringWithCString: lineBuf] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString: @" "];
		NSNumber *n = [NSNumber numberWithInt: [[a objectAtIndex: 1] intValue]];
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
		
		while ((s = [enumerator nextObject]) != nil) {
			int num = [s intValue];
			[self removeSeekFromServer: num];
		}
	} else if (strncmp(lineBuf,"<sc>", 4) == 0) {
		[self removeAllSeeks];
	} else if ((invoc = [patternMatcher parseLine: lineBuf toTarget: self]) != nil) {
		[invoc invoke];
	} else {
		NSString *s = [NSString stringWithUTF8String:(char *) lineBuf];
		if (s != nil)
			[self addOutputLine: [NSString stringWithUTF8String:(char *) lineBuf] type: OTHER info: 0];
	}
}

- (void) connectChessServer
{
	if ([currentServer useTimeseal]) {
		if (timeseal != nil) {
			[timeseal terminate];
			[timeseal release];
		}
		timeseal = [[NSTask alloc] init];
		NSMutableArray *args = [NSMutableArray array];
		[args addObject: [currentServer serverAddress]];
		[args addObject: [NSString stringWithFormat: @"%@", [currentServer serverPort]]];
		[args addObject: @"-p"];
		[args addObject: @"5501"];
		[timeseal setLaunchPath: [NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] resourcePath], @"/timeseal.MacOSX-PPC"]];
		[timeseal setArguments:args];
		[timeseal launch];
		NSHost *host = [NSHost hostWithName: @"127.0.0.1"];
		[NSStream getStreamsToHost:host port: 5501 inputStream: &serverIS outputStream: &serverOS];
	} else {
		NSHost *host = [NSHost hostWithName: [currentServer serverAddress]];
		[NSStream getStreamsToHost:host port:[[currentServer serverPort] intValue] inputStream: &serverIS outputStream: &serverOS];
	}
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
}

- (void) stream: (NSStream *) theStream handleEvent:(NSStreamEvent)event
{
	char c;
	unsigned int i;
	
	switch(event) {
	  case NSStreamEventHasBytesAvailable: {
		unsigned char buf[2048];
		unsigned int len = 0;
		everConnected = YES;
		while ((len = [(NSInputStream *) theStream read:buf maxLength: 2048]) > 0) {
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
					if ((s = [[currentServer initCommands] UTF8String]) != nil) {
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
	  case NSStreamEventErrorOccurred: {
		NSError *theError = [theStream streamError];
		NSRunAlertPanel(@"Error with server connection", 
		 [NSString stringWithFormat:@"Error %i: %@", [theError code], [theError localizedDescription]],
		 @"OK", nil, nil);
		[theStream close];
		[theStream removeFromRunLoop: [NSRunLoop currentRunLoop] forMode: NSDefaultRunLoopMode];
		[theStream release];
		if (theStream == serverIS)
			serverIS = nil;
		if (theStream == serverOS)
			serverOS = nil;			
		break;
	  }
	  case NSStreamEventEndEncountered:
		[theStream close];
		[theStream removeFromRunLoop: [NSRunLoop currentRunLoop] forMode: NSDefaultRunLoopMode];
		[theStream release];
		if (theStream == serverIS)
			serverIS = nil;
		if (theStream == serverOS)
			serverOS = nil;			
		break;
	  default:
		break;
	}
	if ((serverIS == nil) || (serverOS == nil)) {
		if (serverIS != nil) {
			[serverIS close];
			[serverIS removeFromRunLoop: [NSRunLoop currentRunLoop] forMode: NSDefaultRunLoopMode];
			[serverIS release];
			serverIS = nil;
		}
		if (serverOS != nil) {
			[serverOS close];
			[serverOS removeFromRunLoop: [NSRunLoop currentRunLoop] forMode: NSDefaultRunLoopMode];
			[serverOS release];
			serverOS = nil;
		}
		if (everConnected) {
			if (NSRunAlertPanel(@"Connection to server lost", @"Do you want to try to reconnect?",
			 @"Yes", @"No", nil) == NSAlertDefaultReturn) {
				[activeGames removeAllObjects];
				[seeks removeAllObjects];
				[self connectChessServer];
			} else
				[appController closeServerConnection: self];
		} else {
			NSWindowController *wc;
			NSEnumerator *e = [chatWindows objectEnumerator];			
			while ((wc = [e nextObject]) != nil)
				[wc close];
			e = [serverWindows objectEnumerator];			
			while ((wc = [e nextObject]) != nil)
				[wc close];				
			[appController closeServerConnection: self];		
		}
	}
}

- (ChessServerConnection *) initWithChessServer: (ChessServer *) server appController: ac {
	struct ServerPattern serverPatterns[] = {
		{ "^\\{Game ([0-9]+) \\((" USERNAME_REGEX ") vs\\. (" USERNAME_REGEX ")\\) ([^\\}]+)\\} (.*)", @selector(serverGameEnd:result:reason:), "1I54" },
		{ "^Illegal move \\((.*)\\)\\.(.*)", @selector(serverIllegalMove:), "0" },
		{ "^(It is not your move\\.)$", @selector(serverIllegalMove:), "0" },
		{ "^(The clock is paused, use \"unpause\" to resume\\.)$", @selector(serverIllegalMove:), "0" },
		{ "^(You are not playing or examining a game\\.)$", @selector(serverIllegalMove:), "0" },
		{"^<b1> game ([0-9]+) white \\[([PBNRQKpbnrqk]*)\\] black \\[([PBNRQKpbnrqk]*)\\]", @selector(passedPiecesGame:white:black:), "1I23" },
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
		everConnected = NO;
		appController = [ac retain];
		currentServer = [server retain];
		[self connectChessServer];
		patternMatcher = [[PatternMatching alloc] initWithPatterns: serverPatterns];
		activeGames = [[NSMutableDictionary alloc] init];
		infoGames = [[NSMutableDictionary alloc] init];
		seeks = [[NSMutableDictionary dictionaryWithCapacity:500] retain];
		serverWindows = [[NSMutableArray arrayWithCapacity: 20] retain];
		chatWindows = [[NSMutableArray arrayWithCapacity: 20] retain];
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
	if (serverIS != nil) {
		[serverIS close];
		[serverIS removeFromRunLoop: [NSRunLoop currentRunLoop] forMode: NSDefaultRunLoopMode];
		[serverIS release];
		serverIS = nil;
	}
	if (serverOS != nil) {
		[serverOS close];
		[serverOS removeFromRunLoop: [NSRunLoop currentRunLoop] forMode: NSDefaultRunLoopMode];
		[serverOS release];
		serverOS = nil;
	}
	[appController release];
	[seeks release];
	[currentServer release];
	[patternMatcher release];
	[serverWindows release];
	[chatWindows release];
	[outputLines release];
	[activeGames release];
	[infoGames release];
	if (timeseal != nil) {
		[timeseal terminate];
		[timeseal release];
	}
	[super dealloc];
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

- (id) dataForSeekTable: (NSString *) x row:(int)rowIndex
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
	const char *pieces = " pnbrqk  PNBRQK ";
	
	if (from.line == -1) {
		move[0] = pieces[from.row];
		move[1] = '@';
		move[2] = to.line  + 'a' - 1;
		move[3] = to.row + '1' - 1;
		move[4] = '\n';		
		move[5] = 0;
	} else {
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
	}
	[serverOS write: move maxLength: strlen((char *) move)];
} 

- (NSString *) description
{
	return [currentServer description];
}

- (void) sendSeek: (Seek *) s
{
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
   
	while ((gwc = [enumerator nextObject]) != nil)
		[gwc seekTableNeedsDisplay];
}

- (void) setGameLists
{
	NSEnumerator *enumerator = [serverWindows objectEnumerator];
	GameWindowController *gwc;
   
	while ((gwc = [enumerator nextObject]) != nil)
		[gwc setGameList: activeGames];
}

- (void) updateGame: (Game *) g
{
	NSEnumerator *enumerator = [serverWindows objectEnumerator];
	GameWindowController *gwc;
   
	while ((gwc = [enumerator nextObject]) != nil)
		[gwc updateGame: g];
}

- (void) newPlayWindow
{
	GameWindowController *gwc = [[[GameWindowController alloc] initWithServerConnection: self] autorelease];
	[serverWindows addObject: gwc];
	[gwc showWindow: self];
	[gwc setGameList: activeGames];
	NSEnumerator *enumerator = [activeGames objectEnumerator];
	Game *g, *g2 = nil;  
	while ((g = [enumerator nextObject]) != nil) {
		[gwc updateGame: g];
		g2 = g;
	}
	if (g2 != nil)
		[gwc setActiveGame: g2];
}

- (void) newChatWindow
{
	ChatWindowController *cwc = [[[ChatWindowController alloc] initWithServerConnection: self] autorelease];
	[chatWindows addObject: cwc];
	[cwc showWindow: self];
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

- (void) chatWindowClosed: (ChatWindowController *) cwc
{
	[chatWindows removeObject: cwc];
	if (([serverWindows count] == 0) && ([chatWindows count] == 0))
		[appController closeServerConnection: self];
}

- (void) gameWindowClosed: (GameWindowController *) gwc;
{
	[[self retain] autorelease];
	[serverWindows removeObject: gwc];
	if ([self isConnected] && ([serverWindows count] == 0) && ([chatWindows count] == 0))
		[appController closeServerConnection: self];
}

- (BOOL) lastWindow
{
	return ([serverWindows count] + [chatWindows count] == 1);
}

- (BOOL) isConnected
{
	return (serverIS != nil) && (serverOS != nil);
}

- (void) newSeek
{
	NSLog(@"ChessServerConnection: newSeek");
	[appController newSeekForServer: self];
}

- (void) sendSeekToServer
{
	NSArray *selectedSeeks = [[appController seekControl] getSelectedSeeks];
	int i, m = [selectedSeeks count];
	for (i = 0; i < m; i++)
		[self sendSeek: [selectedSeeks objectAtIndex: i]];
	[appController closeSeekWindow];
}

@end
