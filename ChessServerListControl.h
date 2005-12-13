// icsinterface
// $Id$

#import "global.h"
#import "ChessServerConnection.h"
#import "ChessServerList.h"

@interface ChessServerListControl : NSWindowController <ChessServerErrorHandler> {
	ChessServerList *chessServerList;
	IBOutlet NSTableView *serverList;
	IBOutlet NSTextField *serverName, *serverAddress, *serverUserName, *serverPassword, *serverPort;
	IBOutlet NSTextField *serverInitialization;
}

- (IBAction) userAddNewServer: (id) sender;
- (IBAction) userDeleteCurrentServer: (id) sender;
- (ChessServer *) currentServer;
- (IBAction) updateDefaults: (id) sender;
- (id) init;
- (void) show: (id) sender;
- (IBAction) buttonSelect: (id) sender;
- (IBAction) buttonCancel: (id) sender;

@end

