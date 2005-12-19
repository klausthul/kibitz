// icsinterface
// $Id$

#import "SeekControl.h"
#import "Seek.h"
#import "ChessServerConnection.h"

@implementation SeekControl

- (SeekControl *) initWithAppController: (AppController *) ac 
{
	if ((self = [super initWithWindowNibName: @"Seek"]) != nil) {
		appController = ac;
//		seeks = [[NSMutableArray arrayWithCapacity: 20] retain];
//		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//		chessServerList = [NSKeyedUnarchiver unarchiveObjectWithData: [defaults objectForKey:@"ICSChessServers"]];
//		[chessServerList retain];
	}
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

- (IBAction) seek: (id) sender
{
	NSArray *selectedSeeks = [seekArrayController selectedObjects];
	int i, m = [selectedSeeks count];
	ChessServerConnection *selectedConnection = [[serverArrayController selectedObjects] objectAtIndex: 0];
	for (i = 0; i < m; i++)
		[selectedConnection sendSeek: [selectedSeeks objectAtIndex: i]];
}

- (IBAction) cancel: (id) sender
{
	[[self window] close];
}

- (void) show: (id) sender
{
	[self showWindow: sender];
	[[self window] makeKeyAndOrderFront: sender];
}

- (AppController *) appController
{
	printf("App Controller\n");
	return appController;
}

@end
