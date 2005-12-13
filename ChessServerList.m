// icsinterface
// $Id$

#import "ChessServerList.h"

@implementation ChessServerList

- (ChessServerList *) init
{
	if (self = [super init])
		servers = [[NSMutableArray arrayWithCapacity:30] retain];
	return self;
}

- (void) dealloc
{
	[servers release];
	[super dealloc];
}

- (ChessServer *) addNewServer
{
	ChessServer *cs = [[ChessServer alloc] init];
	[servers addObject: cs];
	return [cs autorelease];
}

- (void) removeServerAtIndex: (int) i
{
	[servers removeObjectAtIndex:i];
}

- (int) numServers
{
	return [servers count];
}

- (ChessServer *) serverAtIndex: (int) i
{
	return [[[servers objectAtIndex:i] retain] autorelease];
}

- (void) addNewServerName: (NSString *) name Address: (NSString *) address port: (int) port userName: (NSString *) userName userPassword: (NSString *) userPassword 
 initCommands: (NSString *) initCommands {
	ChessServer *s = [self addNewServer];
	[s setServerName: name];
	[s setServerAddress: address];
	[s setServerPort: [NSNumber numberWithInt:port]];
	[s setUserName: userName];
	[s setUserPassword: userPassword];
	[s setInitCommands: initCommands];
}

- (id) initWithCoder: (NSCoder *) coder
{
	if (self = [super init])
		servers = [[coder decodeObjectForKey:@"Servers"] retain];
	return self;
}

- (void) encodeWithCoder: (NSCoder *) coder
{
	[coder encodeObject:servers forKey:@"Servers"];
}

@end

