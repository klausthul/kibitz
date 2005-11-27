#import <Cocoa/Cocoa.h>
#import <ChessServerList.h>
@class ChessServer, ChessServerList;

@interface ChessServerListControl : NSWindowController {
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

