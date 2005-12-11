// icsinterface
// $Id$

#import "global.h"
#import "AppController.h"

@interface ChessServer : NSObject <NSCoding> {
	NSString *serverName;
	NSString *serverAddress;
	NSNumber *serverPort;
	NSString *userName;
	NSString *userPassword;
	NSString *initCommands;
}

- (void) setServerName: (NSString *) n;
- (NSString *) serverName;
- (void) setServerAddress: (NSString *) s;
- (void) setServerPort: (NSNumber *) i;
- (void) setUserName: (NSString *) s;
- (void) setUserPassword: (NSString *) s;
- (void) setInitCommands: (NSString *) s;
- (NSString *) serverAddress;
- (NSNumber *) serverPort;
- (NSString *) userName;
- (NSString *) userPassword;
- (NSString *) initCommands;

@end


