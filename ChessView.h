// icsinterface
// $Id$

#import "global.h"
#import "Game.h"
#import "AppController.h"

@interface ChessView : NSView
{
	Board *showBoard;
	NSImage *pieces[16];
	struct ChessField fromMouse, toMouse;
}

- (void) setShowBoard: (Board *) board;

@end
