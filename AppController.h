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
}

+ (void) initialize;
- (void) dealloc;
- (IBAction) selectServer: (id) sender;
- (IBAction) newSeek: (id) sender;

@end
