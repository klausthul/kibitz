// icsinterface
// $Id$

#import "global.h"


@interface PlayView : NSView {

}

- (void) resizeWithOldSuperviewSize: (NSSize) oldBoundsSize;
- (float) maxWidthForHeight;
- (float) maxHeightForWidth;

@end
