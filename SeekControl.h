// icsinterface
// $Id$

#import "global.h"

@interface SeekControl : NSWindowController {
	AppController *appController;
	IBOutlet NSArrayController *arrayController;
}

- (SeekControl *) initWithAppController: (AppController *) ac;
- (void) dealloc;
- (IBAction) seek: (id) sender;
- (void) show: (id) sender;
- (AppController *) appController;

@end
