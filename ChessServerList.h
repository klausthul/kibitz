#import <Cocoa/Cocoa.h>
#import <ChessServer.h>

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
