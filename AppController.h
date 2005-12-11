// iscinterface
// $Id$

#import "global.h"
//#import "Game.h"
#import "ChessServerListControl.h"
//#import "SeekGraph.h"
//#import "ChessView.h"
#import "ChessServerConnection.h"

@interface AppController : NSObject
{
	ChessServerConnection *chessServerConnection;
	ChessServerListControl *chessServerListControl;
}

+ (void) initialize;
- (void) dealloc;
- (IBAction) selectServer: (id) sender;

@end
