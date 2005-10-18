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
	int i, j, n, c, p;
	NSRect imagerect;
	
	imagerect.size = [pieces[1] size];
	imagerect.origin = NSZeroPoint;
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
			if ((p = [game pieceLine:j+1 row:i+1]) != 0) {
//				if (GETCOLOR(p))
//					[[NSColor redColor] set];
//				else
//					[[NSColor greenColor] set];
//				[NSBezierPath fillRect: cur_field];
				[pieces[p] drawInRect:cur_field fromRect:imagerect operation:NSCompositeSourceOver fraction:0.5];
//				[[NSColor blackColor] set];
			}
			cur_field.origin.x += size_x;
			n++;
			c = 1 - c;
		}
		c = 1 - c;
		cur_field.origin.y += size_y;
	}
}

- (ChessView *) awakeFromNib 
{
	pieces[1] = [[[NSImage alloc] initByReferencingFile:@"/users/kthul/pieces/wp.BMP"] retain];
	pieces[2] = [[NSImage alloc] initByReferencingFile:@"/users/kthul/pieces/wn.BMP"];
	pieces[3] = [[NSImage alloc] initByReferencingFile:@"/users/kthul/pieces/wb.BMP"];
	pieces[4] = [[NSImage alloc] initByReferencingFile:@"/users/kthul/pieces/wr.BMP"];
	pieces[5] = [[NSImage alloc] initByReferencingFile:@"/users/kthul/pieces/wq.BMP"];
	pieces[6] = [[NSImage alloc] initByReferencingFile:@"/users/kthul/pieces/wk.BMP"];
	pieces[9] = [[NSImage alloc] initByReferencingFile:@"/users/kthul/pieces/bp.BMP"];
	pieces[10] = [[NSImage alloc] initByReferencingFile:@"/users/kthul/pieces/bn.BMP"];
	pieces[11] = [[NSImage alloc] initByReferencingFile:@"/users/kthul/pieces/bb.BMP"];
	pieces[12] = [[NSImage alloc] initByReferencingFile:@"/users/kthul/pieces/br.BMP"];
	pieces[13] = [[NSImage alloc] initByReferencingFile:@"/users/kthul/pieces/bq.BMP"];
	pieces[14] = [[NSImage alloc] initByReferencingFile:@"/users/kthul/pieces/bk.BMP"];
	return self;
}
@end
