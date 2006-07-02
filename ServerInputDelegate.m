/*
	$Id: GameWindowController.h 111 2006-07-02 05:04:01Z kthul $

	Copyright 2006 Klaus Thul (klaus.thul@mac.com)
	This file is part of kibitz.

	kibitz is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by 
	the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

	kibitz is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of 
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License along with kibitz; if not, write to the 
	Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/

#import "ServerInputDelegate.h"


@implementation ServerInputDelegate

- (ServerInputDelegate *) init
{
	if ((self = [super init]) != nil) {
		positionInHistory = -1;
		commandHistory = [[NSMutableArray arrayWithCapacity: 1000] retain];
	}
	return self;
}

- (void) dealloc
{
	[commandHistory release];
	[super dealloc];
}

- (IBAction) commandEntered: (id) sender
{
	NSString *command = [serverInput stringValue];
	[commandHistory addObject: command];
	positionInHistory = -1;
	[windowController commandEntered: command];
	[serverInput setStringValue: @""];
	[[windowController window] makeFirstResponder: serverInput];
}

- (BOOL) control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)command
{
	if (command == @selector(moveUp:)) {
		if ((positionInHistory != 0) && ([commandHistory count] > 0)) {
			if (positionInHistory < 0) {
				[uncommittedEdit release];
				uncommittedEdit = [[serverInput stringValue] retain];
				positionInHistory = [commandHistory count] - 1;
			} else
				positionInHistory--;
			[serverInput setStringValue: [commandHistory objectAtIndex: positionInHistory]];
		}
		return TRUE;
	} else if (command == @selector(moveDown:)) {
		if (positionInHistory >= 0) {
			if (positionInHistory >= (int) [commandHistory count] - 1) {
				if (uncommittedEdit != nil) {
					[serverInput setStringValue: uncommittedEdit];
					[uncommittedEdit release];
					uncommittedEdit = nil;
				}
				positionInHistory = -1;
			} else {
				[serverInput setStringValue: [commandHistory objectAtIndex: ++positionInHistory]];
			}
		}
		return TRUE;
	} else
		return FALSE;
}

@end
