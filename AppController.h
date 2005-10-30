/* AppController */

#import <Cocoa/Cocoa.h>
#import "game.h"
#import "ChessServer.h"
#import "Seek.h"
@class ChessServerListControl;

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
}

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)proposedFrameSize;
- (void) userMoveFrom: (ChessField) from to: (ChessField) to;
- (void) dealloc;
- (IBAction) selectedPromotionPiece: (id) sender;
- (IBAction) selectServer: (id) sender;
- (IBAction) finishServerSelection: (id) sender;
- (IBAction) toggleSeekDrawer: (id) sender;
+ (void) initialize;

@end
