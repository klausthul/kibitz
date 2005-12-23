// icsinterface
// $Id$

#import "ChessView.h"
#import "ChessMove.h"

@implementation ChessView

- (id) initWithFrame: (NSRect) frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		[self registerForDraggedTypes: [NSArray arrayWithObject: NSStringPboardType]];
	}
	return self;
}

- (void) drawRect: (NSRect) rect
{
	NSRect bounds = [self bounds];
	NSRect cur_field;
	float board_size = MIN(bounds.size.width, bounds.size.height);
	NSRect board = {
		{ 0, bounds.size.height - board_size },
		{ board_size, board_size }
	};
	
	fieldSize = board_size / 8;
	int i, j, n, c, p;
	NSRect imagerect;
	bool flip = ([gameWindowController sideShownOnBottom] == BLACK);
	
	imagerect.size = [pieces[1] size];
	imagerect.origin = NSZeroPoint;
	[[NSColor whiteColor] set];
	[NSBezierPath fillRect: board];	
	[[NSColor brownColor] set];
	cur_field.size.width = fieldSize;
	cur_field.size.height = fieldSize;
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
			cur_field.origin.x += fieldSize;
			n++;
			c = 1 - c;
		}
		c = 1 - c;
		cur_field.origin.y += fieldSize;
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

- (struct ChessField) getFieldFromLocation: (NSPoint) location
{
	struct ChessField f;
	NSPoint p = [self convertPoint: location fromView: nil];
	NSRect bounds = [self bounds];
	f.line = ceilf(p.x / bounds.size.width * 8);
	f.row = ceilf(p.y / bounds.size.height * 8);
	if ([gameWindowController sideShownOnBottom] == BLACK) {
		f.line = 9 - f.line;
		f.row = 9 - f.row;
	}
	return f;	
}

- (struct ChessField) getField: (NSEvent *) theEvent
{
	return [self getFieldFromLocation: [theEvent locationInWindow]];
}

- (unsigned int) draggingSourceOperationMaskForLocal: (BOOL) isLocal
{
	if (isLocal == NO)
		return NSDragOperationNone;
	else
		return NSDragOperationMove;
}

- (void) mouseDown: (NSEvent *) event
{
	fromMouse = [self getField: event];
	NSPasteboard *pb = [NSPasteboard pasteboardWithName: NSDragPboard];
	NSPoint p = [self convertPoint: [event locationInWindow] fromView: nil];
	NSImage *img = [[pieces[[showBoard pieceOnField: fromMouse]] copy] autorelease];
	[img setScalesWhenResized: YES];
	[img setSize: NSMakeSize(fieldSize, fieldSize)];
	p.y -= fieldSize / 2;
	p.x -= fieldSize / 2;
	[pb declareTypes: [NSArray arrayWithObject: NSStringPboardType] owner: self];
	[pb setString: @"move" forType: NSStringPboardType];
	[self dragImage: img at: p offset: NSMakeSize(0, 0) event: event pasteboard: pb source: self slideBack: YES];
}

- (unsigned int) draggingEntered: (id <NSDraggingInfo>) sender
{
	return NSDragOperationMove;
}

- (BOOL) prepareForDragOperation: (id <NSDraggingInfo>) sender
{
	return YES;
}

- (BOOL) performDragOperation: (id <NSDraggingInfo>) sender
{
	NSPasteboard *pb = [sender draggingPasteboard];
	toMouse = [self getFieldFromLocation: [sender draggingLocation]];
	switch ([showBoard validateMoveFrom: fromMouse to: toMouse]) {
	  default:
		return NO;
	  case VALID:
		[gameWindowController userMoveFrom: fromMouse to: toMouse promotion: 0];
		return YES;
	  case REQUIRES_PROMOTION:
		[NSApp beginSheet: promotionDialog modalForWindow: [gameWindowController window] modalDelegate: self didEndSelector: NULL contextInfo: NULL];
		return YES;
	}
}

- (void) setShowBoard: (ChessMove *) board
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


