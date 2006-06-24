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


#import "ChessServerListControl.h"

@implementation ChessServerListControl

- (ChessServerListControl *) initWithAppController: (AppController *) ac 
{
	if ((self = [super initWithWindowNibName: @"ServerSelector"]) != nil) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		chessServerList = [NSKeyedUnarchiver unarchiveObjectWithData: [defaults objectForKey:@"ICSChessServers"]];
		[chessServerList retain];
		appController = [ac retain];
	}
	return self;
}

- (void) dealloc
{
	[chessServerList release];
	[appController release];
	[super dealloc];
}

- (IBAction) updateDefaults: (id) sender
{
	NSData *serverData = [NSKeyedArchiver archivedDataWithRootObject:chessServerList];
	[[NSUserDefaults standardUserDefaults] setObject:serverData forKey:@"ICSChessServers"];
}

- (IBAction) buttonSelect: (id) sender
{
	[appController connectChessServer: [chessServerList serverAtIndex: [serverListArrayController selectionIndex]]];
}

- (IBAction) buttonCancel: (id) sender
{
	[[self window] close];
}

- (void) show: (id) sender
{
	[self showWindow: sender];
}

- (ChessServer *) serverAtIndex: (int) num
{
	return [chessServerList serverAtIndex: num];
}

@end


