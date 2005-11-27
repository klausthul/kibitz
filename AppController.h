// iscinterface
// $Id$

#import <Cocoa/Cocoa.h>
#import "Game.h"
#import "ChessServerListControl.h"
#import "SeekGraph.h"
#import "ChessView.h"

#define min(a, b) (((a) < (b)) ? (a) : (b))

@class Game, ChessServer, ChessServerListControl;

@interface AppController : NSObject
{
    IBOutlet NSWindow *mainWindow;
	IBOutlet NSTextView *serverOutput;
	IBOutlet NSTextField *serverInput;
	IBOutlet Game *game;
	IBOutlet NSWindow *promotionPiece;
	IBOutlet NSWindow *serverSelect;
	IBOutlet SeekGraph *seekGraph;
	IBOutlet ChessServerListControl *chessServerListControl;
	IBOutlet NSDrawer *seekDrawer;
	NSInputStream *serverIS;
	NSOutputStream *serverOS;
	char lineBuf[4096];
	char move[10];
	int lastChar;
	ChessServer *currentServer;
	bool sendNamePassword, sendInit;
	NSTimer *timer;
}

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)proposedFrameSize;
- (void) userMoveFrom: (ChessField) from to: (ChessField) to;
- (void) dealloc;
- (IBAction) selectedPromotionPiece: (id) sender;
- (IBAction) selectServer: (id) sender;
- (IBAction) finishServerSelection: (id) sender;
- (IBAction) toggleSeekDrawer: (id) sender;
- (void) updateClock: (NSTimer *) aTimer;
+ (void) initialize;

@end
