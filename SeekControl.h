// icsinterface
// $Id$

#import "global.h"

@interface SeekControl : NSWindowController {
	NSMutableArray *seeks;
	IBOutlet NSTableView *seekList;
	IBOutlet NSTextField *timeStart, *timeIncrement, *ratingFrom, *ratingTo, *wild;
	IBOutlet NSMatrix *variant, *color;
	IBOutlet NSButton *rated, *manual, *useFormula;
}

- (id) init;
- (void) dealloc;
- (IBAction) seek: (id) sender;
- (IBAction) unseek: (id) sender;
- (IBAction) unseekAll: (id) sender;
- (void) show: (id) sender;

@end
