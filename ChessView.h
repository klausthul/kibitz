// icsinterface
// $Id$

#import "global.h"
#import "Game.h"
#import "AppController.h"

@interface ChessView : NSView
{
	IBOutlet GameWindowController *gameWindowController;
	IBOutlet NSWindow *promotionDialog;
	ChessMove *showBoard;
	NSImage *pieces[16];
	struct ChessField fromMouse, toMouse;
}

- (void) setShowBoard: (ChessMove *) board;
- (IBAction) selectedPromotionPiece: (id) sender;

@end
