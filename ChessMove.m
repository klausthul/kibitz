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

#import "ChessMove.h"

@implementation ChessMove

+ (ChessMove *) moveFromStyle12: (NSArray *) data
{
	int i, j, k;
	NSString *pieces = @"-PNBRQK  pnbrqk";
	ChessMove *cm;
	if ((cm = [[ChessMove alloc] init]) != nil) {
		cm->movePrint = [data[29] retain];
		cm->timeUsed = [data[28] retain];
		cm->gameRelationship = [data[19] intValue];
		for (i = 0; i < 8; i++) {
			NSString *s = data[i + 1];
			for (j = 0; j < 8; j++) {
				unichar c = [s characterAtIndex: j];
				for (k = 0; k < 15; k++)
					if (c == [pieces characterAtIndex: k]) {
						cm->fields[(7-i)*8 + j] = k;
						break;
					}
			}
		}
		if ([data[9] characterAtIndex:0] == 'B')
			cm->sideToMove = BLACK;
		else
			cm->sideToMove = WHITE;
		cm->runningClock = (cm->sideToMove == WHITE) ? WHITE_CLOCK_RUNS : BLACK_CLOCK_RUNS;
		cm->enPassantLine = [data[10] intValue];
		cm->castleRights = [data[11] intValue] * WHITE_SHORT;
		cm->castleRights += [data[12] intValue] * WHITE_LONG;
		cm->castleRights += [data[13] intValue] * BLACK_SHORT;
		cm->castleRights += [data[14] intValue] * BLACK_LONG;
		cm->moveCounter50Rule = [data[15] intValue];
		cm->whiteMaterial = [data[22] intValue];
		cm->blackMaterial = [data[23] intValue];
		cm->whiteRemainingTime = [data[24] intValue];
		cm->blackRemainingTime = [data[25] intValue];
		cm->nextMoveNumber = [data[26] intValue];
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
	if (field.line == -1)
		return (passedPieces[field.row] >= 1) ? field.row : 0;
	else
		return fields[field.row * 8 + field.line - 9];
}

- (enum ValidationResult) validateMoveFrom: (struct ChessField) from to: (struct ChessField) to
{
	if (from.line == -1) {
		if ((from.row < 0) || (from.row > 15)
		 || (passedPieces[from.row] <= 0)
		 || (to.row < 1) || (to.row > 8) || (to.line < 1) || (to.line > 8))
			return INVALID;
		else
			return VALID;
	} else {
		if (((to.row == 1) || (to.row == 8)) && GETPIECE([self pieceOnField:from]) == PAWN)
			return REQUIRES_PROMOTION;
		return VALID;
	}
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

- (int) passedPieces: (int) piece
{
	return passedPieces[piece];
}

- (void) passedPiecesWhite: (NSString *) white black: (NSString *) black
{
	int i, j, l;
	char *pieceNames = "\0PNBRQK\0";
	white = white.uppercaseString;
	black = black.uppercaseString;
	l = white.length;
	hasPassedPieces = 0;
	for (i = 0; i < 8; i++) {
		passedPieces[i] = 0;
		char c = pieceNames[i];
		if (c != 0)
			for (j = 0; j < l; j++)
				if (c == [white characterAtIndex: j]) {
					passedPieces[i]++;
					hasPassedPieces = YES;
				}
	}
	l = black.length;
	for (i = 8; i < 16; i++) {
		passedPieces[i] = 0;
		char c = pieceNames[i - 8];
		if (c != 0)
			for (j = 0; j < l; j++)
				if (c == [black characterAtIndex: j]) {
					passedPieces[i]++;
					hasPassedPieces = YES;
				}
	}
}

- (bool) hasPassedPieces {
	return hasPassedPieces;
}

@end
