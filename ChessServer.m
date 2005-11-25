#import "ChessServer.h"

@implementation ChessServer

- (void) setServerName: (NSString *) n
{
	serverName = [n retain];
}

- (NSString *) serverName
{
	return serverName;
}

- (id) initWithCoder: (NSCoder *) coder
{
	if (self = [super init]) {
		[self setServerName: [coder decodeObjectForKey: @"serverName"]];
		serverAddress = [[coder decodeObjectForKey: @"serverAddress"] retain];
		serverPort = [[coder decodeObjectForKey: @"serverPort"] retain];
		userName = [[coder decodeObjectForKey: @"userName"] retain];
		userPassword = [[coder decodeObjectForKey: @"userPassword"] retain];
		initCommands = [[coder decodeObjectForKey: @"initCommands"] retain];
	}
	return self;
}

- (void) encodeWithCoder: (NSCoder *) coder
{
	[coder encodeObject: [self serverName] forKey: @"serverName"];
	[coder encodeObject: serverAddress forKey: @"serverAddress"];
	[coder encodeObject: serverPort forKey: @"serverPort"];
	[coder encodeObject: userName forKey: @"userName"];
	[coder encodeObject: userPassword forKey: @"userPassword"];
	[coder encodeObject: initCommands forKey: @"initCommands"];
}

@end



