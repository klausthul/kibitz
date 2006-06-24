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

#import "ChessServerList.h"

@implementation ChessServerList

- (ChessServerList *) init
{
	if ((self = [super init]) != nil)
		servers = [[NSMutableArray arrayWithCapacity:30] retain];
	return self;
}

- (void) dealloc
{
	[servers release];
	[super dealloc];
}

- (ChessServer *) addNewServer
{
	ChessServer *cs = [[ChessServer alloc] init];
	[self willChangeValueForKey: @"servers"];
	[servers addObject: cs];
	[self didChangeValueForKey: @"servers"];
	return [cs autorelease];
}

- (void) removeServerAtIndex: (int) i
{
	[self willChangeValueForKey: @"servers"];
	[servers removeObjectAtIndex:i];
	[self didChangeValueForKey: @"servers"];	
}

- (int) numServers
{
	return [servers count];
}

- (ChessServer *) serverAtIndex: (int) i
{
	if ((i < 0) || (i >= [servers count]))
		return nil;
	return [[[servers objectAtIndex:i] retain] autorelease];
}

- (void) addNewServerName: (NSString *) name Address: (NSString *) address port: (int) port userName: (NSString *) userName userPassword: (NSString *) userPassword 
 initCommands: (NSString *) initCommands useTimeseal: (BOOL) useTimeseal {
	ChessServer *s = [self addNewServer];
	[s setServerName: name];
	[s setServerAddress: address];
	[s setServerPort: [NSNumber numberWithInt:port]];
	[s setUserName: userName];
	[s setUserPassword: userPassword];
	[s setInitCommands: initCommands];
	[s setUsetimeseal: useTimeseal];
}

- (id) initWithCoder: (NSCoder *) coder
{
	if ((self = [super init]) != nil)
		servers = [[coder decodeObjectForKey:@"Servers"] retain];
	return self;
}

- (void) encodeWithCoder: (NSCoder *) coder
{
	[coder encodeObject:servers forKey:@"Servers"];
}

@end

