/*
	$Id$

	Copyright 2006 Klaus Thul (klaus.thul@mac.com)
	This file is part of kibitz.

	kibitz is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by 
	the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

	kibitz is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of 
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License along with kibitz; if not, write to the 
	Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/

#import "SeekControl.h"
#import "Seek.h"
#import "ChessServerConnection.h"

@implementation SeekControl

- (SeekControl *) initWithAppController: (AppController *) ac 
{
	if ((self = [super initWithWindowNibName: @"Seek"]) != nil) {
		appController = [ac retain];
		seeks = [[NSMutableArray arrayWithCapacity: 10] retain];
	}
	return self;
}

- (void) awakeFromNib
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray *df = [NSKeyedUnarchiver unarchiveObjectWithData: [defaults objectForKey:@"Seeks"]];
	[self willChangeValueForKey: @"seeks"];
	[seeks addObjectsFromArray: df];
	[self didChangeValueForKey: @"seeks"];
}

- (void) dealloc
{
	[appController release];
	[seeks release];
	[super dealloc];
}

- (IBAction) seek: (id) sender
{
	NSArray *selectedSeeks = [seekArrayController selectedObjects];
	int i, m = [selectedSeeks count];
	for (i = 0; i < m; i++)
		[selectedConnection sendSeek: [selectedSeeks objectAtIndex: i]];
	[[self window] close];
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

- (void) setSelectedConnection: (ChessServerConnection *) csc
{
	selectedConnection = csc;
}

@end
