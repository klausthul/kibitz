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


#import <ctype.h>
#import "Game.h"
#import "MoveStore.h"

@implementation Game

- (Game *) init
{
	if ((self = [super init]) != nil) {
		moves = [[NSMutableArray arrayWithCapacity: 100] retain];
	}
	return self; 
}

- (void) setPlayerNamesWhite: (NSString *) white black: (NSString *) black
{
	[whiteName release];
	whiteName = [white retain];
	[blackName release];
	blackName = [black retain];
}

- (NSString *) whiteName
{
	return [[whiteName retain] autorelease];
}

- (NSString *) blackName
{
	return [[blackName retain] autorelease];
}

- (void) setTimeInitial: (int) initial increment: (int) increment
{
	initialTime = initial;
	incrementTime = increment;
}

- (int) initialTime
{
	return initialTime;
}

- (int) incrementTime
{
	return incrementTime;
}

- (ChessMove *) currentBoardPosition
{
	return lastMove;
}

- (void) newMove: (ChessMove *) move
{
	[lastMove release];
	lastMove = [move retain];
	MoveStore *ms;
	NSEnumerator *e = [moves objectEnumerator];
	int n = [move moveNumber];
	if (n == 0) {
		[self setStartPosition: move];
	} else {
		while ((ms = [e nextObject]) != nil)
			if ([ms moveNum] == n)
				break;
		[self willChangeValueForKey: @"moves"];
		if (ms == nil) {
			ms = [[[MoveStore alloc] initWithMoveNum: n] autorelease];
			[moves addObject: ms];
		}
		if ([move moveColor] == WHITE)
			[ms setWhiteMove: move];
		else
			[ms setBlackMove: move];
		[self didChangeValueForKey: @"moves"];
	}
}

- (void) dealloc
{
	[whiteName release];
	[blackName release];
	[lastMove release];
	[ratingWhite release];
	[ratingBlack release];
	[type release];
	[moves release];
	[super dealloc];
}

- (Game *) initWithStyle12: (NSArray *) data
{
	if ((self = [self init]) != nil) {
		[self updateWithStyle12: data];
	}
	return self;
}

- (Game *) initWithGameInfo: (NSArray *) data
{
	if ((self = [self init]) != nil) {
		[self updateWithGameInfo: data];
	}
	return self;
}

- (void) updateWithStyle12: (NSArray *) data
{
	[self setPlayerNamesWhite: [data objectAtIndex: 17] black: [data objectAtIndex: 18]];
	[self setTimeInitial: [[data objectAtIndex: 20] intValue] increment: [[data objectAtIndex: 21] intValue]];
	gameNumber = [[data objectAtIndex: 16] intValue];
	gameRelationship = [[data objectAtIndex: 19] intValue];
}

- (void) updateWithGameInfo: (NSArray *) data
{
	NSString *s;
	gameNumber = [[data objectAtIndex: 0] intValue];
	if ((s = [ChessServerConnection findTag: @"t=" in: data]) != nil) {
		[type release];
		type = [s retain];
	}
	if ((s = [ChessServerConnection findTag: @"r=" in: data]) != nil)
		rated = ([s intValue] == 1);
	if ((s = [ChessServerConnection findTag: @"pt=" in: data]) != nil)
		partnerGame = [s intValue];
	if ((s = [ChessServerConnection findTag: @"rt=" in: data]) != nil) {
		NSArray *ra = [s componentsSeparatedByString: @","];
		if ([ra count] >= 2) {
			[ratingWhite release];
			ratingWhite = [[ra objectAtIndex: 0] retain];
			[ratingBlack release];		
			ratingBlack = [[ra objectAtIndex: 1] retain];
		}
	}
}

- (Game *) initWithEmptyGame
{
	if ((self = [self init]) != nil) {
		[self setPlayerNamesWhite: @"White" black: @"Black"];
		[self newMove: [ChessMove initialPosition]];
		initialTime = -1;
	}
	return self;
}

- (NSString *) gameInfoString
{
	if (result)
		return [NSString stringWithFormat: @"was Game #%d: %@ - %@, (%d+%d), Result: %@", gameNumber, whiteName, blackName, initialTime, incrementTime, result];
	else
		return [NSString stringWithFormat: @"Game #%d: %@ - %@ (%d+%d)", gameNumber, whiteName, blackName, initialTime, incrementTime];
}

- (void) setResult: (NSString *) resultV reason: (NSString *) reasonV
{
	[result release];
	result = [resultV retain];
	[reason release];
	reason = [reasonV retain];
	[lastMove stopClock];
}

- (NSString *) result
{
	return result;
}

- (NSString *) reason
{
	return reason;
}

- (void) setSideShownOnBottom: (enum Color) color
{
	sideShownOnBottom = color;
}

- (void) flipSideShownOnBottom
{
	sideShownOnBottom = (sideShownOnBottom == BLACK) ? WHITE : BLACK;
}

- (enum Color) sideShownOnBottom
{
	return sideShownOnBottom;
}

- (enum GameRelationship) gameRelationship
{
	return gameRelationship;
}

- (void) setDefaultBoardOrientation
{
	switch (gameRelationship) {
	  case PLAYING_OPONENT_MOVE:
		[self setSideShownOnBottom: BLACK - [self sideToMove]];
		break;
	  case PLAYING_MYMOVE:
		[self setSideShownOnBottom: [self sideToMove]];
		break;
	  default:
		[self setSideShownOnBottom: WHITE];
		break;
	}
}

- (enum Color) sideToMove
{
	return [lastMove sideToMove];
}

- (NSString *) ratingWhite
{
	return ratingWhite;
}

- (NSString *) ratingBlack
{
	return ratingBlack;
}

- (NSString *) type
{
	return type;
}

- (bool) rated
{
	return rated;
}

- (NSString *) whiteNameRating
{
	if (whiteName && ratingWhite)
		return [NSString stringWithFormat: @"%@\n%@", whiteName, ratingWhite];
	else
		return whiteName;
}

- (NSString *) blackNameRating
{
	if (blackName && ratingBlack)
		return [NSString stringWithFormat: @"%@\n%@", blackName, ratingBlack];
	else
		return blackName;
}

- (void) setStartPosition: (ChessMove *) move
{
	[startPosition release];
	startPosition = [move retain];
}

- (ChessMove *) startPosition
{
	return startPosition;
}

- (ChessMove *) storedMoveNumber: (unsigned int) num
{
	if (num >= [moves count])
		return nil;
	else {
		MoveStore *ms = [moves objectAtIndex: num];
		ChessMove *m = [ms blackMove];
		if (m != nil)
			return m;
		else
			return [ms whiteMove];
	}
}

- (int) numMoves
{
	return [moves count];
}

- (void) passedPiecesWhite: (NSString *) white black: (NSString *) black
{
	[lastMove passedPiecesWhite: white black: black];
}

@end
