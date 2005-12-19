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
	}
	return self;
}

- (void) awakeFromNib
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray *df = [NSKeyedUnarchiver unarchiveObjectWithData: [defaults objectForKey:@"Seeks"]];
	[seekArrayController addObjects: df];
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

- (IBAction) save: (id) sender
{
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject: [seekArrayController content]];
	[[NSUserDefaults standardUserDefaults] setObject:data forKey:@"Seeks"];
}

- (void) show: (id) sender
{
	[self showWindow: sender];
	[[self window] makeKeyAndOrderFront: sender];
}

- (AppController *) appController
{
	return appController;
}

@end
