//
//  ChessServerConnection.m
//  Kibitz
//
//  Copyright 2014 William Entriken, licensed under the MIT license:
//  http://opensource.org/licenses/MIT
//
//  Based on Kibitz / ChessServerConnection 2006 Klaus Thul
//

#import "ChessServerConnection.h"
#import "Game.h"
#import "GameWindowController.h"
#import "PatternMatching.h"
#import "Sound.h"
#import "OutputLine.h"
#import "ChessMove.h"
#import "ChatWindowController.h"

#define USERNAME_REGEX "[A-z]{3,17}"
#define TITLES_REGEX "\\([A-Z\\*\\(\\)]*\\)"

@interface ChessServerConnection () <NSStreamDelegate>
@property (strong, nonatomic) NSMutableDictionary *activeGames;
@property (strong, nonatomic) NSMutableDictionary *infoGames;
@property (strong, nonatomic) PatternMatching *patternMatcher;
@property (strong, nonatomic) ChessServer *currentServer;
@property (strong, nonatomic) NSTask *timeseal;
@property (strong, nonatomic) NSInputStream *serverIS;
@property (strong, nonatomic) NSOutputStream *serverOS;
@property (strong, nonatomic) NSMutableDictionary *seeks;
@property (strong, nonatomic) NSMutableArray *outputLines;

@property BOOL sendNamePassword;
@property BOOL sendInit;
@property BOOL everConnected;
@property int lastChar;
@property BOOL lastLinePartial;

///TODO: should not be here:
@property (strong, nonatomic) AppController *appController;
@property (strong, nonatomic) NSMutableArray *chatWindows;
@end

@interface ChessServerConnection () {
    char lineBuf[4096];
}
@end




// See details about FICS output at:
//
// SEEK FORMAT
// iset seekinfo 1
// iset seekremove 1
// set seek 0
// iset pendinfo 1
// http://www.freechess.org/Help/HelpFiles/iv_seekinfo.html
// <sc> [CLEAR ALL SEEKS]
// <s> 31 w=DJEZ ti=00 rt=1308E t=0 i=3 r=u tp=lightning c=? rr=0-9999 a=t f=f
// <sr> 121
// FORMAT: <s> index w=name_from ti=titles rt=rating t=time i=increment
//         r=rated('r')/unrated('u') tp=type c=color
//         rr=rating_range(lower-upper) a=automatic?('t'/'f')
//         f=formula_checked('t'/f')
//
// ALL GAMES ON SERVER
// set gin 1
// http://www.freechess.org/Help/HelpFiles/v_gin.html
// {Game 276 (sundancekidxx vs. bowi) Creating rated blitz match.}
// {Game 171 (goindigo vs. Funambulo) goindigo resigns} 0-1
// {Game 14 (shineyday vs. hamaru) Game aborted on move 1} *
//
// NEW GAME INFO
// iset gameinfo 1
// http://www.freechess.org/Help/HelpFiles/iv_gameinfo.html
// <g1> 1 p=0 t=blitz r=1 u=1,1 it=5,5 i=8,8 pt=0 rt=1586E,2100  ts=1,0
// FORMAT: See webpage
//
// GAME MOVES
// style 12
// http://www.freechess.org/Help/HelpFiles/style.html
// http://www.freechess.org/Help/HelpFiles/style12.html
// <12> r----r-- pp-bqpkp --p-p-p- ---B---- -------- -----N-- PPPQ-PPP ---RR-K- B -1 0 0 0 0 0 8 eurus SIMRANGaUTAM 0 3 0 31 29 119 150 17 B/b3-d5 (0:01) Bxd5 0 1 164
// FORMAT: See webpage
// OPTIONAL: http://www.freechess.org/Help/HelpFiles/iv_compressmove.html
//
// USER INFO
// ivariables fulldecent
// variables fulldecent
// finger Hipparchus
// stat [get player ranking]
// history
//
// OTHER STUFF
// set height 200 [avoid pagination]
// observe /S [adds the highest rated Suicide game to your observation list]
// follow /b [top blitz games]
// showlist [or `=`] gets lists of players
// `help timeseal` and other docs namedrop other Mac clients
// who [find players] [list all users logged in]
// allobservers [find popular games]
// Games types [from help games]
// b: blitz      l: lightning   u: untimed      e: examined game
// s: standard   w: wild        x: atomic       z: crazyhouse
// B: Bughouse   L: losers      S: Suicide      u: untimed
// n: nonstandard game, such as different time controls
// inchannel 4 // player lists
// totals [number of logged in users]
// tell relayinfo show [upcoming events, server time is Pacific time]
// games [list of all games]
// http://www.chessclub.com/activities/events.html
// http://www.freechess.org/Events/Relay/
// http://www.freechess.org/Events/
// http://www.freechess.org/Events/Scheduled/index.html
// http://www.tim-mann.org/ics.html
// ustat [average users connected] [see also http://www.freechess.org/Help/HelpFiles/iv_graph.html]
// http://www.freechess.org/Help/HelpFiles/manual_usage.html
// see moves in a game: moves and smoves for stored games
//
// INTERESTING GAMES THAT ARE RELAYED
// https://en.wikipedia.org/wiki/World_Chess_Championship
// http://www.chessworldcup2013.com/


///TODO: stuff below here is not rewritten yet

@implementation ChessServerConnection

- (void) serverGameEnd: (NSNumber *) game result: (NSString *) result reason: (NSString *) reason
{
	Game *g = (self.activeGames)[game];
	if (g != nil) {
		[g setResult: result reason: reason];
		[self.activeGames removeObjectForKey: game];
		(self.activeGames)[@(--self.storedGameCounter)] = g;
		[self setGameLists];
		if ([g playSound])
			[gSounds gameEnd: [g gameRelationship]];
	}
}

- (void) serverIllegalMove: (NSString *) why
{
	NSEnumerator *enumerator = [self.serverWindows objectEnumerator];
	GameWindowController *gwc;
    
	while ((gwc = [enumerator nextObject]) != nil)
		[gwc showMessage: why];
}

- (void) passedPiecesGame: (NSNumber *) game white: (NSString *) white black: (NSString *) black
{
	Game *g = (self.activeGames)[game];
	if (g != nil) {
		[g passedPiecesWhite: white black: black];
		[self updateGame: g];
	}
}

- (void) processServerOutputLine: (NSString *)line
{
	NSInvocation *invoc;
    const char *lineCStr = [line cStringUsingEncoding:NSISOLatin1StringEncoding];
    
    // Process special side-channel output from FICS
    // See http://www.freechess.org/Help/HelpFiles/iv_seekinfo.html
	if (strncmp(lineCStr,"<12>", 4) == 0) {
		NSArray *a = [[line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString: @" "];
		NSNumber *n = @([a[16] intValue]);
		Game *g = (self.activeGames)[n];
		if (g == nil) {
			if ((g = (self.infoGames)[n]) != nil) {
				[[g retain] autorelease];
				[self.infoGames removeObjectForKey: n];
				[g updateWithStyle12: a];
			} else {
				g = [[[Game alloc] initWithStyle12: a] autorelease];
			}
			(self.activeGames)[n] = g;
			[self setGameLists];
			NSEnumerator *enumerator = [self.serverWindows objectEnumerator];
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
	} else if (strncmp(lineCStr,"<g1>", 4) == 0) {
		NSArray *a = [[line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString: @" "];
		NSNumber *n = @([a[1] intValue]);
		Game *g;
		if ((g = (self.activeGames)[n]) == nil) {
			if ((g = (self.infoGames)[n]) == nil) {
				g = [[Game alloc] initWithGameInfo: a];
				(self.infoGames)[n] = g;
			} else
				[g updateWithGameInfo: a];
		} else {
			[g updateWithGameInfo: a];
			[self setGameLists];
		}
	} else if (strncmp(lineCStr,"<s>", 3) == 0) {
		int num = 0;
		sscanf(lineCStr + 3, " %d", &num);
		[self newSeekFromServer: num description: lineCStr + 4];
	} else if (strncmp(lineCStr,"<sr>", 4) == 0) {
		NSArray *sr = [[[line substringFromIndex:4] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString: @" "];
		NSEnumerator *enumerator = [sr objectEnumerator];
		NSString *s;
		
		while ((s = [enumerator nextObject]) != nil) {
			int num = s.intValue;
			[self removeSeekFromServer: num];
		}
	} else if (strncmp(lineCStr,"<sc>", 4) == 0) {
		[self removeAllSeeks];
	} else if ((invoc = [self.patternMatcher parseLine: lineCStr toTarget: self]) != nil) {
		[invoc invoke];
	} else {
		NSString *s = @((char *) lineCStr);
		if (s != nil)
			[self addOutputLine: @((char *) lineCStr) type: OTHER info: 0];
	}
}

- (void) connectChessServer
{
	if ((self.currentServer).useTimeseal) {
		if (self.timeseal != nil) {
			[self.timeseal terminate];
			[self.timeseal release];
		}
		self.timeseal = [[NSTask alloc] init];
		NSMutableArray *args = [NSMutableArray array];
		[args addObject: (self.currentServer).serverAddress];
		[args addObject: [NSString stringWithFormat: @"%@", (self.currentServer).serverPort]];
		[args addObject: @"-p"];
		[args addObject: @"5501"];
		(self.timeseal).launchPath = [NSString stringWithFormat:@"%@%@", [NSBundle mainBundle].resourcePath, @"/timeseal.MacOSX-PPC"];
		(self.timeseal).arguments = args;
		[self.timeseal launch];
		NSHost *host = [NSHost hostWithName: @"127.0.0.1"];
        NSInputStream *is;
        NSOutputStream *os;
		[NSStream getStreamsToHost:host port:5501 inputStream:&is outputStream:&os];
        self.serverIS = is;
        self.serverOS = os;
	} else {
		NSHost *host = [NSHost hostWithName: (self.currentServer).serverAddress];
        NSInputStream *is;
        NSOutputStream *os;
		[NSStream getStreamsToHost:host port:(self.currentServer).serverPort.intValue inputStream:&is outputStream:&os];
        self.serverIS = is;
        self.serverOS = os;
	}
	[self.serverIS retain];
	[self.serverOS retain];
	(self.serverIS).delegate = self;
	(self.serverOS).delegate = self;
	[self.serverIS scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[self.serverOS scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[self.serverIS open];
	[self.serverOS open];
	self.sendNamePassword = YES;
	self.sendInit = YES;
}

- (void) stream: (NSStream *) theStream handleEvent:(NSStreamEvent)event
{
	char c;
	unsigned int i;
	
	switch(event) {
        case NSStreamEventHasBytesAvailable: {
            unsigned char buf[2048];
            unsigned int len = 0;
            self.everConnected = YES;
            while ((len = [(NSInputStream *) theStream read:buf maxLength: 2048]) > 0) {
                for (i = 0; i < len; i++) {
                    switch (c = buf[i]) {
                        case 10:
                            lineBuf[self.lastChar] = 0;
                            NSString *str = @(lineBuf);
                            if (str)
                                [self processServerOutputLine:str];
                            self.lastChar = 0;
                            break;
                        case 13:
                            break;
                        default:
                            lineBuf[self.lastChar++] = c;
                            break;
                    }
                }
                if (len < 2048) {
                    lineBuf[self.lastChar] = 0;
                    break;
                }
            }
            if (self.lastChar > 0) {
                if (strncmp(lineBuf,"fics%", 5) == 0) {
                    if (self.sendInit) {
                        const char *s;
                        self.sendInit = NO;
                        if ((s = (self.currentServer).initCommands.UTF8String) != nil) {
                            [self.serverOS write:(unsigned const char *) s maxLength:strlen(s)];
                            [self.serverOS write:(unsigned const char *) "\n" maxLength:1];
                        }
                        self.lastChar = 0;
                        lineBuf[0] = 0;
                        if ((self.currentServer).issueSeek)
                            [self sendSeek: (self.currentServer).seek];
                    }
                } else if (strncmp(lineBuf,"login:", 6) == 0) {
                    if (self.currentServer != nil && self.sendNamePassword == YES) {
                        const char *s;
                        self.sendNamePassword = NO;
                        if ((self.currentServer).userName && (self.currentServer).userPassword) {
                            s = (self.currentServer).userName.UTF8String;
                            [self.serverOS write:(unsigned const char *) s maxLength:strlen(s)];
                            [self.serverOS write:(unsigned const char *) "\n" maxLength:1];
                            s = (self.currentServer).userPassword.UTF8String;
                            [self.serverOS write:(unsigned const char *) s maxLength:strlen(s)];
                            [self.serverOS write:(unsigned const char *) "\n" maxLength:1];
                            self.lastChar = 0;
                            lineBuf[0] = 0;
                        }
                    }
                }
                if (self.lastChar > 0)
                    [self addOutputLine: @((char *) lineBuf) type: LINE_PARTIAL info: 0];
            }
            break;
        }
        case NSStreamEventErrorOccurred: {
            NSError *theError = theStream.streamError;
            NSRunAlertPanel(@"Error with server connection",
                            @"Error %li: %@",
                            @"OK",
                            nil,
                            nil,
                            (long)theError.code,
                            theError.localizedDescription);
            [theStream close];
            [theStream removeFromRunLoop: [NSRunLoop currentRunLoop] forMode: NSDefaultRunLoopMode];
            [theStream release];
            if (theStream == self.serverIS)
                self.serverIS = nil;
            if (theStream == self.serverOS)
                self.serverOS = nil;
            break;
        }
        case NSStreamEventEndEncountered:
            [theStream close];
            [theStream removeFromRunLoop: [NSRunLoop currentRunLoop] forMode: NSDefaultRunLoopMode];
            [theStream release];
            if (theStream == self.serverIS)
                self.serverIS = nil;
            if (theStream == self.serverOS)
                self.serverOS = nil;
            break;
        default:
            break;
	}
	if ((self.serverIS == nil) || (self.serverOS == nil)) {
		if (self.serverIS != nil) {
			[self.serverIS close];
			[self.serverIS removeFromRunLoop: [NSRunLoop currentRunLoop] forMode: NSDefaultRunLoopMode];
			[self.serverIS release];
			self.serverIS = nil;
		}
		if (self.serverOS != nil) {
			[self.serverOS close];
			[self.serverOS removeFromRunLoop: [NSRunLoop currentRunLoop] forMode: NSDefaultRunLoopMode];
			[self.serverOS release];
			self.serverOS = nil;
		}
		if (self.everConnected) {
			if (NSRunAlertPanel(@"Connection to server lost", @"Do you want to try to reconnect?",
                                @"Yes", @"No", nil) == NSAlertDefaultReturn) {
				[self.activeGames removeAllObjects];
				[self.seeks removeAllObjects];
				[self connectChessServer];
			} else
				[self.appController closeServerConnection: self];
		} else {
			NSWindowController *wc;
			NSEnumerator *e = [self.chatWindows objectEnumerator];
			while ((wc = [e nextObject]) != nil)
				[wc close];
			e = [self.serverWindows objectEnumerator];
			while ((wc = [e nextObject]) != nil)
				[wc close];
			[self.appController closeServerConnection: self];
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
     [KIBITZ_REGEX] = "^("+USERNAME_REGEX+")("+TITLES_REGEX+")?\\( {,3}([\\-0-9]+)\\)\\[(\\d+)\\] Kibitzes: (.*)"
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
		self.everConnected = NO;
		self.appController = [ac retain];
		self.currentServer = [server retain];
		[self connectChessServer];
		self.patternMatcher = [[PatternMatching alloc] initWithPatterns: serverPatterns];
		self.activeGames = [[NSMutableDictionary alloc] init];
		self.infoGames = [[NSMutableDictionary alloc] init];
		self.seeks = [[NSMutableDictionary dictionaryWithCapacity:500] retain];
		self.serverWindows = [[NSMutableArray arrayWithCapacity: 20] retain];
		self.chatWindows = [[NSMutableArray arrayWithCapacity: 20] retain];
		self.lastChar = 0;
		self.outputLines = [[NSMutableArray arrayWithCapacity: 1000] retain];
		GameWindowController *gwc = [[[GameWindowController alloc] initWithServerConnection: self] autorelease];
		[self.serverWindows addObject: gwc];
		[gwc showWindow: self];
	}
	return self;
}

- (void) dealloc
{
	if (self.serverIS != nil) {
		[self.serverIS close];
		[self.serverIS removeFromRunLoop: [NSRunLoop currentRunLoop] forMode: NSDefaultRunLoopMode];
		[self.serverIS release];
		self.serverIS = nil;
	}
	if (self.serverOS != nil) {
		[self.serverOS close];
		[self.serverOS removeFromRunLoop: [NSRunLoop currentRunLoop] forMode: NSDefaultRunLoopMode];
		[self.serverOS release];
		self.serverOS = nil;
	}
	[self.appController release];
	[self.seeks release];
	[self.currentServer release];
	[self.patternMatcher release];
	[self.serverWindows release];
	[self.chatWindows release];
	[self.outputLines release];
	[self.activeGames release];
	[self.infoGames release];
	if (self.timeseal != nil) {
		[self.timeseal terminate];
		[self.timeseal release];
	}
	[super dealloc];
}

- (void) write: (unsigned char *) data maxLength: (int) i
{
	[self.serverOS write: data maxLength:i ];
}

- (void) newSeekFromServer: (int) num description: (const char *) seekInfo
{
	Seek *s = [Seek seekFromSeekInfo: seekInfo];
	if (s != nil) {
		(self.seeks)[@(num)] = s;
		[self redisplaySeekTables];
	} else
		NSLog(@"Error in Seek request");
}

- (void) removeSeekFromServer: (int) num
{
	[self.seeks removeObjectForKey: @(num)];
	[self redisplaySeekTables];
}

- (void) removeAllSeeks
{
	[self.seeks removeAllObjects];
	[self redisplaySeekTables];
}

- (int) numSeeks
{
	return (self.seeks).count;
}

- (id) dataForSeekTable: (NSString *) x row:(int)rowIndex
{
	NSNumber *key = (self.seeks).allKeys[rowIndex];
	if ([x compare: @"#"] == 0) {
		return key;
	} else {
		Seek *s = (self.seeks)[key];
		if ([x compare: @"Name"] == 0) {
			return [s nameFrom];
		} else if ([x compare: @"Rating"] == 0) {
			return @([s ratingValue]);
		} else if ([x compare: @"Type"] == 0) {
			return [s typeOfPlay];
		} else
			return nil;
	}
}

- (void) userMoveFrom:(struct ChessField)from to:(struct ChessField)to
{
	[self userMoveFrom:from to:to promotion:0];
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
	[self.serverOS write: move maxLength: strlen((char *) move)];
}

- (NSString *) description
{
	return (self.currentServer).description;
}

- (void) sendSeek: (Seek *) s
{
	[self sendToServer: [s seekCommand]];
}

- (void) sendToServer: (NSString *) s
{
	const char *cs = s.UTF8String;
	[self.serverOS write: (unsigned char *) cs maxLength: strlen(cs)];
	[self.serverOS write: (unsigned char *) "\n" maxLength: 1];
}

- (void) sendUserInputToServer: (NSString *) s
{
	if ((s == nil) || (s.length == 0))
		return;
	[self sendToServer: s];
	[self addOutputLine: s type: LINE_USER_INPUT info: 0];
}

- (void) redisplaySeekTables
{
	NSEnumerator *enumerator = [self.serverWindows objectEnumerator];
	GameWindowController *gwc;
    
	while ((gwc = [enumerator nextObject]) != nil)
		[gwc seekTableNeedsDisplay];
}

- (void) setGameLists
{
	NSEnumerator *enumerator = [self.serverWindows objectEnumerator];
	GameWindowController *gwc;
    
	while ((gwc = [enumerator nextObject]) != nil)
		[gwc setGameList: self.activeGames];
}

- (void) updateGame: (Game *) g
{
	NSEnumerator *enumerator = [self.serverWindows objectEnumerator];
	GameWindowController *gwc;
    
	while ((gwc = [enumerator nextObject]) != nil)
		[gwc updateGame: g];
}

- (void) newPlayWindow
{
	GameWindowController *gwc = [[[GameWindowController alloc] initWithServerConnection: self] autorelease];
	[self.serverWindows addObject: gwc];
	[gwc showWindow: self];
	[gwc setGameList: self.activeGames];
	NSEnumerator *enumerator = [self.activeGames objectEnumerator];
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
	[self.chatWindows addObject: cwc];
	[cwc showWindow: self];
}

- (void) addOutputLine: (NSString *) tx type: (enum OutputLineType) ty info: (int) i
{
	[self willChangeValueForKey: @"outputLines"];
	if (self.lastLinePartial) {
		if (ty == LINE_USER_INPUT) {
			NSString *lt = [(self.outputLines).lastObject text];
			i = lt.length;
			tx = [NSString stringWithFormat: @"%@%@", lt, tx];
		}
		(self.outputLines)[(self.outputLines).count - 1] = [OutputLine newOutputLine: tx type: ty info: i];
		self.lastLinePartial = NO;
	} else {
		if (((self.outputLines).count > 0) && [[(self.outputLines).lastObject text] compare: @"fics% "] == 0)
			(self.outputLines)[(self.outputLines).count - 1] = [OutputLine newOutputLine: tx type: ty info: i];
		else
			[self.outputLines addObject: [OutputLine newOutputLine: tx type: ty info: i]];
	}
	if (ty == LINE_PARTIAL)
		self.lastLinePartial = YES;
	[self didChangeValueForKey: @"outputLines"];
}

+ (NSString *) findTag: (NSString *) tag in: (NSArray *) array
{
	NSEnumerator *e = [array objectEnumerator];
	NSString *s = s;
	while ((s = [e nextObject]) != 0) {
		if ([s hasPrefix: tag])
			return [s substringFromIndex: tag.length];
	}
	return nil;
}

- (int) lengthOutput
{
	return (self.outputLines).count;
}

- (void) chatWindowClosed: (ChatWindowController *) cwc
{
	[self.chatWindows removeObject: cwc];
	if (((self.serverWindows).count == 0) && ((self.chatWindows).count == 0))
		[self.appController closeServerConnection: self];
}

- (void) gameWindowClosed: (GameWindowController *) gwc;
{
	[[self retain] autorelease];
	[self.serverWindows removeObject: gwc];
	if ([self isConnected] && ((self.serverWindows).count == 0) && ((self.chatWindows).count == 0))
		[self.appController closeServerConnection: self];
}

- (BOOL) lastWindow
{
	return ((self.serverWindows).count + (self.chatWindows).count == 1);
}

- (BOOL) isConnected
{
	return (self.serverIS != nil) && (self.serverOS != nil);
}

- (void) newSeek
{
	[self.appController newSeekForServer: self];
}

- (void) sendSeekToServer
{
	NSArray *selectedSeeks = [[self.appController seekControl] getSelectedSeeks];
	int i, m = selectedSeeks.count;
	for (i = 0; i < m; i++)
		[self sendSeek: selectedSeeks[i]];
	[self.appController closeSeekWindow];
}

- (void) switchAllSoundsOff
{
	NSEnumerator *e = [self.activeGames objectEnumerator];
	Game *g;
	while ((g = [e nextObject]) != nil)
		[g setPlaySound: NO];
}

- (AppController *) appController
{
	return self.appController;
}

@end
