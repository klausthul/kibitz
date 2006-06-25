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

#import "global.h"
#import "AppController.h"

@interface ChessServer : NSObject <NSCoding> {
	NSString *serverName;
	NSString *serverAddress;
	NSNumber *serverPort;
	NSString *userName;
	NSString *userPassword;
	NSString *initCommands;
	BOOL useTimeseal, connectAtStartup, issueSeek;
	Seek *seek;
}

- (void) setServerName: (NSString *) n;
- (NSString *) serverName;
- (void) setServerAddress: (NSString *) s;
- (void) setServerPort: (NSNumber *) i;
- (void) setUserName: (NSString *) s;
- (void) setUserPassword: (NSString *) s;
- (void) setInitCommands: (NSString *) s;
- (void) setUsetimeseal: (bool) ts;
- (void) setConnectAtStartup: (bool) cas;
- (void) setIssueSeek: (bool) is;
- (NSString *) serverAddress;
- (NSNumber *) serverPort;
- (NSString *) userName;
- (NSString *) userPassword;
- (NSString *) initCommands;
- (BOOL) useTimeseal;
- (BOOL) connectAtStartup;
- (BOOL) issueSeek;
- (id) initWithCoder: (NSCoder *) coder;
- (void) encodeWithCoder: (NSCoder *) coder;
- (NSString *) description;

@end


