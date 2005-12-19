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
	float board_size = MIN(bounds.size.width, bounds.size.height);
	NSRect board = {
		{ 0, bounds.size.height - board_size },
		{ board_size, board_size }
	};
	
	float field_size = board_size / 8;
	int i, j, n, c, p;
	NSRect imagerect;
	bool flip = ([gameWindowController sideShownOnBottom] == BLACK);
	
	imagerect.size = [pieces[1] size];
	imagerect.origin = NSZeroPoint;
	[[NSColor whiteColor] set];
	[NSBezierPath fillRect: board];	
	[[NSColor brownColor] set];
	cur_field.size.width = field_size;
	cur_field.size.height = field_size;
	cur_field.origin.y = board.origin.y;
	n = 0;
	c = 1;
	for (i = 0; i < 8; i++) {
		cur_field.origin.x = board.origin.x;
		for (j = 0; j < 8; j++) {
			if (c == 1)
				[NSBezierPath fillRect: cur_field];
			if (flip)
				p = [showBoard flipPieceLine: j + 1 row: i + 1];
			else
				p = [showBoard pieceLine: j + 1 row: i + 1];
			if (p != 0) {
				[pieces[p] drawInRect:cur_field fromRect:imagerect operation:NSCompositeSourceOver fraction:1];
			}
			cur_field.origin.x += field_size;
			n++;
			c = 1 - c;
		}
		c = 1 - c;
		cur_field.origin.y += field_size;
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
	if ([gameWindowController sideShownOnBottom] == BLACK) {
		f.line = 9 - f.line;
		f.row = 9 - f.row;
	}
	return f;	
}

- (void) mouseDown: (NSEvent *) theEvent
{
	fromMouse = [self getField: theEvent];
}

- (void) mouseUp: (NSEvent *) theEvent
{
	toMouse = [self getField: theEvent];
	switch ([showBoard validateMoveFrom: fromMouse to: toMouse]) {
	  case INVALID:
		break;
	  case VALID:
		[gameWindowController userMoveFrom: fromMouse to: toMouse promotion: 0];
		break;
	  case REQUIRES_PROMOTION:
		[NSApp beginSheet: promotionDialog modalForWindow: [gameWindowController window] modalDelegate: self didEndSelector: NULL contextInfo: NULL];
		break;
	}
}

- (void) setShowBoard: (Board *) board
{
	[showBoard release];
	showBoard = [board retain];
	[self setNeedsDisplay: TRUE];
}

- (IBAction) selectedPromotionPiece: (id) sender
{
	[promotionDialog orderOut:sender];
	[NSApp endSheet:promotionDialog returnCode: 1];
	[gameWindowController userMoveFrom: fromMouse to: toMouse promotion: [sender tag]];
}

@end


