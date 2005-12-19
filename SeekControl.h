// icsinterface
// $Id$

#import "global.h"

@interface SeekControl : NSWindowController {
//	NSMutableArray *seeks;
	IBOutlet NSArrayController *arrayController;
}

- (id) init;
- (void) dealloc;
- (IBAction) seek: (id) sender;
- (void) show: (id) sender;

@end
