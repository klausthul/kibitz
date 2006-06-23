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
#import "ChessView.h"
#import "ChessMove.h"

@interface Game : NSObject {
	NSString *whiteName, *blackName;
	enum GameRelationship gameRelationShip;
	int initialTime, incrementTime;
	ChessMove *lastMove, *startPosition;
	NSString *result, *reason, *type, *ratingWhite, *ratingBlack;
	int gameNumber;
	enum Color sideShownOnBottom;
	enum GameRelationship gameRelationship;
	bool rated;
	bool playSound;
	int partnerGame;
	NSMutableArray *moves;
	BOOL isEmpty;
}

- (void) setPlayerNamesWhite: (NSString *) white black: (NSString *) black;
- (NSString *) whiteName;
- (NSString *) blackName;
- (void) setTimeInitial: (int) initial increment: (int) increment;
- (int) initialTime;
- (int) incrementTime;
- (ChessMove *) currentBoardPosition;
- (void) newMove: (ChessMove *) move;
- (void) dealloc;
- (Game *) initWithStyle12: (NSArray *) data;
- (Game *) initWithGameInfo: (NSArray *) data;
- (void) updateWithStyle12: (NSArray *) data;
- (void) updateWithGameInfo: (NSArray *) data;
- (Game *) initWithEmptyGame;
- (NSString *) gameInfoString;
- (void) setResult: (NSString *) resultV reason: (NSString *) reasonV;
- (NSString *) result;
- (NSString *) reason;
- (void) setSideShownOnBottom: (enum Color) color;
- (void) flipSideShownOnBottom;
- (enum Color) sideShownOnBottom;
- (enum GameRelationship) gameRelationship;
- (void) setDefaultBoardOrientation;
- (enum Color) sideToMove;
- (NSString *) ratingWhite;
- (NSString *) ratingBlack;
- (NSString *) type;
- (bool) rated;
- (NSString *) whiteNameRating;
- (NSString *) blackNameRating;
- (void) setStartPosition: (ChessMove *) move;
- (ChessMove *) storedMoveNumber: (unsigned int) num;
- (int) numMoves;
- (void) passedPiecesWhite: (NSString *) white black: (NSString *) black;
- (BOOL) isEmpty;
- (BOOL) playSound;
- (void) setPlaySound: (bool) ps;

@end
