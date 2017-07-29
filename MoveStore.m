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

- (void) setMoveNum: (int) mn 
{ 
	moveNum = mn;
}

- (NSString *) whiteMovePrint
{
	return (whiteMove != nil) ? [whiteMove movePrint] : @"";
}

- (NSString *) blackMovePrint
{
	return (blackMove != nil) ? [blackMove movePrint] : @"";
}

@end
