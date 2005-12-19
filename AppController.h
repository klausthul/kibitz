// iscinterface
// $Id$

#import "global.h"
#import "ChessServerListControl.h"
#import "ChessServerConnection.h"
#import "SeekControl.h"

@interface AppController : NSObject
{
	SeekControl *seekControl;
	ChessServerListControl *chessServerListControl;
	NSMutableArray *serverConnections;
}

+ (void) initialize;
- (AppController *) init;
- (void) dealloc;
- (IBAction) selectServer: (id) sender;
- (IBAction) newSeek: (id) sender;
- (void) connectChessServer: (ChessServer *) cs;
- (NSArray *) serverConnections;

@end
