// icsinterface
// $Id: Game.m 79 2005-12-21 07:14:06Z kthul $

#import "MoveStore.h"

@implementation MoveStore

- (MoveStore *) initWithMoveNum: (int) mn
{
	if ((self = [super init]) != nil)
		moveNum = mn;
	return self;
}

- (void) dealloc
{
	[whiteMove release];
	[blackMove release];
	[super dealloc];
}

- (void) setWhiteMove: (ChessMove *) wm { 
	[whiteMove release];
	whiteMove = [wm retain];
}

- (ChessMove *) whiteMove
{ 
	return whiteMove;
}

- (void) setBlackMove: (ChessMove *) bm
{ 
	[blackMove release];
	blackMove = [bm retain];
}

- (ChessMove *) blackMove
{
	return blackMove;
}

- (int) moveNum 
{ 
	return moveNum;
}

- (void) setMoveNum: (int) mn { 
	moveNum = mn;
}

@end
