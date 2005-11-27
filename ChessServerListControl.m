#import "ChessServerListControl.h"

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

- (id) init
{
	if ((self = [super initWithWindowNibFile: @"ServerSelector"]) != nil) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		chessServerList = [NSKeyedUnarchiver unarchiveObjectWithData: [defaults objectForKey:@"ICSChessServers"]];
		[chessServerList retain];
	}
	return self;
}

- (IBAction) updateDefaults: (id) sender
{
	NSDate *serverData = [NSKeyedArchiver archivedDataWithRootObject:chessServerList];
	[[NSUserDefaults standardUserDefaults] setObject:serverData forKey:@"ICSChessServers"];
}

- (IBAction) finishServerSelection: (id) sender
{
	printf("Finish ServerSelect\n");
	[serverSelect orderOut:sender];
	if ([(NSButton *) sender tag] == 2) {
		if (chessServerConnection != nil)
			[chessServerConnection release];
		chessServerConnection = [[ChessServerConnection alloc] initWithChessServer: [chessServerListControl currentServer]]; 
	}
	[NSApp endSheet:serverSelect returnCode: 1];
}
@end


