// icsinterface
// $Id$

#import "ChessView.h"

@implementation ChessView

- (id)initWithFrame:(NSRect)frameRect
{
	return (self = [super initWithFrame:frameRect]);
}

- (void)drawRect:(NSRect)rect
{
	NSRect bounds = [self bounds];
	NSRect cur_field;
	float size_x = bounds.size.width / 8.0;
	float size_y = bounds.size.height / 8.0;
	int i, j, n, c, p;
	NSRect imagerect;
	
	imagerect.size = [pieces[1] size];
	imagerect.origin = NSZeroPoint;
	[[NSColor whiteColor] set];
	[NSBezierPath fillRect: bounds];	
	[[NSColor brownColor] set];
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
			if ((p = [showBoard pieceLine:j+1 row:i+1]) != 0) {
				[pieces[p] drawInRect:cur_field fromRect:imagerect operation:NSCompositeSourceOver fraction:1];
			}
			cur_field.origin.x += size_x;
			n++;
			c = 1 - c;
		}
		c = 1 - c;
		cur_field.origin.y += size_y;
	}
}

- (void) awakeFromNib 
{
	NSBundle *b = [NSBundle mainBundle];
	NSString *names[] = { nil, @"wp", @"wn", @"wb", @"wr", @"wq", @"wk", nil, nil, @"bp", @"bn", @"bb", @"br", @"bq", @"bk", nil, nil };
	int i;
	
	for (i = 0; i < 16; i++) {
		if (names[i] == nil)
			pieces[i] = nil;
		else
			pieces[i] = [[NSImage alloc] initByReferencingFile:[b pathForImageResource:names[i]]];
	}
}

- (struct ChessField) getField: (NSEvent *) theEvent
{
	struct ChessField f;
	NSPoint p = [self convertPoint:[theEvent locationInWindow] fromView: nil];
	NSRect bounds = [self bounds];
	f.line = ceilf(p.x / bounds.size.width * 8);
	f.row = ceilf(p.y / bounds.size.height * 8);
	printf("%f %f\n", p.x, p.y);
	return f;	
}

- (void) mouseDown: (NSEvent *) theEvent
{
	fromMouse = [self getField: theEvent];
	printf("%d %d\n", fromMouse.line, fromMouse.row);
}

- (void) mouseUp: (NSEvent *) theEvent
{
	toMouse = [self getField: theEvent];
//	[appController userMoveFrom: fromMouse to: toMouse];
}

- (void) setShowBoard: (Board *) board
{
	[showBoard release];
	showBoard = [board retain];
	[self setNeedsDisplay: TRUE];
}

@end


