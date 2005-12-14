// icsinterface
// $Id$

#import <ctype.h>
#import "Game.h"
#import "Board.h"

@implementation Game

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

- (Board *) currentBoardPosition
{
	return [lastMove positionAfter];
}

- (void) newMove: (ChessMove *) move
{
	[lastMove release];
	lastMove = [move retain];
}

- (void) dealloc
{
	[whiteName release];
	[blackName release];
	[lastMove release];
	[super dealloc];
}

- (Game *) initWithStyle12: (NSArray *) data
{
	if ((self = [self init]) != nil) {
		[self setPlayerNamesWhite: [data objectAtIndex: 17] black: [data objectAtIndex: 18]];
		[self setTimeInitial: [[data objectAtIndex: 20] intValue] increment: [[data objectAtIndex: 21] intValue]];
	}
	return self;
}

- (NSString *) gameInfoString
{
	return [NSString stringWithFormat: @"%@ - %@, %d, %d", whiteName, blackName, initialTime, incrementTime];
}

@end
