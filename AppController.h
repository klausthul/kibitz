// iscinterface
// $Id$

#import <Cocoa/Cocoa.h>
#import "Game.h"
#import "ChessServerListControl.h"
#import "SeekGraph.h"
#import "ChessView.h"
#import "ChessServerConnection.h"

#define min(a, b) (((a) < (b)) ? (a) : (b))

@class Game, ChessServer, ChessServerListControl;

@interface AppController : NSObject
{
	ChessServerConnection *chessServerConnection;
	ChessServerListControl *chessServerListControl;
}

+ (void) initialize;
- (void) dealloc;
- (IBAction) selectServer: (id) sender;

@end
