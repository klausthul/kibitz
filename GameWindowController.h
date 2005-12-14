// icsinterface
// $Id$

#import "global.h"
#import "ChessServerConnection.h"

@interface GameWindowController : NSWindowController {
	ChessServerConnection *serverConnection;
	IBOutlet NSTextView *serverOutput;
	IBOutlet NSTextField *serverInput;
	IBOutlet NSDrawer *seekDrawer;
	IBOutlet NSTableView *tableView;
	IBOutlet ChessView *chessView;
	IBOutlet NSTextField *upperClock, *lowerClock;
	IBOutlet NSTableView *seekTable;
	IBOutlet NSPopUpButton *gameSelector;
	IBOutlet NSButton *buttonTakeback, *buttonTakeback2, *buttonDraw, *buttonResign, *buttonAdjurn, *buttonAbort;
	IBOutlet NSSplitView *verticalSplit, *horizontalSplit;
	IBOutlet NSView *playView, *chatView, *movesView;
	char move[10];
	NSTimer *timer;
	Game *activeGame;
	NSDictionary *gameList;
	NSToolbar *toolbar;
	NSMutableDictionary *toolbarItems;
}

- (id) initWithServerConnection: (ChessServerConnection *) sc;
- (void) addToServerOutput: (NSString *) s;
- (void) dealloc;
- (IBAction) toggleSeekDrawer: (id) sender;
- (void) updateClock: (NSTimer *) aTimer;
- (int) numberOfRowsInTableView: (NSTableView *) aTableView;
- (id) tableView:(NSTableView *) aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;
- (void) seekTableNeedsDisplay;
- (void) setShowBoard: (Board *) board;
- (IBAction) selectGame: (id) sender;
- (void) setGameList: (NSDictionary *) gl;
- (void) updateGame: (Game *) g;
- (void) setActiveGame: (Game *) g;
- (Game *) activeGame;
- (void) userMoveFrom: (struct ChessField) from to: (struct ChessField) to promotion: (int) promotion;
+ (NSString *) stringWithClock: (int) seconds;
- (void) updateClocks;
- (IBAction) buttonTakeback: (id) sender;
- (IBAction) buttonTakeback2: (id) sender;
- (IBAction) buttonDraw: (id) sender;
- (IBAction) buttonResign: (id) sender;
- (IBAction) buttonAdjurn: (id) sender;
- (IBAction) buttonAbort: (id) sender;
- (BOOL)splitView: (NSSplitView *) sender canCollapseSubview: (NSView *) subview;
- (float)splitView: (NSSplitView *) sender constrainMaxCoordinate: (float) proposedMax ofSubviewAt:(int)offset;
- (float)splitView: (NSSplitView *) sender constrainMinCoordinate: (float) proposedMin ofSubviewAt:(int)offset;

@end
