#import <Cocoa/Cocoa.h>
#import <ChessServerList.h>

@interface ChessServerListControl : NSObject {
	ChessServerList *chessServerList;
	IBOutlet NSTableView *serverList;
	IBOutlet NSTextField *serverName, *serverAddress, *serverUserName, *serverPassword, *serverPort;
	IBOutlet NSTextField *serverInitialization;
}

- (IBAction) userAddNewServer: (id) sender;
- (IBAction) userDeleteCurrentServer: (id) sender;
- (ChessServer *) currentServer;
- (void) awakeFromNib;
- (IBAction) updateDefaults: (id) sender;

@end

