// icsinterface
// $Id$

#import "ChessServer.h"

@implementation ChessServer

- (void) setServerName: (NSString *) n
{
	[serverName release];
	serverName = [n retain];
}

- (NSString *) serverName
{
	return serverName;
}

- (void) setServerAddress: (NSString *) s
{
	[serverAddress release];
	serverAddress = [s retain];
}

- (void) setServerPort: (NSNumber *) i
{
	[serverPort release];
	serverPort = [i retain];
}

- (void) setUserName: (NSString *) s
{
	[userName release];
	userName = [s retain];
}

- (void) setUserPassword: (NSString *) s
{
	[userPassword release];
	userPassword = [s retain];
}

- (void) setInitCommands: (NSString *) s
{
	[initCommands release];
	initCommands = [s retain];
}

- (NSString *) serverAddress
{
	return [[serverAddress retain] autorelease];
}

- (NSNumber *) serverPort
{
	return [[serverPort retain] autorelease];
}

- (NSString *) userName;
{
	return [[userName retain] autorelease];
}

- (NSString *) userPassword
{
	return [[userPassword retain] autorelease];
}

- (NSString *) initCommands
{
	return [[initCommands retain] autorelease];
}

- (id) initWithCoder: (NSCoder *) coder
{
	if (self = [super init]) {
		[self setServerName: [coder decodeObjectForKey: @"serverName"]];
		[self setServerAddress: [coder decodeObjectForKey: @"serverAddress"]];
		[self setServerPort: [coder decodeObjectForKey: @"serverPort"]];
		[self setUserName: [coder decodeObjectForKey: @"userName"]];
		[self setUserPassword: [coder decodeObjectForKey: @"userPassword"]];
		[self setInitCommands: [coder decodeObjectForKey: @"initCommands"]];
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



