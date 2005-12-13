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
//	[game updateClocks];
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

- (IBAction) selectedPromotionPiece: (id) sender
{
}

- (void) setShowBoard: (Board *) board
{
	[chessView setShowBoard: board];
}

- (IBAction) selectGame: (id) sender
{
	NSLog(@"New Game Selected\n");
	NSLog([[gameSelector selectedItem] title]);
	[self setActiveGame: [gameList objectForKey: [NSNumber numberWithInt: [[gameSelector titleOfSelectedItem] intValue]]]];
}

- (void) setGameList: (NSDictionary *) gl
{
	NSEnumerator *enumerator;
	NSNumber *num;
	
	[gameList release];
	gameList = [gl retain];
	[gameSelector removeAllItems];
	enumerator = [gameList keyEnumerator];
	while ((num = [enumerator nextObject])) {
		[gameSelector addItemWithTitle: [NSString stringWithFormat: @"%@: %@", num, [[gl objectForKey: num] gameInfoString]]];
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
	[gameSelector selectItemWithTag:<#(int)tag#>
}

- (Game *) activeGame
{
	return activeGame;
}

@end
