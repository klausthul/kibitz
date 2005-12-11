#import "global.h"
#import "Seek.h"

@interface SeekGraph : NSObject {
	NSMutableDictionary *seeks;
	IBOutlet NSTableView *seekTable;
}

- (void) newSeekFromServer: (int) num description: (const char *) seekInfo;
- (void) removeSeekFromServer: (int) num;
- (SeekGraph *) init;
- (int) numberOfRowsInTableView: (NSTableView *) aTableView;
- (id) tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;

@end

