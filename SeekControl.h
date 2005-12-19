// icsinterface
// $Id$

#import "global.h"

@interface SeekControl : NSWindowController {
	AppController *appController;
	IBOutlet NSArrayController *seekArrayController, *serverArrayController;
}

- (SeekControl *) initWithAppController: (AppController *) ac;
- (void) dealloc;
- (IBAction) seek: (id) sender;
- (IBAction) cancel: (id) sender;
- (void) show: (id) sender;
- (AppController *) appController;

@end
