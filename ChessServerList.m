// icsinterface
// $Id$

#import "ChessServerList.h"

@implementation ChessServerList

- (ChessServerList *) init
{
//	[super init];
	servers = [NSMutableArray arrayWithCapacity:30];
	[servers retain];
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
	return cs;
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
	return [servers objectAtIndex:i];
}

- (void) addNewServerName: (NSString *) name Address: (NSString *) address port: (int) port userName: (NSString *) userName userPassword: (NSString *) userPassword 
 initCommands: (NSString *) initCommands {
	ChessServer *s = [self addNewServer];
	s->serverName = [name retain];
	s->serverAddress = [address retain];
	s->serverPort = [[NSNumber numberWithInt:port] retain];
	s->userName = [userName retain];
	s->userPassword = [userPassword retain];
	s->initCommands = [initCommands retain];
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

