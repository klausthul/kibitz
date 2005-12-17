// icsinterface
// $Id$

#import "GameWindowController.h"

enum ToolbarItems {
	ToolbarTakeback,
	ToolbarTakeback2,
	ToolbarDraw,
	ToolbarResign,
	ToolbarAdjurn,
	ToolbarAbort,
	ToolbarNewSeek,
	ToolbarMatch,
	ToolbarAccept,
	ToolbarDecline,
	ToolbarFlipBoard,
	ToolbarHideMoves,
	ToolbarHideDialog,
	ToolbarLogout,
	ToolbarReconnect,
	ToolbarExportGame,
	ToolbarSeekDrawer
};

NSString *toolbarIdentifiers[] = {
	@"ToolbarTakeback",
	@"ToolbarTakeback2",
	@"ToolbarDraw",
	@"ToolbarResign",
	@"ToolbarAdjurn",
	@"ToolbarAbort",
	@"ToolbarNewSeek",
	@"ToolbarMatch",
	@"ToolbarAccept",
	@"ToolbarDecline",
	@"ToolbarFlipBoard",
	@"ToolbarHideMoves",
	@"ToolbarHideDialog",
	@"ToolbarLogout",
	@"ToolbarReconnect",
	@"ToolbarExportGame",
	@"ToolbarSeekDrawer",
	nil
};

NSString *toolbarLabels[] = {
	@"Takeback",
	@"Takeback 2",
	@"Draw",
	@"Resign",
	@"Adjurn",
	@"Abort",
	@"New Seek",
	@"Match",
	@"Accept",
	@"Decline",
	@"Flip board",
	@"Hide Moves",
	@"Hide Dialog",
	@"Logout",
	@"Reconnect",
	@"Export Game",
	@"Show Seek Drawer",
	nil
};

NSString *toolbarTooltips[] = {
	@"Take back one (half) move",
	@"Take back two (half) move",
	@"Offer / accept / claim a draw",
	@"Resign the game",
	@"Adjurn the game",
	@"Abort the game",
	@"Place a new seek request",
	@"Match a player",
	@"Accept a match request",
	@"Decline a match request",
	@"Turn board by 180 deg",
	@"Hide move list from window",
	@"Hide dialog from window",
	@"Logout from server",
	@"Reconnect to server",
	@"Export game to file",
	nil
};

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

- (void) updateGameInfo
{
	[self updateClocks];
	if (activeGame == nil) {
		[lowerName setStringValue: @""];
		[upperName setStringValue: @""];
		[result setStringValue: @""];
		[resultReason setStringValue: @""];
		[gameType setStringValue: @""];	
	} else {
		if ([activeGame siteShownOnBottom] == WHITE) {
			[upperName setStringValue: nil2Empty([activeGame blackName])];
			[lowerName setStringValue: nil2Empty([activeGame whiteName])];
		} else {
			[lowerName setStringValue: nil2Empty([activeGame blackName])];
			[upperName setStringValue: nil2Empty([activeGame whiteName])];
		}
		[result setStringValue: nil2Empty([activeGame result])];
		[resultReason setStringValue: nil2Empty([activeGame reason])];
		[gameType setStringValue: 
		 ([activeGame initialTime] >= 0) 
		 ? nil2Empty([NSString stringWithFormat: @"Initial time: %d min\nIncrement: %d sec\n", [activeGame initialTime], [activeGame incrementTime]])
		 : @""];
	}
	[messageField setStringValue: nil2Empty(message)];
/*	[lowerName setNeedsDisplay: YES];
	[result setNeedsDisplay: YES];
	[resultReason setNeedsDisplay: YES];
	[upperName setNeedsDisplay: YES];
	[gameType setNeedsDisplay: YES]; */
}

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)proposedFrameSize
{
//	NSSize s = [sender frame].size;
//	float delta = MIN(proposedFrameSize.width - s.width, proposedFrameSize.height - s.height);
//	s.width += delta;
//	s.height += delta;
//	return s;
	return proposedFrameSize;
}

- (void) dealloc
{
	[timer release];
	[serverConnection release];
	[activeGame release];
	[gameList release];
	[toolbar release];
	[toolbarItems release];
	[super dealloc];
}

- (int) numberOfRowsInTableView: (NSTableView *) aTableView
{
	if (aTableView == seekTable)
		return [serverConnection numSeeks];
	else
		return 0;
}

- (id) tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;
{
	if (aTableView == seekTable)
		return [serverConnection dataForSeekTable: [aTableColumn identifier] row: rowIndex];
	else
		return 0;
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
	[self setActiveGame: [[gameSelector selectedItem] representedObject]];
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
		int i = 0, ag = -1;
		enumerator = [gameList keyEnumerator];
		while ((num = [enumerator nextObject])) {
			Game *g = [gl objectForKey: num];
			[gameSelector addItemWithTitle: [g gameInfoString]];
			[[gameSelector lastItem] setRepresentedObject: g];
			if (g == activeGame)
				ag = i;
			i++;
		}
		if (c > 1)
			[gameSelector setEnabled: TRUE];
		if (ag >= 0)
			[gameSelector selectItemAtIndex: ag];
	}
	[self updateGameInfo];
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
	[self clearMessage];
}

- (Game *) activeGame
{
	return activeGame;
}

- (void) userMoveFrom: (struct ChessField) from to: (struct ChessField)to promotion: (int) promotion
{
	[serverConnection userMoveFrom: from to: to promotion: promotion];
	[self clearMessage];
}

- (void) updateClocks
{
	if (activeGame == nil) {
		[upperClock setStringValue: @"-:--:--"];	
		[lowerClock setStringValue: @"-:--:--"];	
	} else if ([activeGame siteShownOnBottom] == WHITE) {
		[upperClock setStringValue: [GameWindowController stringWithClock: [[activeGame currentBoardPosition] blackCurrentTime]]];	
		[lowerClock setStringValue: [GameWindowController stringWithClock: [[activeGame currentBoardPosition] whiteCurrentTime]]];
	} else {
		[lowerClock setStringValue: [GameWindowController stringWithClock: [[activeGame currentBoardPosition] blackCurrentTime]]];
		[upperClock setStringValue: [GameWindowController stringWithClock: [[activeGame currentBoardPosition] whiteCurrentTime]]];
	}
	[upperClock setNeedsDisplay: YES];
	[lowerClock setNeedsDisplay: YES];

}

+ (NSString *) stringWithClock: (int) seconds
{
	int minutes, hours;
	char string[10];
	
	if (seconds < 0) {
		return @"-:--:--";
	} else {
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
}

- (IBAction) takeback: (id) sender
{
	NSLog(@"bottonTakeback");
}

- (IBAction) takeback2: (id) sender
{
	NSLog(@"bottonTakeback2");
}

- (IBAction) draw: (id) sender
{
	NSLog(@"buttonDraw");
}

- (IBAction) resign: (id) sender
{
	NSLog(@"buttonResign");
}

- (IBAction) adjurn: (id) sender
{
	NSLog(@"buttonAdjurn");
}

- (IBAction) abort: (id) sender
{
	NSLog(@"buttonAbort");
}

- (IBAction) newSeek: (id) sender
{
	NSLog(@"newSeek");
}

- (IBAction) match: (id) sender
{
	NSLog(@"match");
}

- (IBAction) accept: (id) sender
{
	NSLog(@"accept");
}

- (IBAction) decline: (id) sender
{
	NSLog(@"decline");
}

- (IBAction) flipBoard: (id) sender
{
	NSLog(@"decline");
}

- (IBAction) hideMoves: (id) sender
{
	NSLog(@"decline");
}

- (IBAction) hideDialog: (id) sender
{
	NSLog(@"decline");
}

- (IBAction) logout: (id) sender;
{
	NSLog(@"logout");
}

- (IBAction) reconnect: (id) sender;
{
	NSLog(@"reconnect");
}

- (IBAction) exportGame: (id) sender;
{
	NSLog(@"exportGame");
}

- (BOOL) splitView: (NSSplitView *) sender canCollapseSubview: (NSView *) subview
{
	return ((subview == chatView) || (subview == movesView));
}

- (float) splitView: (NSSplitView *) sender constrainMaxCoordinate: (float) proposedMax ofSubviewAt:(int)offset
{
	if (sender == verticalSplit) {
		return proposedMax - 210;
	} else if (sender == horizontalSplit) {
		return proposedMax - 150;
	}
	return proposedMax; // line should never be reached
}

- (float)splitView: (NSSplitView *) sender constrainMinCoordinate: (float) proposedMin ofSubviewAt:(int)offset
{
	if (sender == verticalSplit) {
		return 457;
	} else if (sender == horizontalSplit) {
		return 353;
	}
	return proposedMin; // line should never be reached
}

- (void) splitView: (NSSplitView *) sender resizeSubviewsWithOldSize: (NSSize) oldSize
{
	NSRect chatFrame = [chatView frame];
	NSRect senderFrame = [sender frame];
	NSRect playFrame = [playView frame];

	float dividerThickness = [sender dividerThickness];
	if (sender == verticalSplit) {
		NSRect movesFrame = [movesView frame];
		float delta = oldSize.width - senderFrame.size.width;
		if (delta < 0) {
			int x;
			x = MIN(playFrame.size.height - [playInnerView maxHeightForWidth], -delta);
			delta += x;
			playFrame.size.width += x;
			if (![sender isSubviewCollapsed: movesView])
				movesFrame.size.width -= x;
		}
		float room_left = playFrame.size.width - 457;
		float room_right = movesFrame.size.width - 210;		
		if ([sender isSubviewCollapsed: movesView])
			room_right = 0;
		float total_room = room_left + room_right;
		if (total_room >= 1)
			playFrame.size.width = ceilf(MIN(playFrame.size.width - room_left / total_room * delta, MAX([playInnerView maxWidthForHeight], playFrame.size.width)));
		else
			playFrame.size.width = ceilf(playFrame.size.width - delta * 0.5);
		if (playFrame.size.height - senderFrame.size.height > 0 && ![sender isSubviewCollapsed: movesView])
			playFrame.size.width = MIN(playFrame.size.width, [playInnerView maxWidthForHeight: senderFrame.size.height]);
		if (![sender isSubviewCollapsed: movesView]) 
			movesFrame.size.width = senderFrame.size.width - dividerThickness - playFrame.size.width;
		movesFrame.size.height = playFrame.size.height = senderFrame.size.height;
		movesFrame.origin.x = playFrame.size.width + dividerThickness;
		[playView setFrame: playFrame];
		[movesView setFrame: movesFrame];
		[chatView setFrame: chatFrame];
	}
	else if (sender == horizontalSplit) {
		NSRect upperFrame = [upperView frame];
		float delta = oldSize.height - senderFrame.size.height;
		if (delta < 0) {
			int x;
			x = MIN(playFrame.size.width - [playInnerView maxWidthForHeight], -delta);
			delta += x;
			upperFrame.size.height += x;
			if (![sender isSubviewCollapsed: chatView])
				chatFrame.size.height -= x;
		}
		float room_upper = upperFrame.size.height - 353;
		float room_lower = chatFrame.size.height - 150;
		if ([sender isSubviewCollapsed: chatView])
			room_lower = 0;
		float total_room = room_upper + room_lower;
		if (total_room >= 1)
			upperFrame.size.height = ceilf(MIN(upperFrame.size.height - room_upper / total_room * delta, MAX([playInnerView maxHeightForWidth]  - dividerThickness, upperFrame.size.height)));
		else
				upperFrame.size.height = ceilf(upperFrame.size.height - delta * 0.5);
		if (![sender isSubviewCollapsed: chatView])
			chatFrame.size.height = senderFrame.size.height - dividerThickness - upperFrame.size.height;
		upperFrame.size.width = chatFrame.size.width = senderFrame.size.width;
		chatFrame.origin.y = upperFrame.size.height + dividerThickness;
		[chatView setFrame: chatFrame];
		[upperView setFrame: upperFrame];
	} else { // line should never be reached
		[sender adjustSubviews];
	}
}

- (void) awakeFromNib
{
	toolbar = [[NSToolbar alloc] initWithIdentifier: @"GameWindowToolbar"];
	[toolbar setDelegate: self];
	[toolbar setAllowsUserCustomization: YES];
	[toolbar setAutosavesConfiguration: YES];
	[[self window] setToolbar: toolbar]; 
	[self setActiveGame: [[[Game alloc] initWithEmptyGame] autorelease]];
//	[self updateGameInfo];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL) flag 
{
    NSToolbarItem *toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier] autorelease];
	int i;
	NSString *s;
	SEL toolbarSelectors[] = {
		@selector(takeback:),
		@selector(takeback2:),
		@selector(draw:),
		@selector(resign:),
		@selector(adjurn:),
		@selector(abort:),
		@selector(newSeek:),
		@selector(match:),
		@selector(accept:),
		@selector(decline:),
		@selector(flipBoard:),
		@selector(hideMoves:),
		@selector(hideDialog:),
		@selector(logout:),
		@selector(reconnect:),
		@selector(exportGame:),
		@selector(toggleSeekDrawer:)
	};
	
	for (i = 0; (s = toolbarIdentifiers[i]) != nil; i++) {
		if ([itemIdentifier isEqual: s]) {
			[toolbarItem setLabel: toolbarLabels[i]];
			[toolbarItem setPaletteLabel:toolbarLabels[i]];
			[toolbarItem setToolTip: toolbarTooltips[i]];
			[toolbarItem setImage:[NSImage imageNamed:@"SaveDocumentItemImage"]];
			[toolbarItem setTarget:self];
			[toolbarItem setAction: toolbarSelectors[i]];		
			break;
		}
	}
    return toolbarItem;
}

- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar 
{
	NSMutableArray *a = [NSMutableArray arrayWithObjects: NSToolbarFlexibleSpaceItemIdentifier, NSToolbarSpaceItemIdentifier, NSToolbarSeparatorItemIdentifier, 
	 NSToolbarCustomizeToolbarItemIdentifier, nil];
	NSString **sp;
	
	for (sp = toolbarIdentifiers; (*sp) != nil; sp++)
		[a addObject: *sp];
	return a;
}

- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar *) toolbar
{
    return [NSArray arrayWithObjects: toolbarIdentifiers[ToolbarDraw], toolbarIdentifiers[ToolbarResign], 
	 NSToolbarFlexibleSpaceItemIdentifier, toolbarIdentifiers[ToolbarSeekDrawer], nil];
}

- (void) showMessage: (NSString *) text
{
	[message release];
	message = [text retain];
	[self updateGameInfo];
}

- (void) clearMessage
{
	[message release];
	message = nil;
	[self updateGameInfo];
}
@end
