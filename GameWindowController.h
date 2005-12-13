// icsinterface
// $Id$

#import "global.h"
#import "ChessServerConnection.h"

@interface GameWindowController : NSWindowController {
	ChessServerConnection *serverConnection;
	IBOutlet NSTextView *serverOutput;
	IBOutlet NSTextField *serverInput;
	IBOutlet NSWindow *promotionPiece;
	IBOutlet NSDrawer *seekDrawer;
	IBOutlet NSTableView *tableView;
	IBOutlet ChessView *chessView;
	IBOutlet NSTextField *upperClock, *lowerClock;
	IBOutlet NSTableView *seekTable;
	IBOutlet NSPopUpButton *gameSelector;
	char move[10];
	NSTimer *timer;
	Game *activeGame;
	NSDictionary *gameList;
}

- (id) initWithServerConnection: (ChessServerConnection *) sc;
- (void) addToServerOutput: (NSString *) s;
- (void) dealloc;
- (IBAction) selectedPromotionPiece: (id) sender;
- (IBAction) toggleSeekDrawer: (id) sender;
- (void) updateClock: (NSTimer *) aTimer;
- (int) numberOfRowsInTableView: (NSTableView *) aTableView;
- (id) tableView:(NSTableView *) aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;
- (void) seekTableNeedsDisplay;
// - (void) setShowBoard: (Board *) board;
- (IBAction) selectGame: (id) sender;
- (void) setGameList: (NSDictionary *) gl;
- (void) updateGame: (Game *) g;
- (void) setActiveGame: (Game *) g;
- (Game *) activeGame;

@end
