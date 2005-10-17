#import "ChessView.h"

@implementation ChessView

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		// Add initialization code here
	}
	return self;
}

- (void)drawRect:(NSRect)rect
{
	NSRect bounds = [self bounds];
	NSRect cur_field;
	float size_x = bounds.size.width / 8.0;
	float size_y = bounds.size.height / 8.0;
	int i, j, n, c;

	[[NSColor whiteColor] set];
	[NSBezierPath fillRect: bounds];	
	[[NSColor blackColor] set];
	cur_field.size.width = size_x;
	cur_field.size.height = size_y;
	cur_field.origin.y = 0;
	n = 0;
	c = 1;
	for (i = 0; i < 8; i++) {
		cur_field.origin.x = 0;
		for (j = 0; j < 8; j++) {
			if (c == 1)
				[NSBezierPath fillRect: cur_field];
			cur_field.origin.x += size_x;
			n++;
			c = 1 - c;
		}
		c = 1 - c;
		cur_field.origin.y += size_y;
	}
}

@end
