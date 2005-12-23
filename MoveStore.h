// icsinterface
// $Id$

#import "global.h"
#import "ChessMove.h"

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
