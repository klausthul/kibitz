//  ChessServer.h

#import <Cocoa/Cocoa.h>
#import "AppController.h"

@interface ChessServer : NSObject <NSCoding> {
	@public
	NSString *serverName;
	NSString *serverAddress;
	NSNumber *serverPort;
	NSString *userName;
	NSString *userPassword;
	NSString *initCommands;
}

- (void) setServerName: (NSString *) n;
- (NSString *) serverName;

@end

@interface ChessServerList : NSObject <NSCoding> {
	NSMutableArray *servers;
}

- (ChessServerList *) init;
- (void) dealloc;
- (ChessServer *) addNewServer;
- (void) removeServerAtIndex: (int) i;
- (int) numServers;
- (void) addNewServerName: (NSString *) name Address: (NSString *) address port: (int) port userName: (NSString *) userName userPassword: (NSString *) userPassword 
 initCommands: (NSString *) initCommands;
@end

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
