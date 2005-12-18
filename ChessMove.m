// icsinterface
// $Id$

#import "ChessMove.h"
#import "Board.h"

@implementation ChessMove

+ (ChessMove *) moveFromStyle12: (NSArray *) data
{
	ChessMove *cm = [[ChessMove alloc] init];
	if (cm != nil) {
		cm->movePrint = [[data objectAtIndex: 29] retain];
		cm->timeUsed = [[data objectAtIndex: 28] retain];
		cm->positionAfter = [[Board boardFromStyle12: data] retain];
		cm->gameRelationship = [[data objectAtIndex: 19] intValue];
	}
	return [cm autorelease];
}

+ (ChessMove *) initialPosition
{
	ChessMove *cm = [[ChessMove alloc] init];
	if (cm != nil) {
		cm->positionAfter = [[Board startPosition] retain];
	}
	return [cm autorelease];
}

- (Board *) positionAfter
{
	return [[positionAfter retain] autorelease];
}

- (enum GameRelationship) gameRelationship
{
	return gameRelationship;
}

@end
