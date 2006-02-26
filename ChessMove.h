/*
	$Id$

	Copyright 2006 Klaus Thul (klaus.thul@mac.com)
	This file is part of kibitz.

	kibitz is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by 
	the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

	kibitz is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of 
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License along with kibitz; if not, write to the 
	Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/

#import "global.h"

@interface ChessMove : NSObject {
	unsigned char fields[64];
	enum CastleRights castleRights;
	enum Color sideToMove;
	int enPassantLine, moveCounter50Rule, whiteMaterial, blackMaterial, nextMoveNumber, 
	 whiteRemainingTime, blackRemainingTime; 
	time_t lastTimeUpdate;
	enum RunningClock runningClock;
	NSString *movePrint;
	NSString *timeUsed;
	enum GameRelationship gameRelationship;
	int passedPieces[16];
	bool hasPassedPieces;
}

+ (ChessMove *) moveFromStyle12: (NSArray *) data;
+ (ChessMove *) initialPosition;
- (void) dealloc;
- (enum GameRelationship) gameRelationship;
- (enum Color) sideToMove;
- (int) pieceLine: (int) l row: (int) r;
- (int) flipPieceLine: (int) l row: (int) r;
- (int) pieceOnField: (struct ChessField) field;
- (enum ValidationResult) validateMoveFrom: (struct ChessField) from to: (struct ChessField) to;
- (int) whiteCurrentTime;
- (int) blackCurrentTime;
- (void) stopClock;
- (enum Color) sideToMove;
- (int) moveNumber;
- (enum Color) moveColor;
- (NSString *) movePrint;
- (int) passedPieces: (int) piece;
- (bool) hasPassedPieces;
- (void) passedPiecesWhite: (NSString *) white black: (NSString *) black;

@end
