// icsinterface
// $Id$

#import "GameWindowController.h"


@implementation GameWindowController

- (id) initWithServerConnection: (ChessServerConnection *) sc
{
	self = [super initWithWindowNibName: @"GameWindow"];
	if (self != nil) {
		timer = [[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateClock:) userInfo:nil repeats:YES] retain];
		serverConnection = [sc retain];
	}
	return self;
}

- (void) addToServerOutput: (NSString *) s
{
	NSRange r = { [[serverOutput string] length], 0 };
	[serverOutput replaceCharactersInRange:r withString:s];	
}

- (void) controlTextDidEndEditing:(NSNotification *)aNotification
{
	NSString *input = [serverInput stringValue];
	const char *s = [input UTF8String];
	NSLog([serverInput stringValue]);
	if (strlen(s) > 0)
		[serverConnection write:(unsigned char *) s maxLength:strlen(s)];
	[serverConnection write:(unsigned char *) "\n\r" maxLength:2];
}

- (IBAction) toggleSeekDrawer: (id) sender
{
	[seekDrawer toggle:sender];
}

- (void) updateClock: (NSTimer *) aTimer
{
	[self updateClocks];
}

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)proposedFrameSize
{
	NSSize s = [sender frame].size;
	float delta = MIN(proposedFrameSize.width - s.width, proposedFrameSize.height - s.height);
	s.width += delta;
	s.height += delta;
	return s;
}

- (void) dealloc
{
	[timer release];
	[serverConnection release];
	[activeGame release];
	[gameList release];
	[super dealloc];
}

- (int) numberOfRowsInTableView: (NSTableView *) aTableView
{
	return [serverConnection numSeeks];
}

- (id) tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;
{
	return [serverConnection dataForSeekTable: [aTableColumn identifier] row: rowIndex];
}

- (void) seekTableNeedsDisplay
{
	[seekTable reloadData];
}

- (void) setShowBoard: (Board *) board
{
	[chessView setShowBoard: board];
}

- (IBAction) selectGame: (id) sender
{
	NSLog(@"New Game Selected\n");
	NSLog([[gameSelector selectedItem] title]);
	[self setActiveGame: [[gameSelector selectedItem] representedObject]];
	[self updateClocks];
}

- (void) setGameList: (NSDictionary *) gl
{
	NSEnumerator *enumerator;
	NSNumber *num;
	int c = [gl count];
	
	[gameList release];
	gameList = [gl retain];
	[gameSelector removeAllItems];
	[gameSelector setEnabled: FALSE];
	if (c <= 0) {
		[gameSelector addItemWithTitle: @"no game played or observed"];
	} else {
		enumerator = [gameList keyEnumerator];
		while ((num = [enumerator nextObject])) {
			Game *g = [gl objectForKey: num];
			[gameSelector addItemWithTitle: [NSString stringWithFormat: @"%@: %@", num, [g gameInfoString]]];
			[[gameSelector lastItem] setRepresentedObject: g];
		}
		if (c > 1)
			[gameSelector setEnabled: TRUE];
	}
}

- (void) updateGame: (Game *) g
{
	if (g == activeGame) {
		[chessView setShowBoard: [g currentBoardPosition]];
	}
}

- (void) setActiveGame: (Game *) g
{
	[activeGame release];
	activeGame = [g retain];
	[self updateGame: activeGame];
	[gameSelector selectItemAtIndex: [gameSelector indexOfItemWithRepresentedObject: g]];
}

- (Game *) activeGame
{
	return activeGame;
}

- (void) userMoveFrom: (struct ChessField) from to: (struct ChessField)to promotion: (int) promotion
{
	[serverConnection userMoveFrom: from to: to promotion: promotion];
}

- (void) updateClocks
{
	[upperClock setStringValue: [GameWindowController stringWithClock: [[activeGame currentBoardPosition] blackCurrentTime]]];
	[upperClock setNeedsDisplay: YES];
	[lowerClock setStringValue: [GameWindowController stringWithClock: [[activeGame currentBoardPosition] whiteCurrentTime]]];
	[lowerClock setNeedsDisplay: YES];
}

+ (NSString *) stringWithClock: (int) seconds
{
	int minutes, hours;
	char string[10];
	minutes = seconds / 60;
	seconds -= minutes * 60;
	hours = minutes / 60;
	minutes -= hours * 60;
	string[0] = hours % 10 + '0';
	string[1] = ':';
	string[2] = minutes / 10 + '0';
	string[3] = minutes % 10 + '0';
	string[4] = ':';
	string[5] = seconds / 10 + '0';
	string[6] = seconds % 10 + '0';
	string[7] = 0;
	return [NSString stringWithCString: string];
}

- (IBAction) buttonTakeback: (id) sender
{
	NSLog(@"bottonTakeback");
}

- (IBAction) buttonTakeback2: (id) sender
{
	NSLog(@"bottonTakeback2");
}

- (IBAction) buttonDraw: (id) sender
{
	NSLog(@"buttonDraw");
}

- (IBAction) buttonResign: (id) sender
{
	NSLog(@"buttonResign");
}

- (IBAction) buttonAdjurn: (id) sender
{
	NSLog(@"buttonAdjurn");
}

- (IBAction) buttonAbort: (id) sender
{
	NSLog(@"buttonAbort");
}

@end
