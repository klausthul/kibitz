// icsinterface
// $Id$

#import "Board.h"

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

- (void) setBoardFromString: (char *) s flip: (int) flip
{
	int i, j;
//	unsigned char *p = (flip == 0) ? fields : fields + 63;
//	unsigned char *p = (flip == 0) ? fields : fields + 63;
//	int step = (flip == 0) ? 1 : -1;
	
	for (i = 0; i < 8; i++) {
		for (j = 0; j < 8; j++) {
			fields[(7-i)*8 + j] = pieceFromChar(*s);
			if (*(++s) == 0)
				return;
		}
		if (*(++s) == 0)
			return;
	}
}

- (unsigned char) pieceOnField: (ChessField) field
{
	return fields[field.row * 8 + field.line - 9];
}

@end
