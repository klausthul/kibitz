#import "global.h"
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


