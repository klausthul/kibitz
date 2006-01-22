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

#import "ChatWindowController.h"
#import "ChessServerConnection.h"

@implementation ChatWindowController

- (ChatWindowController *) initWithServerConnection: (ChessServerConnection *) sc
{
	if ((self = [super initWithWindowNibName: @"ChatWindow"]) != nil) {
		serverConnection = [sc retain];
		[sc addObserver: self forKeyPath: @"outputLines" options: 0 context: nil];
	}
	return self;
}

- (void) dealloc
{
	[serverConnection removeObserver: self forKeyPath: @"outputLines"];
	[serverConnection release];
	[super dealloc];
}

- (IBAction) newPlayWindow: (id) sender
{
	[serverConnection newPlayWindow];
}

- (IBAction) newChatWindow: (id) sender
{
	[[[ChatWindowController alloc] initWithServerConnection: serverConnection] showWindow: sender];
}

- (IBAction) commandEntered: (id) sender
{
	[serverConnection sendUserInputToServer: [serverInput stringValue]];
}

- (void) observeValueForKeyPath: (NSString *) keyPath ofObject: (id) object change: (NSDictionary *) change context: (void *) context
{
	[serverOutput scrollRowToVisible: [serverConnection lengthOutput] - 1];
}

@end
