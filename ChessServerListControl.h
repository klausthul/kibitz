// icsinterface
// $Id$

#import "global.h"
#import "ChessServerConnection.h"
#import "ChessServerList.h"

@interface ChessServerListControl : NSWindowController <ChessServerErrorHandler> {
	ChessServerList *chessServerList;
	AppController *appController;
	NSMutableString *emptyString;
	IBOutlet NSTableView *serverList;
	IBOutlet NSTextField *serverName, *serverAddress, *serverUserName, *serverPassword, *serverPort;
	IBOutlet NSTextView *serverInitialization;
}

- (IBAction) userAddNewServer: (id) sender;
- (IBAction) userDeleteCurrentServer: (id) sender;
- (ChessServer *) currentServer;
- (IBAction) updateDefaults: (id) sender;
- (ChessServerListControl *) initWithAppController: (AppController *) ac;
- (void) dealloc;
- (void) show: (id) sender;
- (IBAction) buttonSelect: (id) sender;
- (IBAction) buttonCancel: (id) sender;

@end

