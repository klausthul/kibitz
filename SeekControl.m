// icsinterface
// $Id$

#import "SeekControl.h"
#import "Seek.h"

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
	NSLog([[[arrayController selectedObjects] objectAtIndex: 0] seekDescriptionLine]);
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
