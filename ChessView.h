/* ChessView */

#import <Cocoa/Cocoa.h>
#import "game.h"

@interface ChessView : NSView
{
	    IBOutlet Game *game;
		NSImage *pieces[16];
}

@end
