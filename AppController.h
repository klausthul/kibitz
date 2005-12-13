// iscinterface
// $Id$

#import "global.h"
#import "ChessServerListControl.h"
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
