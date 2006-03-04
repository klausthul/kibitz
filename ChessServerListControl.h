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
#import "ChessServerConnection.h"
#import "ChessServerList.h"

@interface ChessServerListControl : NSWindowController {
	ChessServerList *chessServerList;
	AppController *appController;
	NSMutableString *emptyString;
	IBOutlet NSTableView *serverList;
	IBOutlet NSTextField *serverName, *serverAddress, *serverUserName, *serverPassword, *serverPort;
	IBOutlet NSTextView *serverInitialization;
	IBOutlet NSButton *useTimeseal;
}

- (IBAction) userAddNewServer: (id) sender;
- (IBAction) userDeleteCurrentServer: (id) sender;
- (ChessServer *) currentServer;
- (IBAction) updateDefaults: (id) sender;
- (ChessServerListControl *) initWithAppController: (AppController *) ac;
- (void) dealloc;
- (void) show: (id) sender;
- (IBAction) buttonSelect: (id) sender;
- (IBAction) buttonCancel: (id) sender;

@end

