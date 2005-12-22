// icsinterface
// $Id: Game.m 79 2005-12-21 07:14:06Z kthul $

#import "global.h"

@interface MoveStore : NSObject {
	int moveNum;
	ChessMove *whiteMove, *blackMove;
}

- (MoveStore *) initWithMoveNum: (int) mn;
- (void) dealloc;
- (void) setWhiteMove: (ChessMove *) wm;
- (ChessMove *) whiteMove;
- (void) setBlackMove: (ChessMove *) bm;
- (ChessMove *) blackMove;
- (int) moveNum;
- (void) setMoveNum: (int) mn;

@end
