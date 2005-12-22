// iscinterface
// $Id: AppController.h 69 2005-12-19 07:36:40Z kthul $

#import "global.h"

@interface ChatWindowController : NSWindowController {
	ChessServerConnection *serverConnection;
	IBOutlet NSTextField *serverInput;
	IBOutlet NSTableView *serverOutput;
}

- (ChatWindowController *) initWithServerConnection: (ChessServerConnection *) sc;
- (IBAction) newPlayWindow: (id) sender;
- (IBAction) newChatWindow: (id) sender;
- (IBAction) commandEntered: (id) sender;
- (void) observeValueForKeyPath: (NSString *) keyPath ofObject: (id) object change: (NSDictionary *) change context: (void *) context;

@end
