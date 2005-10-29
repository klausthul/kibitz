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

- (IBAction) userAddNewServer: (id) sender
{
	[self addNewServer];
	[serverList reloadData];
}

- (IBAction) userDeleteCurrentServer: (id) sender
{
	int i = [serverList selectedRow];
	if (i != -1)
		[servers removeObjectAtIndex:i];
	[serverList reloadData];
}

- (int) numberOfRowsInTableView: (NSTableView *) aTableView
{
	return [servers count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	NSString *name = [[servers objectAtIndex:rowIndex] serverName];
	return (name != nil) ? name : @"<undefined>";
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	[[servers objectAtIndex:rowIndex] setServerName: anObject];
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
		s = [servers objectAtIndex: n];
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
		return [servers objectAtIndex: n];
}
@end

