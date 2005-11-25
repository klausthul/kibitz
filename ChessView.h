#import <Cocoa/Cocoa.h>
#import "Game.h"
#import "AppController.h"

@interface ChessView : NSView
{
	IBOutlet Game *game;
	IBOutlet AppController *appController;
	NSImage *pieces[16];
	ChessField fromMouse;
	ChessField toMouse;
}

@end
