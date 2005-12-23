// icsinterface
// $Id$

#import "ChessMove.h"

@implementation ChessMove

+ (ChessMove *) moveFromStyle12: (NSArray *) data
{
	int i, j, k;
	NSString *pieces = @"-PNBRQK  pnbrqk";
	ChessMove *cm;
	if ((cm = [[ChessMove alloc] init]) != nil) {
		cm->movePrint = [[data objectAtIndex: 29] retain];
		cm->timeUsed = [[data objectAtIndex: 28] retain];
		cm->gameRelationship = [[data objectAtIndex: 19] intValue];
		for (i = 0; i < 8; i++) {
			NSString *s = [data objectAtIndex: i + 1];
			for (j = 0; j < 8; j++) {
				unichar c = [s characterAtIndex: j];
				for (k = 0; k < 15; k++)
					if (c == [pieces characterAtIndex: k]) {
						cm->fields[(7-i)*8 + j] = k;
						break;
					}
			}
		}
		if ([[data objectAtIndex: 9] characterAtIndex:0] == 'B')
			cm->sideToMove = BLACK;
		else
			cm->sideToMove = WHITE;
		cm->runningClock = (cm->sideToMove == WHITE) ? WHITE_CLOCK_RUNS : BLACK_CLOCK_RUNS;
		cm->enPassantLine = [[data objectAtIndex: 10] intValue];
		cm->castleRights = [[data objectAtIndex: 11] intValue] * WHITE_SHORT;
		cm->castleRights += [[data objectAtIndex: 12] intValue] * WHITE_LONG;
		cm->castleRights += [[data objectAtIndex: 13] intValue] * BLACK_SHORT;
		cm->castleRights += [[data objectAtIndex: 14] intValue] * BLACK_LONG;
		cm->moveCounter50Rule = [[data objectAtIndex: 15] intValue];
		cm->whiteMaterial = [[data objectAtIndex: 22] intValue];
		cm->blackMaterial = [[data objectAtIndex: 23] intValue];
		cm->whiteRemainingTime = [[data objectAtIndex: 24] intValue];
		cm->blackRemainingTime = [[data objectAtIndex: 25] intValue];
		cm->nextMoveNumber = [[data objectAtIndex: 26] intValue];
		cm->lastTimeUpdate = time(NULL);	
	}
	return [cm autorelease];
}

+ (ChessMove *) initialPosition
{
	ChessMove *cm = [[ChessMove alloc] init];
	if (cm != nil) {
		int i, j, k, l;
		const char firstrow[] = { ROOK, KNIGHT, BISHOP, QUEEN, KING, BISHOP, KNIGHT, ROOK };
		for (i = 0, j = 56, k = 8, l = 48; i < 8; i++, j++, k++, l++) {
			cm->fields[i] = firstrow[i] | WHITE;
			cm->fields[j] = firstrow[i] | BLACK;
			cm->fields[k] = PAWN | WHITE;
			cm->fields[l] = PAWN | BLACK;
		}
		cm->enPassantLine = -1;
		cm->sideToMove = WHITE;
		cm->nextMoveNumber = 1;
		cm->castleRights = WHITE_LONG | WHITE_SHORT | BLACK_LONG | BLACK_SHORT;
	}
	cm->whiteRemainingTime = cm->blackRemainingTime = -1;
	return [cm autorelease];
}

- (void) dealloc
{
	[movePrint release];
	[timeUsed release];
	[super dealloc];
}

- (enum GameRelationship) gameRelationship
{
	return gameRelationship;
}

- (enum Color) sideToMove
{
	return sideToMove;
}

- (int) pieceLine: (int) l row: (int) r
{
	return fields[l + 8*r - 9];
}

- (int) flipPieceLine: (int) l row: (int) r
{
	return fields[63 - l - 8*r + 9];
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

- (int) moveNumber
{
	return (sideToMove == BLACK) ? nextMoveNumber : nextMoveNumber - 1; 
}

- (enum Color) moveColor
{
	return (sideToMove == BLACK) ? WHITE : BLACK; 
}

- (NSString *) movePrint
{
	return (movePrint != nil) ? movePrint : @"";
}

@end
