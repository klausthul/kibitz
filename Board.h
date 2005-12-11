// icsinterface
// $Id$

#import "global.h"
#import "ChessMove.h"
#import "ChessMoveStore.h"

@interface Board : NSObject {
	unsigned char fields[64];
	enum CASTLE_RIGHTS castle_rights;
	enum COLOR to_move;
	int en_passant; 
}

- (int) pieceLine: (int) l row: (int) r;
- (void) startPosition;
- (void) printBoard;
- (ChessMoveStore *) doMove: (ChessMove *) move;
- (void) undoMove: (ChessMoveStore *) move;
- (unsigned char) pieceOnField: (ChessField) field;
- (void) setBoardFromString: (char *) s flip: (int) flip;

@end
