// icsinterface
// $Id$

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
