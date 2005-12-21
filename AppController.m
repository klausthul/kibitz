// iscinterface
// $Id$

#import "AppController.h"
#import "SeekControl.h"

@implementation AppController

+ (void) initialize
{ 
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	ChessServerList *defaultServers = [[[ChessServerList alloc] init] autorelease];
	NSData *data;
	[defaultServers addNewServerName: @"Free Internet Chess Server (FICS)" Address: @"69.36.243.188" port: 5000 userName: nil userPassword: nil 
	 initCommands: @"iset seekremove 1\niset seekinfo 1\niset gameinfo 1\nset height 200\n"];
	data = [NSKeyedArchiver archivedDataWithRootObject:defaultServers];
	[defaultValues setObject:data forKey:@"ICSChessServers"];
	NSArray *defaultSeeks = [NSArray arrayWithObjects: [[[Seek alloc] init] autorelease], nil];
	data = [NSKeyedArchiver archivedDataWithRootObject: defaultSeeks];
	[defaultValues setObject: data forKey:@"Seeks"];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
	gSounds = [[Sound alloc] init];
}

- (AppController *) init
{
	if ((self = [super init]) != nil) {
		serverConnections = [[NSMutableArray arrayWithCapacity: 20] retain];
	}
	return self;
}

- (void) dealloc
{
	[chessServerListControl release];
	[serverConnections release];
	[super dealloc];
}

- (IBAction) selectServer: (id) sender
{
	if (chessServerListControl == nil)
		chessServerListControl = [[ChessServerListControl alloc] initWithAppController: self];
	[chessServerListControl show: sender];
}

- (IBAction) newSeek: (id) sender
{
	if (seekControl == nil)
		seekControl = [(SeekControl *) [SeekControl alloc] initWithAppController: self];
	[seekControl show: sender];
}

- (void) connectChessServer: (ChessServer *) cs
{	
	ChessServerConnection *csc = [[ChessServerConnection alloc] initWithChessServer: cs]; 
	if (csc != nil) {
		[csc setErrorHandler: chessServerListControl];
		[chessServerListControl close];
		[self willChangeValueForKey: @"serverConnections"];
		[serverConnections addObject: csc];
		[self didChangeValueForKey: @"serverConnections"];
		[seekControl setValue: csc forKey: @"selectedConnection"];
	}
}

- (NSArray *) serverConnections
{
	return serverConnections;
}

@end
