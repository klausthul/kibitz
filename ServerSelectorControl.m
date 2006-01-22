// icsinterface
// $Id: ServerSelectorControl.m 58 2005-12-18 16:30:20Z kthul $

#import "ServerSelectorControl.h"


@implementation ServerSelectorControl

- (id) init 
{
	if ((self = [super initWithWindowNibName: @"Seek"]) != nil) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		chessServerList = [NSKeyedUnarchiver unarchiveObjectWithData: [defaults objectForKey:@"ICSChessServers"]];
		[chessServerList retain];
	}
	return self;
}

@end
