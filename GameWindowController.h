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

#import "global.h"
#import "ChessServerConnection.h"
#import "PlayView.h"

@interface GameWindowController : NSWindowController {
	ChessServerConnection *serverConnection;
	IBOutlet NSTextField *serverInput;
	IBOutlet NSDrawer *seekDrawer;
	IBOutlet NSTableView *tableView, *serverOutput;
	IBOutlet ChessView *chessView;
	IBOutlet NSTextField *upperClock, *lowerClock, *upperName, *lowerName, *result, *resultReason, *gameType, *messageField;
	IBOutlet NSTableView *seekTable, *movesTable;
	IBOutlet NSPopUpButton *gameSelector;
	IBOutlet NSSplitView *verticalSplit, *horizontalSplit;
	IBOutlet NSView *playView, *chatView, *movesView, *upperView;
	IBOutlet PlayView *playInnerView;
	IBOutlet NSArrayController *moveListController;
	char move[10];
	NSTimer *timer;
	Game *activeGame;
	NSDictionary *gameList;
	NSToolbar *toolbar;
	NSMutableDictionary *toolbarItems;
	NSString *message;
	NSMutableArray *commandHistory;
	NSString *uncommittedEdit;
	int positionInHistory;
}

- (id) initWithServerConnection: (ChessServerConnection *) sc;
- (void) updateWindowTitle;
- (void) dealloc;
- (IBAction) toggleSeekDrawer: (id) sender;
- (void) updateClock: (NSTimer *) aTimer;
- (int) numberOfRowsInTableView: (NSTableView *) aTableView;
- (id) tableView:(NSTableView *) aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;
- (void) seekTableNeedsDisplay;
- (void) setShowBoard: (ChessMove *) board;
- (IBAction) selectGame: (id) sender;
- (void) setGameList: (NSDictionary *) gl;
- (void) updateGame: (Game *) g;
- (void) setActiveGame: (Game *) g;
- (Game *) activeGame;
- (void) userMoveFrom: (struct ChessField) from to: (struct ChessField) to promotion: (int) promotion;
+ (NSString *) stringWithClock: (int) seconds;
- (void) updateClocks;
- (IBAction) takeback: (id) sender;
- (IBAction) takeback2: (id) sender;
- (IBAction) draw: (id) sender;
- (IBAction) resign: (id) sender;
- (IBAction) adjurn: (id) sender;
- (IBAction) abort: (id) sender;
- (IBAction) match: (id) sender;
- (IBAction) accept: (id) sender;
- (IBAction) decline: (id) sender;
- (IBAction) flipBoard: (id) sender;
- (IBAction) hideMoves: (id) sender;
- (IBAction) hideDialog: (id) sender;
- (IBAction) logout: (id) sender;
- (IBAction) reconnect: (id) sender;
- (IBAction) exportGame: (id) sender;
- (IBAction) newPlayWindow: (id) sender;
- (IBAction) newChatWindow: (id) sender;
- (IBAction) commandEntered: (id) sender;
- (BOOL)splitView: (NSSplitView *) sender canCollapseSubview: (NSView *) subview;
- (float)splitView: (NSSplitView *) sender constrainMaxCoordinate: (float) proposedMax ofSubviewAt:(int)offset;
- (float)splitView: (NSSplitView *) sender constrainMinCoordinate: (float) proposedMin ofSubviewAt:(int)offset;
- (void) awakeFromNib;
- (NSToolbarItem *) toolbar: (NSToolbar *) toolbar itemForItemIdentifier: (NSString *) itemIdentifier willBeInsertedIntoToolbar: (BOOL) flag;
- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar; 
- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar *) toolbar;
- (void) updateGameInfo;
- (void) showMessage: (NSString *) text;
- (void) clearMessage;
- (NSSize) windowWillResize:(NSWindow *) sender toSize: (NSSize) proposedFrameSize;
- (enum Color) sideShownOnBottom;
- (void) observeValueForKeyPath: (NSString *) keyPath ofObject: (id) object change: (NSDictionary *) change context: (void *) context;
- (BOOL) windowShouldClose: (id)sender;
- (void) logoutWarningDidEnd: (NSWindow *) sheet returnCode: (int) returnCode contextInfo: (void *) contextInfo;
- (void) windowWillClose: (NSNotification *) aNotification;
- (IBAction) newSeek: (id) sender;
- (IBAction) togglePlaySound: (id) sender;
- (IBAction) sendSeekToServer: (id) sender;
- (BOOL) control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)command;

@end
