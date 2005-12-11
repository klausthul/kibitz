#import "global.h"
#import "ChessServer.h"
@class ChessServer;

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
- (ChessServer *) serverAtIndex: (int) i;
@end
