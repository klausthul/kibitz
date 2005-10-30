//
//  chessserver.m
//  icsinterface
//
//  Created by Thul Klaus on 10/23/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

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


@implementation ChessServerListControl

- (IBAction) userAddNewServer: (id) sender
{
	[chessServerList addNewServer];
	[serverList reloadData];
}

- (IBAction) userDeleteCurrentServer: (id) sender
{
	int i = [serverList selectedRow];
	if (i != -1)
		[chessServerList removeServerAtIndex:i];
	[serverList reloadData];
}

- (int) numberOfRowsInTableView: (NSTableView *) aTableView
{
	return [chessServerList numServers];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	NSString *name = [[chessServerList serverAtIndex:rowIndex] serverName];
	return (name != nil) ? name : @"<undefined>";
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	[[chessServerList serverAtIndex:rowIndex] setServerName: anObject];
}

- (void) tableViewSelectionDidChange:(NSNotification *)aNotification
{
	ChessServer *s;
	int n = [serverList selectedRow];
	if (n < 0) {
		[serverName setEnabled: NO];
		[serverAddress setEnabled: NO];
		[serverUserName setEnabled: NO];
		[serverPassword setEnabled: NO];
		[serverPort setEnabled: NO];
		[serverInitialization setEnabled: NO];
	} else {
		s = [chessServerList serverAtIndex: n];
		[serverName bind:@"value" toObject:s withKeyPath:@"serverName" options:nil];
		[serverAddress bind:@"value" toObject:s withKeyPath:@"serverAddress" options:nil];
		[serverUserName bind:@"value" toObject:s withKeyPath:@"userName" options:nil];
		[serverPassword bind:@"value" toObject:s withKeyPath:@"userPassword" options:nil];
		[serverPort bind:@"value" toObject:s withKeyPath:@"serverPort" options:nil];
		[serverInitialization bind:@"value" toObject:s withKeyPath:@"initCommands" options:nil];
		[serverName setEnabled: YES];
		[serverAddress setEnabled: YES];
		[serverUserName setEnabled: YES];
		[serverPassword setEnabled: YES];
		[serverPort setEnabled: YES];
		[serverInitialization setEnabled: YES];
	}
}

- (ChessServer *) currentServer
{
	int n = [serverList selectedRow];
	if (n < 0)
		return nil;
	else
		return [chessServerList serverAtIndex: n];
}

- (void) awakeFromNib
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *test = [defaults objectForKey:@"Test"];
	NSLog(test);
	chessServerList = [NSKeyedUnarchiver unarchiveObjectWithData: [defaults objectForKey:@"ICSChessServers"]];
	[chessServerList retain];
}

- (IBAction) updateDefaults: (id) sender
{
	NSDate *serverData = [NSKeyedArchiver archivedDataWithRootObject:chessServerList];
	[[NSUserDefaults standardUserDefaults] setObject:serverData forKey:@"ICSChessServers"];
}
@end

