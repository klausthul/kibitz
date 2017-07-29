/*
	$Id$

	Copyright 2006 Klaus Thul (klaus.thul@mac.com)
	This file is part of Kibitz.

	Kibitz is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by 
	the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

	Kibitz is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of 
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License along with Kibitz; if not, write to the 
	Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/

#import "SeekControl.h"
#import "Seek.h"
#import "ChessServerConnection.h"

@implementation SeekControl

- (SeekControl *) initSeekControlWithAppController: (AppController *) ac 
{
	if ((self = [super initWithWindowNibName: @"Seek"]) != nil) {
		appController = [ac retain];
	}
	return self;
}

- (void) dealloc
{
	[appController release];
	[super dealloc];
}

- (NSArray *) getSelectedSeeks
{
	return seekArrayController.selectedObjects;
}

- (void) show: (id) sender
{
	[self showWindow: sender];
	[self.window makeKeyAndOrderFront: sender];
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
