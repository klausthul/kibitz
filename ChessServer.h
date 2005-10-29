//
//  ChessServer.h
//  icsinterface
//
//  Created by Thul Klaus on 10/23/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ChessServer : NSObject {
	@public
	NSString *serverName;
	NSString *serverAddress;
	NSNumber *serverPort;
	NSString *userName;
	NSString *userPassword;
	NSString *initCommands;
}

- (void) setServerName: (NSString *) n;
- (NSString *) serverName;

@end

@interface ChessServerList : NSObject {
	NSMutableArray *servers;
	IBOutlet NSTableView *serverList;
	IBOutlet NSTextField *serverName, *serverAddress, *serverUserName, *serverPassword, *serverPort;
	IBOutlet NSTextField *serverInitialization;
}

- (ChessServerList *) init;
- (void) dealloc;
- (ChessServer *) addNewServer;
- (IBAction) userAddNewServer: (id) sender;
- (IBAction) userDeleteCurrentServer: (id) sender;
- (ChessServer *) currentServer;

@end
