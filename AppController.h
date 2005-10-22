/* AppController */

#import <Cocoa/Cocoa.h>
#import "game.h"

@interface AppController : NSObject
{
    IBOutlet NSWindow *mainWindow;
	IBOutlet NSTextView *serverOutput;
	IBOutlet NSTextField *serverInput;
	IBOutlet Game *game;
	NSInputStream *serverIS;
	NSOutputStream *serverOS;
	char lineBuf[4096];
	int lastChar;
}

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)proposedFrameSize;
- (void) userMoveFrom: (ChessField) from to: (ChessField) to;
- (void) dealloc;

@end
