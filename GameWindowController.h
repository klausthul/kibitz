// icsinterface
// $Id$

#import "global.h"


@interface GameWindowController : NSWindowController {
	ChessServerConnection *serverConnection;
    IBOutlet NSWindow *mainWindow;
	IBOutlet NSTextView *serverOutput;
	IBOutlet NSTextField *serverInput;
	IBOutlet NSWindow *promotionPiece;
	IBOutlet NSWindow *serverSelect;
	IBOutlet ChessServerListControl *chessServerListControl;
	IBOutlet NSDrawer *seekDrawer;
	IBOutlet NSTableView *tableView;
	IBOutlet ChessView *chessView;
	IBOutlet NSTextField *upperClock, *lowerClock;
	char move[10];
	NSTimer *timer;
}

- (id) init;
- (void) addToServerOutput: (NSString *) s;
- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)proposedFrameSize;
- (void) userMoveFrom: (ChessField) from to: (ChessField) to;
- (void) dealloc;
- (IBAction) selectedPromotionPiece: (id) sender;
- (IBAction) finishServerSelection: (id) sender;
- (IBAction) toggleSeekDrawer: (id) sender;
- (void) updateClock: (NSTimer *) aTimer;

@end
