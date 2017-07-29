/*
	$Id$

	Copyright 2006 Klaus Thul (klaus.thul@mac.com)
	This file is part of Kibitz.

	Kibitz is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by 
	the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

	Kibitz is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of 
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License along with Kibitz; if not, write to the 
	Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/

#import "ChessView.h"
#import "ChessMove.h"

@implementation ChessView

- (instancetype) initWithFrame: (NSRect) frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		[self registerForDraggedTypes: @[NSStringPboardType]];
	}
	extendedView = NO;
	return self;
}

- (void) drawRect: (NSRect) rect
{
	NSRect bounds = self.bounds;
	NSRect cur_field;
	float board_size = fminf(bounds.size.width, bounds.size.height);
	NSRect board;
	fieldSize = board_size / ((extendedView) ? 9 : 8);	
	 if (!extendedView)
		board = (NSRect) {
			{ 0, bounds.size.height - board_size },
			{ board_size, board_size }
		};
	else
		board = (NSRect) {
			{ 0, bounds.size.height - board_size + fieldSize},
			{ fieldSize * 8, fieldSize * 8 }
		};
	
	int i, j, n, c, p;
	NSRect imagerect;
	bool flip = ([gameWindowController sideShownOnBottom] == BLACK);
	
	imagerect.size = pieces[1].size;
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
	if (extendedView) {
		cur_field.origin.x = 0;
		cur_field.origin.y = 0;
		for (i = 0; i < 8; i++) {
			p = i + ((flip) ? 8 : 0);
			int np = [showBoard passedPieces: p];
			if (pieces[p] != nil && (np > 0)) {
				[pieces[p] drawInRect:cur_field fromRect:imagerect operation:NSCompositeSourceOver fraction:1];
				if (np > 1)
					[[NSString stringWithFormat: @"%d", np] drawAtPoint: cur_field.origin withAttributes: nil];
			}
			cur_field.origin.x += fieldSize;
		}
		cur_field.origin.y = fieldSize;
		cur_field.origin.x = 8 * fieldSize;
		for (i = 0; i < 8; i++) {
			p = i + ((flip) ? 0 : 8);
			int np = [showBoard passedPieces: p];
			if (pieces[p] != nil && (np > 0)) {
				[pieces[p] drawInRect:cur_field fromRect:imagerect operation:NSCompositeSourceOver fraction:1];
				if (np > 1)
					[[NSString stringWithFormat: @"%d", np] drawAtPoint: cur_field.origin withAttributes: nil];
			}
			cur_field.origin.y += fieldSize;
		}
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
	bool flip = ([gameWindowController sideShownOnBottom] == BLACK);
	struct ChessField f;
	NSPoint p = [self convertPoint: location fromView: nil];
	NSRect bounds = self.bounds;
	if (extendedView) {
		f.line = ceilf(p.x / bounds.size.width * 9);
		f.row = ceilf(p.y / bounds.size.height * 9) - 1;
		if (f.line == 9) {
			f.row = f.row + ((flip) ? -1 : 7);
			f.line = -1;
			return f;
		}
		if (f.row == 0) {
			f.row = f.line + ((flip) ? 7 : -1);
			f.line = -1;
			return f;
		}
	} else {
		f.line = ceilf(p.x / bounds.size.width * 8);
		f.row = ceilf(p.y / bounds.size.height * 8);
	}
	if (flip) {
		f.line = 9 - f.line;
		f.row = 9 - f.row;
	}
	return f;	
}

- (struct ChessField) getField: (NSEvent *) theEvent
{
	return [self getFieldFromLocation: theEvent.locationInWindow];
}

- (enum NSDragOperation) draggingSourceOperationMaskForLocal: (BOOL) isLocal
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
	NSPoint p = [self convertPoint: event.locationInWindow fromView: nil];
	NSImage *img = [[pieces[[showBoard pieceOnField: fromMouse]] copy] autorelease];
	if (img != nil) {
		img.size = NSMakeSize(fieldSize, fieldSize);
		p.y -= fieldSize / 2;
		p.x -= fieldSize / 2;
		[pb declareTypes: @[NSStringPboardType] owner: self];
		[pb setString: @"move" forType: NSStringPboardType];
		[self dragImage: img at: p offset: NSMakeSize(0, 0) event: event pasteboard: pb source: self slideBack: YES];
	}
}

- (enum NSDragOperation) draggingEntered: (id <NSDraggingInfo>) sender
{
	return NSDragOperationMove;
}

- (BOOL) prepareForDragOperation: (id <NSDraggingInfo>) sender
{
	return YES;
}

- (BOOL) performDragOperation: (id <NSDraggingInfo>) sender
{
	toMouse = [self getFieldFromLocation: [sender draggingLocation]];
	switch ([showBoard validateMoveFrom: fromMouse to: toMouse]) {
	  default:
		return NO;
	  case VALID:
		[gameWindowController userMoveFrom: fromMouse to: toMouse promotion: 0];
		return YES;
	  case REQUIRES_PROMOTION:
		[NSApp beginSheet: promotionDialog modalForWindow:self.window modalDelegate: self didEndSelector: NULL contextInfo: NULL];
		return YES;
	}
}

- (void) setShowBoard: (ChessMove *) board
{
	[showBoard release];
	showBoard = [board retain];
	extendedView = [showBoard hasPassedPieces];
	[self setNeedsDisplay: TRUE];
}

- (IBAction) selectedPromotionPiece: (id) sender
{
	[promotionDialog orderOut:sender];
	[NSApp endSheet:promotionDialog returnCode: 1];
	[gameWindowController userMoveFrom: fromMouse to: toMouse promotion: [sender tag]];
}

@end


