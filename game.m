//
//  game.m
//  icsinterface
//
//  Created by Thul Klaus on 10/15/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <ctype.h>
#import "game.h"

@implementation Board

- (void) startPosition
{
	int i, j, k, l;
	const char firstrow[] = { ROOK, KNIGHT, BISHOP, QUEEN, KING, BISHOP, KNIGHT, ROOK };
	
	for (i = 0, j = 56, k = 8, l = 48; i < 8; i++, j++, k++, l++) {
		fields[i] = firstrow[i] | WHITE;
		fields[j] = firstrow[i] | BLACK;
		fields[k] = PAWN | WHITE;
		fields[l] = PAWN | BLACK;
	}
	en_passant = 0;
	to_move = WHITE;
	castle_rights = WHITE_LONG | WHITE_SHORT | BLACK_LONG | BLACK_SHORT;
}

- (void) printBoard
{
	int i, j, i_max;
	const char *pieces = ".pnbrqk  PNBRQK";
	
	for (j = 56, i_max = 64; j >= 0; i_max = j, j -= 8) {
		for (i = j; i < i_max; i++)
			printf("%c", pieces[fields[i]]);
		printf("\n");
	}
	printf("Castle: %d, Enpassant: %d\n", castle_rights, en_passant);
	printf("\n%s to move.\n\n", (to_move == WHITE) ? "White" : "Black");
}

- (ChessMoveStore *) doMove: (ChessMove *) move
{
	int d;
	ChessMoveStore *store = [ChessMoveStore newChessMoveStore: move captured: fields[move->to] enPassant: en_passant castleRights: castle_rights];

	fields[move->to] = move->promotion ? move->promotion | GETCOLOR(move->from) : fields[move->from];
	fields[move->from] = 0;
	en_passant = 0;
	switch (move->from) {  // change right to castle if king or rook moved
	  case 0:
	    castle_rights &= WHITE_SHORT | BLACK_LONG | BLACK_SHORT;
		break;
	  case 4:
	    castle_rights &= BLACK_LONG | BLACK_SHORT;
		break;
	  case 7:
	    castle_rights &= WHITE_LONG | BLACK_LONG | BLACK_SHORT;
		break;
	  case 56:
	    castle_rights &= WHITE_LONG | WHITE_SHORT | BLACK_SHORT;
		break;
	  case 60:
	    castle_rights &= WHITE_LONG | WHITE_SHORT;
		break;
	  case 63:
	    castle_rights &= WHITE_LONG | WHITE_SHORT | BLACK_LONG;
		break;
	}
	d = move->to - move->from;
	switch (fields[move->to]) { // handle castling and en-passant
	  case PAWN | BLACK:
		if (move->to == store->en_passant)
		    fields[move->to + 8] = 0; // remove pawn in case of en-passant capture
	    if (d == -16)
		    en_passant = move->to + 8;
	    break;
	  case PAWN | WHITE:
		if (move->to == store->en_passant)
		    fields[move->to - 8] = 0; // remove pawn in case of en-passant capture
	    if (d == 16)
		    en_passant = move->to - 8;
	    break;
	  case KING | WHITE:
		if ((move->from == 4) && (move->to == 6)) { // move rook for castle
			fields[7] = 0;
			fields[5] = ROOK | WHITE;
		}
		if ((move->from == 4) && (move->to == 2)) { // move rook for castle
			fields[0] = 0;
			fields[3] = ROOK | WHITE;
		}
		break;
	  case KING | BLACK:
		if ((move->from == 60) && (move->to == 62)) { // move rook for castle
			fields[63] = 0;
			fields[61] = ROOK | BLACK;
		}
		if ((move->from == 60) && (move->to == 58)) { // move rook for castle
			fields[56] = 0;
			fields[59] = ROOK | BLACK;
		}
		break;
	}
	to_move = BLACK - to_move;
	return store;
}

- (void) undoMove: (ChessMoveStore *) move
{
	int d, color = GETCOLOR(fields[move->to]);

	fields[move->from] = move->promotion ? PAWN | color : fields[move->to];
	fields[move->to] = move->captured;
	en_passant = move->en_passant;
	castle_rights = move->castle_rights;
	d = move->to - move->from;
	switch (fields[move->from]) { // handle castling and en-passant
	  case PAWN | BLACK:
		if (move->to == en_passant)
		    fields[move->to + 8] = PAWN | WHITE; // put pawn back in case of en-passant capture
	    break;
	  case PAWN | WHITE:
		if (move->to == en_passant)
		    fields[move->to - 8] = PAWN | BLACK; // put pawn back in case of en-passant capture
	    break;
	  case KING | WHITE:
		if ((move->from == 4) && (move->to == 6)) { // move rook for castle
			fields[5] = 0;
			fields[7] = ROOK | WHITE;
		}
		if ((move->from == 4) && (move->to == 2)) { // move rook for castle
			fields[3] = 0;
			fields[0] = ROOK | WHITE;
		}
		break;
	  case KING | BLACK:
		if ((move->from == 60) && (move->to == 62)) { // move rook for castle
			fields[61] = 0;
			fields[63] = ROOK | BLACK;
		}
		if ((move->from == 60) && (move->to == 58)) { // move rook for castle
			fields[59] = 0;
			fields[56] = ROOK | BLACK;
		}
		break;
	}
	to_move = BLACK - to_move;
}

- (int) pieceLine: (int) l row: (int) r
{
	return fields[l + 8*r - 9];
}

@end

@implementation ChessMove

+ (ChessMove *) fromString: (const char *) s {
	int p, i;
	ChessMove *m = [[ChessMove alloc] init];
	
	m->from = tolower(s[0]) - 'a' + (tolower(s[1]) - '1') * 8;
	m->to = tolower(s[2]) - 'a' + (tolower(s[3]) - '1') * 8;
	m->promotion = 0;
	if (isalnum(p = s[4])) {
	    p = toupper(p);
		for (i = 2; i <= QUEEN; i++)
			if ("  KBRQ"[i] == p) {
				m->promotion = i;
				break;
			}
	}
	return [m autorelease];
}

- (NSString *) asCoordinates
{
	char buffer[256];
	sprintf(buffer, "%c%c-%c%c%c\n", from % 8 + 'a', from / 8 + '1', to % 8 + 'a', to / 8 + '1', "  KBRQ"[promotion]);
	return [NSString stringWithUTF8String: buffer];
}

- (void) printMove 
{
	printf("%c%c-%c%c%c\n", from % 8 + 'a', from / 8 + '1', to % 8 + 'a', to / 8 + '1', "  KBRQ"[promotion]);
}

@end

@implementation ChessMoveStore

+ (ChessMoveStore *) newChessMoveStore: (ChessMove *) move captured: (char) cp enPassant: (int) ep  castleRights: (int) cr
{
	ChessMoveStore *cms = [[ChessMoveStore alloc] init];

	cms->from = move->from;
	cms->to = move->to;
	cms->promotion = move->promotion;
	cms->captured = cp;
	cms->en_passant = ep;
	cms->castle_rights = cr;
	return [cms autorelease];
}

@end

@implementation Game

- (Game *) init
{
	if (self = [super init]) {
		board = [[Board alloc] init];
		[board startPosition];
		move_list = [[NSMutableArray alloc] initWithCapacity: 500];
		num_half_moves = 0;
		cur_move = 0;
	}
	return self;
}

- (void) dealloc
{
	[board release];
	[move_list release];
	[super dealloc];
}

- (void) doMove: (ChessMove *) move 
{
	ChessMoveStore *cms;

	[self goEnd];
	cms = [board doMove: move];
	cur_move++;
	[move_list insertObject: cms atIndex: num_half_moves++];
}

- (void) undoMove
{
	[self goEnd];
	if (num_half_moves > 0) {
		[self goBackward];
		--cur_move;
		[move_list removeObjectAtIndex: --num_half_moves];
	}
}

- (int) goForeward
{
	if (cur_move < num_half_moves) {
		[board doMove: [move_list objectAtIndex: cur_move++]];
		[chessView setNeedsDisplay:YES];
		if (cur_move == num_half_moves - 1) {
//			[tableView deselectAll: self];
			return 0;
		} else
			return 1;
	} else {
		return -1;
	}
}

- (void) goBackward
{
	if (cur_move > 0)
		[board undoMove: [move_list objectAtIndex: --cur_move]];
	[chessView setNeedsDisplay:YES];
}

- (void) goEnd
{
	while ([self goForeward] == 1)
		;
}

- (void) goStart
{
	while (cur_move > 0)
		[self goBackward];
	[tableView selectRow: cur_move / 2 byExtendingSelection: FALSE];
}

- (void) goMove: (int) n
{
	if (n >= num_half_moves)
		n = num_half_moves - 1; 
	if (n < 0)
		n = 0;
	while (cur_move < n)
		[self goForeward];
	while (cur_move > n)
		[self goBackward];
}

- (IBAction) goForeward: (id) sender
{
	[self goForeward];
	[tableView selectRow: cur_move / 2 byExtendingSelection: FALSE];
}

- (IBAction) goBackward: (id) sender
{
	[self goBackward];
	[tableView selectRow: cur_move / 2 byExtendingSelection: FALSE];
}

- (IBAction) goStart: (id) sender
{
	[self goStart];
	[tableView selectRow: cur_move / 2 byExtendingSelection: FALSE];
}

- (IBAction) goEnd: (id) sender
{
	[self goEnd];
	[tableView selectRow: cur_move / 2 byExtendingSelection: FALSE];
}

- (void) printBoard
{
	[board printBoard];
}

- (void) printMoveList
{
	int i;
	
	for (i = 0; i < num_half_moves; i++) {
		printf("%d%c. ", i/2 + 1, (i % 2 == 0) ? 'w' : 'b');
		[[move_list objectAtIndex: i] printMove];
	}
}

- (void) printGame
{
	[self printMoveList];
	[self printBoard];
	printf("At %d of %d.\n", cur_move, num_half_moves);
}

- (void) awakeFromNib
{
	FILE *f = fopen("/users/kthul/Desktop/test.game", "r");
	char s[256];
	
	while(fgets(s, 255, f) != NULL)
		[self doMove: [ChessMove fromString: s]];
	[tableView reloadData];
}

- (int) numberOfRowsInTableView: (NSTableView *) aTableView
{
	return (num_half_moves + 1)/2;
}

- (id) tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	NSString *x = [aTableColumn identifier];
	int i = -1;
	if ([x compare: @"2"] == 0)
		i = rowIndex * 2;
	else if ([x compare: @"3"] == 0)
		i = rowIndex * 2 + 1;
	if ((i >= 0) && (i < num_half_moves))
		return [[move_list objectAtIndex: i] asCoordinates];
	if ([x compare: @"1"] == 0)
		return [NSNumber numberWithInt: rowIndex + 1];
	return @"...";
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	[self goMove: [tableView selectedRow] * 2];
}

- (int) pieceLine: (int) l row: (int) r
{
	return [board pieceLine: l row: r];
}

@end
