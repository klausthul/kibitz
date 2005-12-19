// icsinterface
// $Id$

#import "SeekControl.h"

@implementation SeekControl

- (id) init 
{
	if ((self = [super initWithWindowNibName: @"Seek"]) != nil) {
		seeks = [[NSMutableArray arrayWithCapacity: 20] retain];
//		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//		chessServerList = [NSKeyedUnarchiver unarchiveObjectWithData: [defaults objectForKey:@"ICSChessServers"]];
//		[chessServerList retain];
	}
	return self;
}

- (void) dealloc
{
	[seeks release];
	[super dealloc];
}

- (IBAction) seek: (id) sender
{
}

- (IBAction) unseek: (id) sender
{
}

- (IBAction) unseekAll: (id) sender
{
}

- (void) show: (id) sender
{
	[self showWindow: sender];
	[[self window] makeKeyAndOrderFront: sender];
}

@end
