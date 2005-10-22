/* ChessView */

#import <Cocoa/Cocoa.h>
#import "game.h"

@interface ChessView : NSView
{
	IBOutlet Game *game;
	IBOutlet AppController *appController;
	NSImage *pieces[16];
	ChessField fromMouse;
	ChessField toMouse;
}

@end
