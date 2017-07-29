/*
	$Id$

	Copyright 2006 Klaus Thul (klaus.thul@mac.com)
	This file is part of Kibitz.

	Kibitz is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by 
	the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

	Kibitz is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of 
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License along with Kibitz; if not, write to the 
	Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/

#import "GameWindowController.h"
#import "ChatWindowController.h"

enum ToolbarItems {
	ToolbarTakeback,
	ToolbarTakeback2,
	ToolbarDraw,
	ToolbarResign,
	ToolbarAdjourn,
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
	@"ToolbarAdjourn",
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
	@"Adjourn",
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
	@"Adjourn the game",
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

- (instancetype) initWithServerConnection: (ChessServerConnection *) sc
{
	if ((self = [super initWithWindowNibName: @"GameWindow"]) != nil) {
		timer = [[NSTimer scheduledTimerWithTimeInterval:1.0 target: self
		 selector:@selector(updateClock:) userInfo:nil repeats:YES] retain];
		serverConnection = [sc retain];
		[sc addObserver: self forKeyPath: @"outputLines" options: 0 context: nil];
		[self updateWindowTitle];
	}
	return self;
}

- (void) updateWindowTitle
{
	NSString *title;
	if ((activeGame != nil) && ![activeGame isEmpty])
		title = [NSString stringWithFormat: @"%@ - %@", serverConnection.description, [activeGame gameInfoString]];
	else
		title = [NSString stringWithFormat: @"%@", serverConnection.description];
	self.window.title = title;
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
		lowerName.stringValue = @"";
		upperName.stringValue = @"";
		result.stringValue = @"";
		resultReason.stringValue = @"";
		gameType.stringValue = @"";	
	} else {
		if ([activeGame sideShownOnBottom] == WHITE) {
			upperName.stringValue = nil2Empty([activeGame blackNameRating]);
			lowerName.stringValue = nil2Empty([activeGame whiteNameRating]);
		} else {
			lowerName.stringValue = nil2Empty([activeGame blackNameRating]);
			upperName.stringValue = nil2Empty([activeGame whiteNameRating]);
		}
		result.stringValue = nil2Empty([activeGame result]);
		resultReason.stringValue = nil2Empty([activeGame reason]);
		if ([activeGame initialTime] >= 0) {
			NSString *type = ([activeGame type]) ? [NSString stringWithFormat: @"%s %@", ([activeGame rated]) ? "rated" : "unrated", 
			 [activeGame type]] : @"";
			gameType.stringValue = [NSString stringWithFormat: @"Initial time: %d min\nIncrement: %d sec\n%@", 
			 [activeGame initialTime], [activeGame incrementTime], type];
		} else
			gameType.stringValue = @"";
	}
	messageField.stringValue = nil2Empty(message);
	[self updateWindowTitle];
}

- (void) dealloc
{
	[timer release];
	[self setActiveGame: nil];
	[serverConnection removeObserver: self forKeyPath: @"outputLines"];
	[serverConnection release];
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

- (id) tableView:(NSTableView *)aTableView objectValueForTableColumn: (NSTableColumn *) aTableColumn row: (int) rowIndex
{
	if (aTableView == seekTable)
		return [serverConnection dataForSeekTable: aTableColumn.identifier row: rowIndex];
	else
		return 0;
}

- (void) tableViewSelectionDidChange: (NSNotification *) notification
{
	if (notification.object == movesTable) {
		int r = movesTable.selectedRow;
		if (r != -1) {
			ChessMove *m = [activeGame storedMoveNumber: r];
			if (m != nil)
				[chessView setShowBoard: m];
		}
	}
}

- (void) seekTableNeedsDisplay
{
	[seekTable reloadData];
}

- (void) setShowBoard: (ChessMove *) board
{
	[chessView setShowBoard: board];
}

- (IBAction) selectGame: (id) sender
{
	[self setActiveGame: gameSelector.selectedItem.representedObject];
}

- (void) setGameList: (NSDictionary *) gl
{
	NSEnumerator *enumerator;
	NSNumber *num;
	int c = gl.count;
	
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
			Game *g = gl[num];
			[gameSelector addItemWithTitle: [g gameInfoString]];
			gameSelector.lastItem.representedObject = g;
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
	if (activeGame != nil) {
		[moveListController unbind: @"contentArray"];
		[activeGame removeObserver: self forKeyPath: @"moves"];
		[activeGame release];
	}
	if ((activeGame = g) != nil) {
		[g retain];
		[self updateGame: activeGame];
		[gameSelector selectItemAtIndex: [gameSelector indexOfItemWithRepresentedObject: g]];
		[self clearMessage];
		[moveListController bind: @"contentArray" toObject: g withKeyPath: @"moves" options: 
		@{NSRaisesForNotApplicableKeysBindingOption: @1,
		NSValidatesImmediatelyBindingOption: @1}];
		[g addObserver: self forKeyPath: @"moves" options: 0 context: nil];
	}
}

- (void) observeValueForKeyPath: (NSString *) keyPath ofObject: (id) object change: (NSDictionary *) change context: (void *) context
{
	if (object == serverConnection)
		[serverOutput scrollRowToVisible: [serverConnection lengthOutput] - 1];
	else {
		[movesTable scrollRowToVisible: [activeGame numMoves] - 1];
		[movesTable deselectAll: self];
	}
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
		upperClock.stringValue = @"-:--:--";	
		lowerClock.stringValue = @"-:--:--";	
	} else if ([activeGame sideShownOnBottom] == WHITE) {
		upperClock.stringValue = [GameWindowController stringWithClock: [[activeGame currentBoardPosition] blackCurrentTime]];	
		lowerClock.stringValue = [GameWindowController stringWithClock: [[activeGame currentBoardPosition] whiteCurrentTime]];
	} else {
		lowerClock.stringValue = [GameWindowController stringWithClock: [[activeGame currentBoardPosition] blackCurrentTime]];
		upperClock.stringValue = [GameWindowController stringWithClock: [[activeGame currentBoardPosition] whiteCurrentTime]];
	}
}

+ (NSString *) stringWithClock: (int)seconds
{
    int hours, minutes;
    
    if (seconds < 0)
		return @"-:--:--";
    hours = seconds / 3600;
    minutes = (seconds / 60) % 60;
    seconds = seconds % 60;
    return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
}

- (IBAction) takeback: (id) sender
{
	[serverConnection sendToServer: @"takeback 2"];
}

- (IBAction) takeback2: (id) sender
{
	[serverConnection sendToServer: @"takeback"];
}

- (IBAction) draw: (id) sender
{
	[serverConnection sendToServer: @"draw"];
}

- (IBAction) resign: (id) sender
{
	[serverConnection sendToServer: @"resign"];
}

- (IBAction) adjourn: (id) sender
{
	[serverConnection sendToServer: @"adjourn"];
}

- (IBAction) abort: (id) sender
{
	[serverConnection sendToServer: @"abort"];
}

- (IBAction) match: (id) sender
{
	NSLog(@"match");
}

- (IBAction) accept: (id) sender
{
	[serverConnection sendToServer: @"accept"];
}

- (IBAction) decline: (id) sender
{
	[serverConnection sendToServer: @"decline"];
}

- (IBAction) flipBoard: (id) sender
{
	NSLog(@"decline");
	[activeGame flipSideShownOnBottom];
	[self updateGameInfo];
	[chessView setNeedsDisplay: YES];
}

- (IBAction) hideMoves: (id) sender
{

}

- (IBAction) hideDialog: (id) sender
{

}

- (IBAction) logout: (id) sender
{
	NSLog(@"logout");
}

- (IBAction) reconnect: (id) sender
{
	NSLog(@"reconnect");
}

- (IBAction) exportGame: (id) sender
{
	NSLog(@"exportGame");
}

- (IBAction) newPlayWindow: (id) sender
{
	[serverConnection newPlayWindow];
}

- (IBAction) newChatWindow: (id) sender
{
	[serverConnection newChatWindow];
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
		return 463;
	} else if (sender == horizontalSplit) {
		return 353;
	}
	return proposedMin; // line should never be reached
}

- (void) splitView: (NSSplitView *) sender resizeSubviewsWithOldSize: (NSSize) oldSize
{
	NSRect senderFrame = sender.frame;
	NSRect playFrame = playView.frame;
	float dividerThickness = sender.dividerThickness;
	if (sender == verticalSplit) {
		NSRect movesFrame = movesView.frame;
		if ([sender isSubviewCollapsed: movesView])
			playFrame.size.width = senderFrame.size.width - dividerThickness;
		else {
			float delta = oldSize.width - senderFrame.size.width;
			if (delta < 0) {
				int x;
				x = fminf(playFrame.size.height - [playInnerView maxHeightForWidth], -delta);
				delta += x;
				playFrame.size.width += x;
				movesFrame.size.width -= x;
			}
			float room_left = playFrame.size.width - 463;
			float room_right = movesFrame.size.width - 210;		
			float total_room = room_left + room_right;
			if (total_room >= 1)
				playFrame.size.width = ceilf(fminf(playFrame.size.width - room_left / total_room * delta, 
				 fmaxf([playInnerView maxWidthForHeight], playFrame.size.width)));
			else
				playFrame.size.width = ceilf(playFrame.size.width - delta * 0.5);
			movesFrame.size.width = senderFrame.size.width - dividerThickness - playFrame.size.width;
			movesFrame.origin.x = playFrame.size.width + dividerThickness;
			movesFrame.size.height = senderFrame.size.height;
			movesView.frame = movesFrame;
		}
		playFrame.size.height = senderFrame.size.height;
		[playView setFrameSize: playFrame.size];
	}
	else if (sender == horizontalSplit) {
		NSRect chatFrame = chatView.frame;
		NSRect upperFrame = upperView.frame;
		if ([sender isSubviewCollapsed: chatView]) {
			upperFrame.size.height = senderFrame.size.height - dividerThickness;
		} else {
			float delta = oldSize.height - senderFrame.size.height;
			if (delta < 0) {
				int x;
				x = fminf(playFrame.size.width - [playInnerView maxWidthForHeight], -delta);
				delta += x;
				upperFrame.size.height += x;
				chatFrame.size.height -= x;
			}
			float room_upper = upperFrame.size.height - 353;
			float room_lower = chatFrame.size.height - 150;
			float total_room = room_upper + room_lower;
			if (total_room >= 1)
				upperFrame.size.height = ceilf(fminf(upperFrame.size.height - room_upper / total_room * delta, 
				 fmaxf([playInnerView maxHeightForWidth]  - dividerThickness, upperFrame.size.height)));
			else
				upperFrame.size.height = ceilf(upperFrame.size.height - delta * 0.5);
			chatFrame.size.height = senderFrame.size.height - dividerThickness - upperFrame.size.height;
			chatFrame.size.width = senderFrame.size.width;
			chatFrame.origin.y = upperFrame.size.height + dividerThickness;
			chatView.frame = chatFrame;
		}
		upperFrame.size.width = senderFrame.size.width;
		upperView.frame = upperFrame;
	} 
}

- (float) splitView: (NSSplitView *) sender constrainSplitPosition: (float) proposedPosition ofSubviewAt: (int) offset
{
	NSSize wc = self.window.contentView.bounds.size;
	if (sender == verticalSplit) {
		if (wc.width < 683)
			return 683 - 9;
	} else if (sender == horizontalSplit) {
		if (wc.height < 513)
			return 513 - 9;
	}
	return proposedPosition;
}

- (void) awakeFromNib
{
	toolbar = [[NSToolbar alloc] initWithIdentifier: @"GameWindowToolbar"];
	toolbar.delegate = self;
	[toolbar setAllowsUserCustomization: YES];
	[toolbar setAutosavesConfiguration: YES];
	self.window.toolbar = toolbar; 
	[self setActiveGame: [[[Game alloc] initWithEmptyGame] autorelease]];
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
		@selector(adjourn:),
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
			toolbarItem.label = toolbarLabels[i];
			toolbarItem.paletteLabel = toolbarLabels[i];
			toolbarItem.toolTip = toolbarTooltips[i];
			toolbarItem.image = [NSImage imageNamed:@"SaveDocumentItemImage"];
			toolbarItem.target = self;
			toolbarItem.action = toolbarSelectors[i];		
			break;
		}
	}
    return toolbarItem;
}

- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar 
{
	NSMutableArray *a = [NSMutableArray arrayWithObjects: NSToolbarFlexibleSpaceItemIdentifier, NSToolbarSpaceItemIdentifier, 
	 NSToolbarSeparatorItemIdentifier, NSToolbarCustomizeToolbarItemIdentifier, nil];
	NSString **sp;
	
	for (sp = toolbarIdentifiers; (*sp) != nil; sp++)
		[a addObject: *sp];
	return a;
}

- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar *) toolbar
{
    return @[toolbarIdentifiers[ToolbarDraw], toolbarIdentifiers[ToolbarResign], 
	 NSToolbarFlexibleSpaceItemIdentifier, toolbarIdentifiers[ToolbarSeekDrawer]];
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

- (NSSize) windowWillResize:(NSWindow *) sender toSize: (NSSize) size
{
	size = [sender contentRectForFrameRect: (NSRect) { {0, 0}, size }].size;
	if (size.width < 683 && ![verticalSplit isSubviewCollapsed: movesView])
			size.width = 683;
	if (size.height < 513 && ![horizontalSplit isSubviewCollapsed: chatView])
		size.height = 513;	
	size = [sender frameRectForContentRect: (NSRect) { {0, 0}, size }].size;
	return size;
}

- (enum Color) sideShownOnBottom
{
	return [activeGame sideShownOnBottom];
}

- (BOOL) windowShouldClose: (id)sender
{
	if ([serverConnection lastWindow] && [serverConnection isConnected]) {
		NSBeginAlertSheet(@"Logout?", @"Yes", @"Cancel", nil, self.window, self, @selector(logoutWarningDidEnd:returnCode:contextInfo:), 
		nil, nil, @"Do you want to log out from server?");
		return NO;
	} else
		return YES;
}

- (void) logoutWarningDidEnd: (NSWindow *) sheet returnCode: (int) returnCode contextInfo: (void *) contextInfo
{
	if (returnCode == NSAlertDefaultReturn)
		[self.window close];	
}

- (void) windowWillClose: (NSNotification *) aNotification
{
	[timer invalidate];
	[serverConnection gameWindowClosed: self];
}

- (IBAction) newSeek: (id) sender
{
	NSLog(@"GameWindowController New Seek\n");
	[serverConnection newSeek];
}

- (IBAction) togglePlaySound: (id) sender
{
	[activeGame setPlaySound: ![activeGame playSound]];
}

- (BOOL) validateMenuItem: (NSMenuItem *) menuItem
{
	if (menuItem.action == @selector(togglePlaySound:)) {
		if ((activeGame == nil) || [activeGame isEmpty] || ([activeGame result] != nil))
			return NO;
		else {
			menuItem.state = ([activeGame playSound] ? NSOnState : NSOffState);
			return YES;
		}
	} else
		return YES;
}

- (IBAction) sendSeekToServer: (id) sender
{
	NSLog(@"Send seek to Server");
	[serverConnection sendSeekToServer];
}

- (void) commandEntered: (NSString *) command {
	[serverConnection sendUserInputToServer: command];
}
 
@end
