// icsinterface
// $Id$

#import "Board.h"

@implementation Board

+ (Board *) boardFromStyle12: (NSArray *) data
{
	int i, j, k;
	NSString *pieces = @"-PNBRQK  pnbrqk";
	Board *b = [[Board alloc] init];
	
	for (i = 0; i < 8; i++) {
		NSString *s = [data objectAtIndex: i + 1];
		for (j = 0; j < 8; j++) {
			unichar c = [s characterAtIndex: j];
			for (k = 0; k < 15; k++)
				if (c == [pieces characterAtIndex: k]) {
					b->fields[(7-i)*8 + j] = k;
					break;
				}
		}
	}
	if ([[data objectAtIndex: 9] characterAtIndex:0] == 'B')
		b->sideToMove = BLACK;
	else
		b->sideToMove = WHITE;
	b->runningClock = (b->sideToMove == WHITE) ? WHITE_CLOCK_RUNS : BLACK_CLOCK_RUNS;
	b->enPassantLine = [[data objectAtIndex: 10] intValue];
	b->castleRights = [[data objectAtIndex: 11] intValue] * WHITE_SHORT;
	b->castleRights += [[data objectAtIndex: 12] intValue] * WHITE_LONG;
	b->castleRights += [[data objectAtIndex: 13] intValue] * BLACK_SHORT;
	b->castleRights += [[data objectAtIndex: 14] intValue] * BLACK_LONG;
	b->moveCounter50Rule = [[data objectAtIndex: 15] intValue];
	b->whiteMaterial = [[data objectAtIndex: 22] intValue];
	b->blackMaterial = [[data objectAtIndex: 23] intValue];
	b->whiteRemainingTime = [[data objectAtIndex: 24] intValue];
	b->blackRemainingTime = [[data objectAtIndex: 25] intValue];
	b->nextMoveNumber = [[data objectAtIndex: 26] intValue];
	b->lastTimeUpdate = time(NULL);	
	return [b autorelease];
}
 
+ (Board *) startPosition;
{
	Board *b = [[Board alloc] init];
	if (b != nil) {
		int i, j, k, l;
		const char firstrow[] = { ROOK, KNIGHT, BISHOP, QUEEN, KING, BISHOP, KNIGHT, ROOK };
	
		for (i = 0, j = 56, k = 8, l = 48; i < 8; i++, j++, k++, l++) {
			b->fields[i] = firstrow[i] | WHITE;
			b->fields[j] = firstrow[i] | BLACK;
			b->fields[k] = PAWN | WHITE;
			b->fields[l] = PAWN | BLACK;
		}
		b->enPassantLine = -1;
		b->sideToMove = WHITE;
		b->castleRights = WHITE_LONG | WHITE_SHORT | BLACK_LONG | BLACK_SHORT;
	}
	b->whiteRemainingTime = b->blackRemainingTime = -1;
	return [b autorelease];
}

- (int) pieceLine: (int) l row: (int) r
{
	return fields[l + 8*r - 9];
}

- (int) pieceOnField: (struct ChessField) field
{
	return fields[field.row * 8 + field.line - 9];
}

- (enum ValidationResult) validateMoveFrom: (struct ChessField) from to: (struct ChessField) to
{
	if (((to.row == 1) || (to.row == 8)) && GETPIECE([self pieceOnField:from]) == PAWN)
		return REQUIRES_PROMOTION;
	return VALID;
}

- (int) whiteCurrentTime
{
	if (runningClock == WHITE_CLOCK_RUNS)
		return MAX(0, whiteRemainingTime - difftime(time(NULL), lastTimeUpdate));
	else
		return whiteRemainingTime;
}

- (int) blackCurrentTime
{
	if (runningClock == BLACK_CLOCK_RUNS)
		return MAX(0, blackRemainingTime - difftime(time(NULL), lastTimeUpdate));
	else
		return blackRemainingTime;
}

- (void) stopClock
{
	runningClock = NO_CLOCK_RUNS;
}

@end
