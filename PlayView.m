// icsinterface
// $Id$

#import "PlayView.h"

@implementation PlayView

- (void) resizeWithOldSuperviewSize: (NSSize) oldBoundsSize
{
	NSRect f2 = [[self superview] frame], f;
	f.size.height = MIN(f2.size.height, f2.size.width - 97);
	f.size.width = f.size.height + 97;
	f.origin.x = 0;
	f.origin.y = f2.size.height - f.size.height;		
	[self setFrame: f];
}

- (float) maxWidthForHeight
{
	return [self frame].size.height + 97;
}

- (float) maxHeightForWidth
{
	return [self frame].size.width - 97;
}

@end
