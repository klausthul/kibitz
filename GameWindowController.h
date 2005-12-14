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
- (IBAction) takeback: (id) sender;
- (IBAction) takeback2: (id) sender;
- (IBAction) draw: (id) sender;
- (IBAction) resign: (id) sender;
- (IBAction) adjurn: (id) sender;
- (IBAction) abort: (id) sender;
- (IBAction) newSeek: (id) sender;
- (IBAction) match: (id) sender;
- (IBAction) accept: (id) sender;
- (IBAction) decline: (id) sender;
- (IBAction) flipBoard: (id) sender;
- (IBAction) hideMoves: (id) sender;
- (IBAction) hideDialog: (id) sender;
- (IBAction) logout: (id) sender;
- (IBAction) reconnect: (id) sender;
- (IBAction) exportGame: (id) sender;
- (BOOL)splitView: (NSSplitView *) sender canCollapseSubview: (NSView *) subview;
- (float)splitView: (NSSplitView *) sender constrainMaxCoordinate: (float) proposedMax ofSubviewAt:(int)offset;
- (float)splitView: (NSSplitView *) sender constrainMinCoordinate: (float) proposedMin ofSubviewAt:(int)offset;
- (void) awakeFromNib;
- (NSToolbarItem *) toolbar: (NSToolbar *) toolbar itemForItemIdentifier: (NSString *) itemIdentifier willBeInsertedIntoToolbar: (BOOL) flag;
- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar; 
 - (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar *) toolbar;
 
@end
