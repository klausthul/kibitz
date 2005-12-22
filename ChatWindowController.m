// iscinterface
// $Id: AppController.h 69 2005-12-19 07:36:40Z kthul $

#import "ChatWindowController.h"
#import "ChessServerConnection.h"

@implementation ChatWindowController

- (ChatWindowController *) initWithServerConnection: (ChessServerConnection *) sc
{
	if ((self = [super initWithWindowNibName: @"ChatWindow"]) != nil) {
		serverConnection = [sc retain];
		[sc addObserver: self forKeyPath: @"outputLines" options: 0 context: nil];
	}
	return self;
}

- (void) dealloc
{
	[serverConnection removeObserver: self forKeyPath: @"outputLines"];
	[serverConnection release];
	[super dealloc];
}

- (IBAction) newPlayWindow: (id) sender
{
	[serverConnection newPlayWindow];
}

- (IBAction) newChatWindow: (id) sender
{
	[[[ChatWindowController alloc] initWithServerConnection: serverConnection] showWindow: sender];
}

- (void) controlTextDidEndEditing: (NSNotification *) aNotification
{
	[serverConnection sendUserInputToServer: [serverInput stringValue]];
}

- (void) observeValueForKeyPath: (NSString *) keyPath ofObject: (id) object change: (NSDictionary *) change context: (void *) context
{
	[serverOutput scrollRowToVisible: [serverConnection lengthOutput] - 1];
}

@end
