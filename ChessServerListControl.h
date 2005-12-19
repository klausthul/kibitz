// icsinterface
// $Id$

#import "global.h"
#import "ChessServerConnection.h"
#import "ChessServerList.h"

@interface ChessServerListControl : NSWindowController <ChessServerErrorHandler> {
	ChessServerList *chessServerList;
	AppController *appController;
	IBOutlet NSTableView *serverList;
	IBOutlet NSTextField *serverName, *serverAddress, *serverUserName, *serverPassword, *serverPort;
	IBOutlet NSTextField *serverInitialization;
}

- (IBAction) userAddNewServer: (id) sender;
- (IBAction) userDeleteCurrentServer: (id) sender;
- (ChessServer *) currentServer;
- (IBAction) updateDefaults: (id) sender;
- (ChessServerListControl *) initWithAppController: (AppController *) ac;
- (void) show: (id) sender;
- (IBAction) buttonSelect: (id) sender;
- (IBAction) buttonCancel: (id) sender;

@end

