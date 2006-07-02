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

#import "ChessServer.h"

@implementation ChessServer

- (void) setServerName: (NSString *) n
{
	[serverName release];
	serverName = [n retain];
}

- (NSString *) serverName
{
	return serverName;
}

- (void) setServerAddress: (NSString *) s
{
	[serverAddress release];
	serverAddress = [s retain];
}

- (void) setServerPort: (NSNumber *) i
{
	[serverPort release];
	serverPort = [i retain];
}

- (void) setUserName: (NSString *) s
{
	[userName release];
	userName = [s retain];
}

- (void) setUserPassword: (NSString *) s
{
	[userPassword release];
	userPassword = [s retain];
}

- (void) setInitCommands: (NSString *) s
{
	[initCommands release];
	initCommands = [s retain];
}

- (void) setUsetimeseal: (bool) ts
{
	useTimeseal = ts;
}

- (void) setConnectAtStartup: (bool) cas
{
	connectAtStartup = cas;
}

- (void) setIssueSeek: (bool) is
{
	issueSeek = is;
}

- (NSString *) serverAddress
{
	return [[serverAddress retain] autorelease];
}

- (NSNumber *) serverPort
{
	return [[serverPort retain] autorelease];
}

- (NSString *) userName
{
	return [[userName retain] autorelease];
}

- (NSString *) userPassword
{
	return [[userPassword retain] autorelease];
}

- (NSString *) initCommands
{
	return [[initCommands retain] autorelease];
}

- (BOOL) useTimeseal
{
	return useTimeseal;
}

- (BOOL) connectAtStartup
{
	return connectAtStartup;
}

- (BOOL) issueSeek
{
	return issueSeek;
}

- (void) setSeek: (Seek *) s
{
	[seek release];
	seek = [s retain];
}

- (Seek *) seek
{
	return seek;
}

- (id) initWithCoder: (NSCoder *) coder
{
	if ((self = [super init]) != nil) {
		[self setServerName: [coder decodeObjectForKey: @"serverName"]];
		[self setServerAddress: [coder decodeObjectForKey: @"serverAddress"]];
		[self setServerPort: [coder decodeObjectForKey: @"serverPort"]];
		[self setUserName: [coder decodeObjectForKey: @"userName"]];
		[self setUserPassword: [coder decodeObjectForKey: @"userPassword"]];
		[self setInitCommands: [coder decodeObjectForKey: @"initCommands"]];
		[self setUsetimeseal: [coder decodeBoolForKey: @"useTimeseal"]];
		[self setConnectAtStartup: [coder decodeBoolForKey: @"connectAtStartup"]];
		[self setIssueSeek: [coder decodeBoolForKey: @"issueSeek"]];
		[self setSeek: [coder decodeObjectForKey: @"seek"]];
	}
	return self;
}

- (void) encodeWithCoder: (NSCoder *) coder
{
	[coder encodeObject: [self serverName] forKey: @"serverName"];
	[coder encodeObject: serverAddress forKey: @"serverAddress"];
	[coder encodeObject: serverPort forKey: @"serverPort"];
	[coder encodeObject: userName forKey: @"userName"];
	[coder encodeObject: userPassword forKey: @"userPassword"];
	[coder encodeObject: initCommands forKey: @"initCommands"];
	[coder encodeBool: useTimeseal forKey: @"useTimeseal"];
	[coder encodeBool: connectAtStartup forKey: @"connectAtStartup"];
	[coder encodeBool: issueSeek forKey: @"issueSeek"];
	[coder encodeObject: seek forKey: @"seek"];
}

- (NSString *) description
{
	return [self serverName];
}

@end



