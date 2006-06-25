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

#import "AppController.h"
#import "SeekControl.h"
#import "PreferenceController.h"
#import "ChessServerListControl.h"

@implementation AppController

+ (void) initialize
{ 
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	ChessServer *s = [[ChessServer alloc] init];
	[s setServerName: @"Free Internet Chess Server (FICS)"];
	[s setServerAddress: @"69.36.243.188"];
	[s setServerPort: [NSNumber numberWithInt: 5000]];
	[s setInitCommands: @"iset seekremove 1\niset seekinfo 1\niset gameinfo 1\nset height 200\n"];
	[s setUsetimeseal: YES];
	NSMutableArray *defaultChessServers = [NSMutableArray arrayWithObject: s];
	NSMutableArray *defaultSeeks = [NSMutableArray arrayWithObjects: [[[Seek alloc] init] autorelease], nil];
	NSDictionary *defaultSeeksAndServers = [NSDictionary dictionaryWithObjectsAndKeys: defaultChessServers, @"chessServers", defaultSeeks, @"seeks", nil, nil];
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject: defaultSeeksAndServers];
	[defaultValues setObject:data forKey:@"seeksAndServers"];
	[defaultValues setValue: [NSNumber numberWithInt: 1] forKey: @"soundDefault"];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
	gSounds = [[Sound alloc] init];
}

- (AppController *) init
{
	if ((self = [super init]) != nil) {
		serverConnections = [[NSMutableArray arrayWithCapacity: 20] retain];
		seekControl = [(SeekControl *) [SeekControl alloc] initWithAppController: self];
		chessServerListControl = [[ChessServerListControl alloc] initWithAppController: self];
		
		NSData *d = nil;
		NSDictionary *seeksAndServers = nil;
		if ((d = [[NSUserDefaults standardUserDefaults] objectForKey: @"seeksAndServers"]) != nil)
			if ((seeksAndServers = [NSKeyedUnarchiver unarchiveObjectWithData: d]) != nil) {
				chessServers = [[seeksAndServers objectForKey: @"chessServers"] retain];
				seeks = [[seeksAndServers objectForKey: @"seeks"] retain];
			}
		if (chessServers == nil)
			chessServers = [[NSMutableArray arrayWithCapacity: 10] retain];
		if (seeks == nil)
			seeks = [[NSMutableArray arrayWithCapacity: 10] retain];
	}
	return self;
}

- (void) awakeFromNib
{
	NSEnumerator *e = [chessServers objectEnumerator];
	ChessServer *cs;
	bool autoConnect = FALSE;
	while ((cs = [e nextObject]) != nil)
		if ([cs connectAtStartup]) {
			[self connectChessServer: cs];
			autoConnect = TRUE;
		}
	if (!autoConnect)
		[chessServerListControl showWindow: self];
}

- (void) dealloc
{
	[chessServerListControl release];
	[serverConnections release];
	[preferenceController release];
	[seekControl release];
	[chessServers release];
	[super dealloc];
}

- (void) showChessServerSelectorWindow
{
	[chessServerListControl show: self];
}

- (IBAction) selectServer: (id) sender
{
	[self showChessServerSelectorWindow];
}

- (IBAction) newSeek: (id) sender
{
	[seekControl show: sender];
}

- (void) newSeekForServer: (ChessServerConnection *) csc
{
	[self newSeek: self];
	[seekControl  setSelectedConnection: csc];
}

- (void) connectChessServer: (ChessServer *) cs
{	
	ChessServerConnection *csc = [[[ChessServerConnection alloc] initWithChessServer: cs appController: self] autorelease]; 
	if (csc != nil) {
//		[chessServerListControl close];
		[self willChangeValueForKey: @"serverConnections"];
		[serverConnections addObject: csc];
		[self didChangeValueForKey: @"serverConnections"];
		[seekControl setValue: csc forKey: @"selectedConnection"];
	}
}

- (void) closeServerConnection: (ChessServerConnection *) csc
{	
	if (csc != nil) {
		[self willChangeValueForKey: @"serverConnections"];
		[serverConnections removeObject: csc];
		[self didChangeValueForKey: @"serverConnections"];
		if ([serverConnections count] == 0)
			[self showChessServerSelectorWindow]; 
	}
}

- (NSArray *) serverConnections
{
	return serverConnections;
}

- (NSApplicationTerminateReply) applicationShouldTerminate: (NSApplication *) sender
{
	if (([serverConnections count] == 0)
	 || (NSRunAlertPanel(@"Confirm quit", @"You are currently connected to a chess server. Quit anyway?", @"Yes", @"No", nil)
	     == NSAlertDefaultReturn)) {
		NSMutableDictionary *seeksAndServers = [NSMutableDictionary dictionaryWithCapacity: 2];
		[seeksAndServers setObject: chessServers forKey: @"chessServers"];
		[seeksAndServers setObject: seeks forKey: @"seeks"];
		NSData *d = [NSKeyedArchiver archivedDataWithRootObject: seeksAndServers];
		[[NSUserDefaults standardUserDefaults] setObject: d forKey: @"seeksAndServers"];
		return NSTerminateNow;
	} else
		return NSTerminateCancel;
}

- (IBAction) showPreferenceController: (id) sender {
	if (preferenceController == nil)
		preferenceController = [[PreferenceController alloc] initWithAppController: self];
	[preferenceController showWindow: self];
}

- (SeekControl *) seekControl
{
	return seekControl;
}

- (void) closeSeekWindow
{
	[[seekControl window] close];
}

@end
