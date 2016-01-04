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

#import "AppController.h"
#import "SeekControl.h"
#import "PreferenceController.h"
#import "ChessServerListControl.h"
#import "Sound.h"

@implementation AppController

+ (void) initialize
{ 
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
    
    // See http://www.freechess.org/Help/HelpFiles/iset.html
	ChessServer *s = [[ChessServer alloc] init];
    s.serverName = @"Free Internet Chess Server (FICS)";
    s.serverAddress = @"freechess.org";
    s.serverPort = @(5000);
    s.initCommands = @" ";
    s.useTimeseal = NO;
    s.userName = @"guest";
    s.userPassword = @"guest";

	NSMutableArray *defaultChessServers = [NSMutableArray arrayWithObject: s];
	NSMutableArray *defaultSeeks = [NSMutableArray arrayWithObjects: [[[Seek alloc] init] autorelease], nil];
	NSDictionary *defaultSeeksAndServers = [NSDictionary dictionaryWithObjectsAndKeys: defaultChessServers, @"chessServers", defaultSeeks, @"seeks", nil, nil];
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject: defaultSeeksAndServers];
	defaultValues[@"seeksAndServers"] = data;
	[defaultValues setValue: @1 forKey: @"soundDefault"];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
	gSounds = [[Sound alloc] init];
}

- (AppController *) init
{
	if ((self = [super init]) != nil) {
		serverConnections = [[NSMutableArray arrayWithCapacity: 20] retain];
		seekControl = [[SeekControl alloc] initSeekControlWithAppController: self];
		chessServerListControl = [[ChessServerListControl alloc] initChessServerListControlWithAppController: self];
		
		NSData *d = nil;
		NSDictionary *seeksAndServers = nil;
		if ((d = [[NSUserDefaults standardUserDefaults] objectForKey: @"seeksAndServers"]) != nil)
			if ((seeksAndServers = [NSKeyedUnarchiver unarchiveObjectWithData: d]) != nil) {
				chessServers = [seeksAndServers[@"chessServers"] retain];
				seeks = [seeksAndServers[@"seeks"] retain];
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
		if (cs.connectAtStartup) {
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
		if (serverConnections.count == 0)
			[self showChessServerSelectorWindow]; 
	}
}

- (NSArray *) serverConnections
{
	return serverConnections;
}

- (NSApplicationTerminateReply) applicationShouldTerminate: (NSApplication *) sender
{
	if ((serverConnections.count == 0)
	 || (NSRunAlertPanel(@"Confirm quit", @"You are currently connected to a chess server. Quit anyway?", @"Yes", @"No", nil)
	     == NSAlertDefaultReturn)) {
		NSMutableDictionary *seeksAndServers = [NSMutableDictionary dictionaryWithCapacity: 2];
		seeksAndServers[@"chessServers"] = chessServers;
		seeksAndServers[@"seeks"] = seeks;
		NSData *d = [NSKeyedArchiver archivedDataWithRootObject: seeksAndServers];
		[[NSUserDefaults standardUserDefaults] setObject: d forKey: @"seeksAndServers"];
		return NSTerminateNow;
	} else
		return NSTerminateCancel;
}

- (IBAction) showPreferenceController: (id) sender {
	if (preferenceController == nil)
		preferenceController = [[PreferenceController alloc] initPreferenceControllerWithAppController: self];
	[preferenceController showWindow: self];
}

- (SeekControl *) seekControl
{
	return seekControl;
}

- (void) closeSeekWindow
{
	[seekControl.window close];
}

- (IBAction) switchAllSoundsOff: (id) sender
{
	NSEnumerator *e = [serverConnections objectEnumerator];
	ChessServerConnection *csc;
	while ((csc = [e nextObject]) != nil)
		[csc switchAllSoundsOff];
}

@end
